//
//  SSRenderer.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import <AVFoundation/AVVideoCompositing.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SSRenderer <NSObject>
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *sourcePixelBufferAttributes;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *requiredPixelBufferAttributesForRenderContext;

- (CVPixelBufferRef)renderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request;
@end

NS_ASSUME_NONNULL_END

