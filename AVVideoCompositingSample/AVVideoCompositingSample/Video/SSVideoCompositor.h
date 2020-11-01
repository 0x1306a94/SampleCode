//
//  SSVideoCompositor.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import <AVFoundation/AVVideoCompositing.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface SSVideoCompositor : NSObject <AVVideoCompositing>
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *sourcePixelBufferAttributes;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *requiredPixelBufferAttributesForRenderContext;

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext;

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)asyncVideoCompositionRequest;

@end

NS_ASSUME_NONNULL_END

