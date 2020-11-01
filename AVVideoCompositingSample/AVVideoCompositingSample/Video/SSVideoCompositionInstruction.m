//
//  SSVideoCompositionInstruction.m
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import "SSVideoCompositionInstruction.h"

@implementation SSVideoCompositionInstruction
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}
#endif

- (instancetype)initWithPassthroughTrackID:(CMPersistentTrackID)passthroughTrackID timeRange:(CMTimeRange)timeRange {
    self = [super init];
    if (self) {
        _passthroughTrackID     = passthroughTrackID;
        _timeRange              = timeRange;
        _requiredSourceTrackIDs = @[];
        _containsTweening       = NO;
        _enablePostProcessing   = NO;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithSourceTrackIDs:(NSArray<NSValue *> *)sourceTrackIDs timeRange:(CMTimeRange)timeRange {
    self = [super init];
    if (self) {
        _requiredSourceTrackIDs = sourceTrackIDs;
        _timeRange              = timeRange;
        _passthroughTrackID     = kCMPersistentTrackID_Invalid;
        _containsTweening       = YES;
        _enablePostProcessing   = NO;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p {{%lld/%d = %.03f}, {%lld/%d = %.03f}}> trackIDs: %@",
                                      NSStringFromClass(self.class),
                                      self,
                                      self.timeRange.start.value,
                                      self.timeRange.start.timescale,
                                      CMTimeGetSeconds(self.timeRange.start),
                                      self.timeRange.duration.value,
                                      self.timeRange.duration.timescale,
                                      CMTimeGetSeconds(self.timeRange.duration),
                                      self.requiredSourceTrackIDs];
}
@end

