//
//  SSVideoCompositionInstruction.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import <AVFoundation/AVVideoCompositing.h>
#import <AVFoundation/AVVideoComposition.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSVideoOverlayItem;

@interface SSVideoCompositionInstruction : NSObject <AVVideoCompositionInstruction>
@property (nonatomic, assign, readonly) CMTimeRange timeRange;
@property (nonatomic, assign) BOOL enablePostProcessing;
@property (nonatomic, assign) BOOL containsTweening;
@property (nonatomic, strong, nullable) NSArray<NSValue *> *requiredSourceTrackIDs;
@property (nonatomic, assign) CMPersistentTrackID passthroughTrackID;
@property (nonatomic, copy) NSArray<SSVideoOverlayItem *> *overlayItems;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithPassthroughTrackID:(CMPersistentTrackID)passthroughTrackID timeRange:(CMTimeRange)timeRange NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithSourceTrackIDs:(NSArray<NSValue *> *)sourceTrackIDs timeRange:(CMTimeRange)timeRange NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END

