//
//  SSVideoOverlayItem.m
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import "SSVideoOverlayItem.h"

#import "SSShaderTypes.h"
#import "SSUtil.h"

#import <GLKit/GLKMathUtils.h>
#import <MetalKit/MetalKit.h>
#import <UIKit/UIImage.h>

#define USE_CONVERT_VERTICES 0

@interface SSVideoOverlayItem ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@end
@implementation SSVideoOverlayItem
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}
#endif
- (instancetype)initWithImage:(UIImage *)image timeRange:(CMTimeRange)timeRange {
    if (self == [super init]) {
        self.image     = image;
        self.timeRange = timeRange;
        _primitiveType = MTLPrimitiveTypeTriangleStrip;
        _vertexCount   = 4;
    }
    return self;
}

static inline size_t FICByteAlign(size_t width, size_t alignment) {
    return ((width + (alignment - 1)) / alignment) * alignment;
}

static inline size_t FICByteAlignForCoreAnimation(size_t bytesPerRow) {
    return FICByteAlign(bytesPerRow, 64);  // 跟 CPU 的高速缓存器有关
}

- (id<MTLTexture>)createMTLTexture:(MTKTextureLoader *)loader device:(id<MTLDevice>)device {
    if (_texture) {
        return _texture;
    }

    CGImageRef imageRef = _image.CGImage;
    if (!imageRef) {
        return nil;
    }

    //    NSError *error = nil;
    //    _texture       = [loader newTextureWithCGImage:imageRef options:@{MTKTextureLoaderOptionSRGB: @(NO)} error:&error];
    //    if (error) {
    //        NSLog(@"newTextureWithCGImage!:%@", error);
    //    }
    size_t width            = CGImageGetWidth(imageRef);
    size_t height           = CGImageGetHeight(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel     = CGImageGetBitsPerPixel(imageRef);

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);

    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);

    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | alphaInfo;

    CGRect rect = CGRectMake(0, 0, width, height);

#if 0
    // 多重采样
    size_t imageRowLength = FICByteAlignForCoreAnimation((bitsPerPixel / bitsPerComponent) * width) * 4;
    CGContextRef context  = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, imageRowLength, colorSpace, bitmapInfo);
    //    CGContextTranslateCTM(context, 0, height);
    //    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, rect, imageRef);
    MTLTextureDescriptor *textureDes = [[MTLTextureDescriptor alloc] init];
    textureDes.textureType           = MTLTextureType2DMultisample;
    textureDes.width                 = width;
    textureDes.height                = height;
    textureDes.sampleCount           = 4;
    textureDes.pixelFormat           = MTLPixelFormatRGBA8Unorm;
    textureDes.usage                 = MTLTextureUsageShaderRead;
    textureDes.storageMode           = MTLStorageModeShared;
#else
    size_t imageRowLength = (bitsPerPixel / bitsPerComponent * width);
    CGContextRef context  = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, imageRowLength, colorSpace, bitmapInfo);

    CGContextDrawImage(context, rect, imageRef);
    MTLTextureDescriptor *textureDes = [[MTLTextureDescriptor alloc] init];
    textureDes.textureType           = MTLTextureType2D;
    textureDes.width                 = width;
    textureDes.height                = height;
    textureDes.sampleCount           = 1;
    textureDes.pixelFormat           = MTLPixelFormatRGBA8Unorm;
    textureDes.usage                 = MTLTextureUsageShaderRead;
    textureDes.storageMode           = MTLStorageModeShared;
#endif
    _texture = [device newTextureWithDescriptor:textureDes];

    void *imageData  = CGBitmapContextGetData(context);
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [_texture replaceRegion:region mipmapLevel:0 withBytes:imageData bytesPerRow:imageRowLength];
    CGContextRelease(context);
    return _texture;
}

- (id<MTLBuffer>)createVertexBuffer:(id<MTLDevice>)device {
    if (_vertexBuffer) {
        return _vertexBuffer;
    }

    _primitiveType    = MTLPrimitiveTypeTriangleStrip;
    _vertexCount      = 4;
    CGRect renderRect = self.metlRect;
    CGSize renderSize = self.renderSize;
    float vertices[16], sourceCoordinates[8];
    genMTLVertices(renderRect, renderSize, vertices, YES, NO);
    replaceArrayElements(sourceCoordinates, (void *)kMTLTextureCoordinatesIdentity, 8);
    SSVertex vertexData[4] = {0};
    for (int i = 0; i < 4; i++) {
        vertexData[i] = (SSVertex){
            {vertices[(i * 4)], vertices[(i * 4) + 1], vertices[(i * 4) + 2], vertices[(i * 4) + 3]},
            {sourceCoordinates[(i * 2)], sourceCoordinates[(i * 2) + 1]},
        };
    }
    _vertexBuffer = [device newBufferWithBytes:vertexData length:sizeof(vertexData) options:MTLResourceStorageModeShared];
    return _vertexBuffer;
}

- (id<MTLBuffer>)createUniformBuffer:(id<MTLDevice>)device {
    if (_uniformBuffer) {
        return _uniformBuffer;
    }

    SSUniform uniform = (SSUniform){
        .transformed = false,
        .projection  = getMetalMatrixFromGLKMatrix(GLKMatrix4Identity),
        //        .view        = getMetalMatrixFromGLKMatrix(GLKMatrix4Identity),
        .model = getMetalMatrixFromGLKMatrix(GLKMatrix4Identity),
    };

    if (self.angle != 0) {

        CGRect renderRect = self.metlRect;
        CGSize renderSize = self.renderSize;

        // 修改旋转中心
        CGPoint controlPoint     = CGPointMake(CGRectGetMidX(renderRect), CGRectGetMidY(renderRect));
        GLKMatrix4 transformto   = GLKMatrix4MakeTranslation(-controlPoint.x, -controlPoint.y, 0);
        GLKMatrix4 rotateMatrix  = GLKMatrix4MakeZRotation(GLKMathDegreesToRadians(-self.angle));
        GLKMatrix4 transformback = GLKMatrix4MakeTranslation(controlPoint.x, controlPoint.y, 0);

        GLKMatrix4 modelMatrix = GLKMatrix4Identity;
        modelMatrix            = GLKMatrix4Multiply(transformto, modelMatrix);
        modelMatrix            = GLKMatrix4Multiply(rotateMatrix, modelMatrix);
        modelMatrix            = GLKMatrix4Multiply(transformback, modelMatrix);

        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, renderSize.width, renderSize.height, 0, -1, 1);

        modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 500, 0), modelMatrix);

        uniform.transformed = true;
        uniform.projection  = getMetalMatrixFromGLKMatrix(projectionMatrix);
        //                uniform.view        = getMetalMatrixFromGLKMatrix(viewMatrix);
        uniform.model = getMetalMatrixFromGLKMatrix(modelMatrix);
    }

    _uniformBuffer = [device newBufferWithBytes:&uniform length:sizeof(uniform) options:MTLResourceStorageModeShared];

    return _uniformBuffer;
}

- (SSUniform)createUniformAtTween:(Float64)tween {

    Float64 angle = tween * 360;
    Float64 tx    = 0;
    Float64 ty    = tween * 400;

    CGRect renderRect = self.metlRect;
    CGSize renderSize = self.renderSize;

    // 修改旋转中心
    CGPoint controlPoint     = CGPointMake(CGRectGetMidX(renderRect), CGRectGetMidY(renderRect));
    GLKMatrix4 transformto   = GLKMatrix4MakeTranslation(-controlPoint.x, -controlPoint.y, 0);
    GLKMatrix4 rotateMatrix  = GLKMatrix4MakeZRotation(GLKMathDegreesToRadians(angle));
    GLKMatrix4 transformback = GLKMatrix4MakeTranslation(controlPoint.x, controlPoint.y, 0);

    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix            = GLKMatrix4Multiply(transformto, modelMatrix);
    modelMatrix            = GLKMatrix4Multiply(rotateMatrix, modelMatrix);
    modelMatrix            = GLKMatrix4Multiply(transformback, modelMatrix);

    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, renderSize.width, renderSize.height, 0, -1, 1);

    modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(tx, ty, 0), modelMatrix);

    return (SSUniform){
        .transformed = true,
        .projection  = getMetalMatrixFromGLKMatrix(projectionMatrix),
        .model       = getMetalMatrixFromGLKMatrix(modelMatrix),
    };
}
@end

