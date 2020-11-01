//
//  SSVideoOverlayItem.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import <CoreGraphics/CGAffineTransform.h>
#import <CoreGraphics/CGGeometry.h>
#import <CoreImage/CIImage.h>
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMTimeRange.h>
#import <Foundation/Foundation.h>
#import <Metal/MTLRenderCommandEncoder.h>

#import "SSShaderTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class MTKTextureLoader;
@class UIImage;

@protocol MTLDevice;
@protocol MTLTexture;
@protocol MTLBuffer;

@interface SSVideoOverlayItem : NSObject
@property (nonatomic, assign, readonly) CMTimeRange timeRange;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGSize overlaySize;
@property (nonatomic, assign) CGSize renderSize;
@property (nonatomic, assign) CGRect metlRect;
@property (nonatomic, assign, readonly) MTLPrimitiveType primitiveType;
@property (nonatomic, assign, readonly) NSUInteger vertexCount;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithImage:(UIImage *_Nullable)image timeRange:(CMTimeRange)timeRange NS_DESIGNATED_INITIALIZER;

- (id<MTLTexture>)createMTLTexture:(MTKTextureLoader *)loader device:(id<MTLDevice>)device;
- (id<MTLBuffer>)createVertexBuffer:(id<MTLDevice>)device;
- (id<MTLBuffer>)createUniformBuffer:(id<MTLDevice>)device;
- (SSUniform)createUniformAtTween:(Float64)tween;
@end

NS_ASSUME_NONNULL_END

