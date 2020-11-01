//
//  SSMetalRenderer.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSMetalRenderer : NSObject<SSRenderer>
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *sourcePixelBufferAttributes;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *requiredPixelBufferAttributesForRenderContext;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithError:(__autoreleasing NSError **)error NS_DESIGNATED_INITIALIZER;

- (CVPixelBufferRef)renderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request;
@end

NS_ASSUME_NONNULL_END

