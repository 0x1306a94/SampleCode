//
//  ViewController.m
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import "ViewController.h"

#import "SSVideoCompositionInstruction.h"
#import "SSVideoCompositor.h"
#import "SSVideoOverlayItem.h"
#import "SSVideoPreviewView.h"

#import <AVFoundation/AVFoundation.h>

#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewController ()
@property (nonatomic, weak) IBOutlet SSVideoPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *exportButton;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAssetExportSession *session;
@property (nonatomic, strong) id timeObserver;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.view.backgroundColor = UIColor.whiteColor;
	self.playButton.enabled   = NO;
	self.stopButton.enabled   = NO;
	self.exportButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		[weakSelf prepare:^(BOOL succeed, AVMutableComposition *composition, AVMutableVideoComposition *videoComposition, AVMutableAudioMix *audioMix) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
				if (!succeed) {
					return;
				}

				AVPlayerItem *item    = [AVPlayerItem playerItemWithAsset:composition];
				item.videoComposition = videoComposition;
				item.audioMix         = audioMix;

				weakSelf.player = [AVPlayer playerWithPlayerItem:item];
				[weakSelf.previewView attachPlayer:weakSelf.player];
				weakSelf.playButton.enabled   = YES;
				weakSelf.stopButton.enabled   = NO;
				weakSelf.exportButton.enabled = YES;
				weakSelf.timeObserver         = [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                    if (CMTIME_COMPARE_INLINE(time, >=, item.duration)) {
                        weakSelf.stopButton.enabled = NO;
                        weakSelf.playButton.enabled = YES;
                    }
                }];
			});
		}];
	});
}

- (IBAction)playButtonAction:(UIButton *)sender {
	sender.enabled          = NO;
	self.stopButton.enabled = YES;
	if (CMTIME_COMPARE_INLINE(self.player.currentTime, >=, self.player.currentItem.duration)) {
		__weak typeof(self) weakSelf = self;
		[self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
			[weakSelf.player play];
		}];
	} else {
		[self.player play];
	}
}

- (IBAction)stopButtonAction:(UIButton *)sender {
	sender.enabled          = NO;
	self.playButton.enabled = YES;
	[self.player pause];
}

- (IBAction)exportButtonAction:(UIButton *)sender {

	__block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.backgroundColor        = [UIColor.blackColor colorWithAlphaComponent:0.6];
	hud.mode                   = MBProgressHUDModeAnnularDeterminate;

	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		[weakSelf prepare:^(BOOL succeed, AVMutableComposition *composition, AVMutableVideoComposition *videoComposition, AVMutableAudioMix *audioMix) {
			if (!succeed) {
				dispatch_async(dispatch_get_main_queue(), ^{
					hud.detailsLabel.text = @"失败了";
					[hud hideAnimated:2.0 afterDelay:YES];
				});
				return;
			}
			NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"mp4"];
			NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
			NSURL *outputURL   = [NSURL fileURLWithPath:[document stringByAppendingPathComponent:fileName]];
			NSFileManager *fm  = [NSFileManager defaultManager];
			if ([fm fileExistsAtPath:outputURL.path]) {
				[fm removeItemAtURL:outputURL error:nil];
			}
			AVAssetExportSession *session       = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
			session.shouldOptimizeForNetworkUse = YES;
			session.outputURL                   = outputURL;
			session.outputFileType              = AVFileTypeMPEG4;
			session.videoComposition            = videoComposition;
			session.audioMix                    = audioMix;

			__block NSTimer *timer = nil;  //
			dispatch_async(dispatch_get_main_queue(), ^{
				timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *_Nonnull timer) {
					hud.progress = session.progress;
				}];
				[timer fire];
			});

			[session exportAsynchronouslyWithCompletionHandler:^{
				dispatch_async(dispatch_get_main_queue(), ^{
					[timer invalidate];
					timer = nil;
					switch (session.status) {
						case AVAssetExportSessionStatusCompleted: {
							hud.progress = 1.0;
							NSLog(@"导出完成: %@", outputURL);
							break;
						}
						case AVAssetExportSessionStatusFailed: {
							NSLog(@"%@", session.error);
							break;
						}
						default:
							break;
					}

					[hud hideAnimated:YES afterDelay:1.0];
				});
			}];
		}];
	});
}

#pragma mark - prepare
- (void)prepare:(void (^)(BOOL succeed, AVMutableComposition *composition, AVMutableVideoComposition *videoComposition, AVMutableAudioMix *audioMix))completion {
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"MP4"];
	self.asset = [AVURLAsset URLAssetWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];

	NSArray<NSString *> *keys = @[
		@"tracks",
		@"duration",
		@"commonMetadata",
	];

	dispatch_semaphore_t semaphore  = dispatch_semaphore_create(0);
	void (^completionHandler)(void) = ^{
		// Production code should be more robust.  Specifically, should capture error in failure case.
		AVKeyValueStatus tracksStatus   = [self.asset statusOfValueForKey:@"tracks" error:nil];
		AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:@"duration" error:nil];
		BOOL prepared                   = (tracksStatus == AVKeyValueStatusLoaded) && (durationStatus == AVKeyValueStatusLoaded);
		if (prepared) {
			dispatch_semaphore_signal(semaphore);
		}
	};

	[self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:completionHandler];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

	AVAssetTrack *videoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
	AVAssetTrack *audioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio].firstObject;

	AVMutableComposition *composition = [AVMutableComposition composition];
	CGSize naturalSize                = videoTrack.naturalSize;
	composition.naturalSize           = naturalSize;

	AVMutableCompositionTrack *videoTracks = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack *audioTracks = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

	NSArray<AVMutableAudioMixInputParameters *> *audioMixParameters = @[];

	CMTimeRange timeRange = videoTrack.timeRange;
	[videoTracks insertTimeRange:timeRange
	                     ofTrack:videoTrack
	                      atTime:kCMTimeZero
	                       error:nil];
#warning 音频轨时间不能超过视频轨,否则会导致 AVVideoCompositing 不会正常工作
	[audioTracks insertTimeRange:timeRange
	                     ofTrack:audioTrack
	                      atTime:kCMTimeZero
	                       error:nil];

	AVMutableAudioMixInputParameters *audioParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
	[audioParameters setVolume:1.0 atTime:kCMTimeZero];
	audioMixParameters = @[
		audioParameters,
	];

	CMTimeShow(composition.duration);
	CMTimeRangeShow(videoTrack.timeRange);
	CMTimeRangeShow(audioTrack.timeRange);

	SSVideoCompositionInstruction *instruction = [[SSVideoCompositionInstruction alloc] initWithSourceTrackIDs:@[@(videoTracks.trackID)] timeRange:timeRange];

	UIImage *image           = [UIImage imageNamed:@"image.jpeg"];
	SSVideoOverlayItem *item = [[SSVideoOverlayItem alloc] initWithImage:image timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(10 * 30, 30))];
	item.overlaySize         = CGSizeMake(600, 600);
	item.renderSize          = composition.naturalSize;
	item.metlRect            = CGRectMake((naturalSize.width - item.overlaySize.width) * 0.5, 200, item.overlaySize.width, item.overlaySize.height);
	item.angle               = -15;
	instruction.overlayItems = @[item];

	AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
	videoComposition.frameDuration              = CMTimeMake(1, videoTrack.nominalFrameRate);
	videoComposition.renderSize                 = composition.naturalSize;
	videoComposition.instructions               = @[instruction];
	videoComposition.customVideoCompositorClass = SSVideoCompositor.class;

	AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
	audioMix.inputParameters    = audioMixParameters;

	!completion ?: completion(YES, composition, videoComposition, audioMix);
}
@end

