//
//  SSVideoPreviewView.m
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import "SSVideoPreviewView.h"

#import <AVFoundation/AVPlayerLayer.h>

@implementation SSVideoPreviewView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    _videoGravity = AVLayerVideoGravityResizeAspect;
}

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity                   = videoGravity;
    [self playerLayer].videoGravity = videoGravity;
}

- (void)attachPlayer:(AVPlayer *)player {
    [self playerLayer].player       = player;
    [self playerLayer].videoGravity = _videoGravity;
}

@end

