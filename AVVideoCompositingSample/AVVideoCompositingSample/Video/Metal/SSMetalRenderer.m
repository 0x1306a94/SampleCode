//
//  SSMetalRenderer.m
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import "SSMetalRenderer.h"

#import "SSShaderTypes.h"
#import "SSUtil.h"
#import "SSVideoCompositionInstruction.h"
#import "SSVideoOverlayItem.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <GLKit/GLKMatrix4.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

static NSErrorDomain __error_domain__ = @"SSMetalRenderer";

static matrix_float3x3 kColorConversion601FullRangeMatrix = (matrix_float3x3){
    (simd_float3){1.0, 1.0, 1.0},       //
    (simd_float3){0.0, -0.343, 1.765},  //
    (simd_float3){1.4, -0.711, 0.0},    //
};

static vector_float3 kColorConversion601FullRangeOffset = (vector_float3){
    -(16.0 / 255.0),  //
    -0.5,             //
    -0.5,             //
};

static NSUInteger kSampleCount = 4;

@interface SSMetalRenderer ()
@property (nonatomic, strong) id<MTLLibrary> library;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLRenderPipelineState> attachmentPipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> defaultMainPipelineState;
@property (nonatomic, strong) id<MTLTexture> msaaTexture;
@property (nonatomic, strong) MTKTextureLoader *loader;
@property (nonatomic, assign) CVMetalTextureCacheRef videoTextureCache;  //need release
@end

@implementation SSMetalRenderer
- (instancetype)initWithError:(__autoreleasing NSError **)error {
	if (self == [super init]) {
		[self commonInit:error];
		if (*error) {
			return nil;
		}
	}
	*error = nil;
	return self;
}

- (void)commonInit:(__autoreleasing NSError **)error {
	_sourcePixelBufferAttributes = @{
		(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
		(__bridge NSString *)kCVPixelBufferMetalCompatibilityKey: @YES,
	};

	_requiredPixelBufferAttributesForRenderContext = @{
		(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
		(__bridge NSString *)kCVPixelBufferMetalCompatibilityKey: @YES,
	};

	_device             = MTLCreateSystemDefaultDevice();
	_commandQueue       = [_device newCommandQueue];
	_commandQueue.label = @"com.0x1306a94.commandQueue";

	_library = [_device newDefaultLibrary];

	_defaultMainPipelineState = [self createPipelineState:@"vertex_main" fragmentFunction:@"fragment_main" error:error];

	if (*error) {
		NSAssert(NO, @"%@", *error);
		return;
	}

	_attachmentPipelineState = [self createPipelineState:@"vertex_attachment_main" fragmentFunction:@"fragment_attachment_main" error:error];

	if (*error) {
		NSAssert(NO, @"%@", *error);
		return;
	}

	_loader = [[MTKTextureLoader alloc] initWithDevice:_device];
	// 倒N型
	SSVertex vertexData[4] = {
	    {{-1, -1, 0, 1}, {0, 1}},  // 左下
	    {{-1, 1, 0, 1}, {0, 0}},   // 左上
	    {{1, -1, 0, 1}, {1, 1}},   // 右下
	    {{1, 1, 0, 1}, {1, 0}},    // 右上
	};

	_vertexBuffer = [_device newBufferWithBytes:vertexData length:sizeof(vertexData) options:MTLResourceStorageModeShared];

	//texture cache
	CVReturn textureCacheError = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, _device, NULL, &_videoTextureCache);
	if (textureCacheError != kCVReturnSuccess) {
		*error = [NSError errorWithDomain:__error_domain__ code:400 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"create texture cache fail!:%d", textureCacheError]}];
		NSAssert(NO, @"%@", *error);
		return;
	}
}

#pragma mark - pipelines
- (id<MTLRenderPipelineState>)createPipelineState:(NSString *)vertexFunction fragmentFunction:(NSString *)fragmentFunction error:(NSError **)error {

	id<MTLFunction> vertexProgram   = [_library newFunctionWithName:vertexFunction];
	id<MTLFunction> fragmentProgram = [_library newFunctionWithName:fragmentFunction];

	if (!vertexProgram || !fragmentProgram) {
		*error = [NSError errorWithDomain:__error_domain__ code:400 userInfo:@{NSLocalizedFailureReasonErrorKey: @"check if .metal files been compiled to correct target!"}];
		NSAssert(0, @"check if .metal files been compiled to correct target!");
		return nil;
	}

	//融混方程
	//https://objccn.io/issue-3-1/
	//https://www.andersriggelsen.dk/glblendfunc.php
	MTLRenderPipelineDescriptor *pipelineStateDescriptor                    = [MTLRenderPipelineDescriptor new];
	pipelineStateDescriptor.vertexFunction                                  = vertexProgram;
	pipelineStateDescriptor.fragmentFunction                                = fragmentProgram;
	pipelineStateDescriptor.colorAttachments[0].pixelFormat                 = MTLPixelFormatBGRA8Unorm;
	pipelineStateDescriptor.colorAttachments[0].blendingEnabled             = YES;
	pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation           = MTLBlendOperationAdd;
	pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation         = MTLBlendOperationAdd;
	pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor        = MTLBlendFactorSourceAlpha;
	pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor      = MTLBlendFactorSourceAlpha;
	pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor   = MTLBlendFactorOneMinusSourceAlpha;
	pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
	// MSAA
	pipelineStateDescriptor.rasterSampleCount = kSampleCount;
	pipelineStateDescriptor.sampleCount       = kSampleCount;

	NSError *psError = nil;

	id<MTLRenderPipelineState> pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&psError];
	if (!pipelineState || psError) {
		*error = [NSError errorWithDomain:__error_domain__ code:400 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"newRenderPipelineStateWithDescriptor error!:%@", psError]}];
		return nil;
	}

	return pipelineState;
}

#pragma mark - setupRenderPassDescriptorForTexture
- (MTLRenderPassDescriptor *)setupRenderPassDescriptorForTexture:(id<MTLTexture>)texture {

	if (_msaaTexture == nil) {
		MTLTextureDescriptor *desc = [[MTLTextureDescriptor alloc] init];
		desc.textureType           = MTLTextureType2DMultisample;
		desc.width                 = texture.width;
		desc.height                = texture.height;
		desc.sampleCount           = kSampleCount;
		desc.pixelFormat           = MTLPixelFormatBGRA8Unorm;
		desc.usage                 = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
		desc.storageMode           = MTLStorageModePrivate;

		_msaaTexture = [_device newTextureWithDescriptor:desc];
	}

	MTLRenderPassDescriptor *renderPassDescriptor           = [MTLRenderPassDescriptor renderPassDescriptor];
	renderPassDescriptor.colorAttachments[0].texture        = _msaaTexture;
	renderPassDescriptor.colorAttachments[0].resolveTexture = texture;
	renderPassDescriptor.colorAttachments[0].clearColor     = MTLClearColorMake(0, 0, 0, 0.0);
	renderPassDescriptor.colorAttachments[0].loadAction     = MTLLoadActionClear;
	renderPassDescriptor.colorAttachments[0].storeAction    = MTLStoreActionStoreAndMultisampleResolve;

	return renderPassDescriptor;
}

#pragma mark - buildTextureForPixelBuffer
- (id<MTLTexture>)buildTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer {
	if (pixelBuffer == NULL) {
		return nil;
	}
	size_t width  = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
	size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);

	CVMetalTextureRef textureRef = NULL;

	CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, _videoTextureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &textureRef);
	if (status != kCVReturnSuccess) {
		return nil;
	}

	id<MTLTexture> texture = CVMetalTextureGetTexture(textureRef);
	CFRelease(textureRef);
	return texture;
}

- (void)dispose {

	_commandQueue            = nil;
	_vertexBuffer            = nil;
	_attachmentPipelineState = nil;
	if (_videoTextureCache) {
		CVMetalTextureCacheFlush(_videoTextureCache, 0);
		CFRelease(_videoTextureCache);
		_videoTextureCache = NULL;
	}
	_defaultMainPipelineState = nil;
}

#pragma mark - SSRenderer
- (CVPixelBufferRef)renderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request {

	if (!request.videoCompositionInstruction || ![request.videoCompositionInstruction isKindOfClass:SSVideoCompositionInstruction.class]) {
		if (request.sourceTrackIDs.count == 0) {
			return NULL;
		}
		NSNumber *trackID            = request.sourceTrackIDs.firstObject;
		CVPixelBufferRef frameBuffer = [request sourceFrameByTrackID:(CMPersistentTrackID)trackID.integerValue];
		// 外部会进行 Realse, 所以这里需要 先 Retain
		CVPixelBufferRetain(frameBuffer);
		return frameBuffer;
	}

	__block CVPixelBufferRef outputPixels = [request.renderContext newPixelBuffer];

	SSVideoCompositionInstruction *instruction = (SSVideoCompositionInstruction *)request.videoCompositionInstruction;

	CGSize renderSize = request.renderContext.size;

	NSNumber *trackID            = (NSNumber *)instruction.requiredSourceTrackIDs.firstObject;
	CVPixelBufferRef frameBuffer = [request sourceFrameByTrackID:(CMPersistentTrackID)trackID.integerValue];
	if (frameBuffer) {
		id<MTLTexture> destinationTexture = [self buildTextureForPixelBuffer:outputPixels];
		id<MTLTexture> backgroundTexture  = [self buildTextureForPixelBuffer:frameBuffer];
		if (!destinationTexture || !backgroundTexture) {
			CVPixelBufferRetain(frameBuffer);
			if (outputPixels) CVPixelBufferRelease(outputPixels);
			return frameBuffer;
		}
		id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
		commandBuffer.label                = @"MyCommand";

		MTLRenderPassDescriptor *renderPassDescriptor = [self setupRenderPassDescriptorForTexture:destinationTexture];

		id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		renderEncoder.label                       = @"MyRenderEncoder";

		MTLViewport viewport = (MTLViewport){0, 0, renderSize.width, renderSize.height, -1, 1};
		[renderEncoder setViewport:viewport];
		// 绘制原始视频帧
		[renderEncoder setRenderPipelineState:_defaultMainPipelineState];
		[renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:SSVertexInputIndexVertexs];
		[renderEncoder setFragmentTexture:backgroundTexture atIndex:SSFragmentTextureVideoIndex];
		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
		// 渲染贴图
		CMTime atTime = request.compositionTime;
		for (SSVideoOverlayItem *overlayItem in instruction.overlayItems) {
			if (CMTimeRangeContainsTime(overlayItem.timeRange, atTime)) {
				id<MTLTexture> texture = [overlayItem createMTLTexture:_loader device:_device];
				if (!texture) {
					continue;
				}
				id<MTLBuffer> vertexBuffer = [overlayItem createVertexBuffer:_device];
				if (!vertexBuffer) {
					continue;
				}
				//                id<MTLBuffer> uniformBuffer = [overlayItem createUniformBuffer:_device];
				//                if (!uniformBuffer) {
				//                    continue;
				//                }
				Float64 tween     = factorForTimeInRange(atTime, overlayItem.timeRange);
				float alpha       = fminf(1.0, (tween * 2 * 1.0));
				SSUniform uniform = [overlayItem createUniformAtTween:tween];
				[renderEncoder setRenderPipelineState:_attachmentPipelineState];
				[renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:SSVertexInputIndexVertexs];
				//                [renderEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:SSVertexInputIndexUniforms];
				[renderEncoder setVertexBytes:&uniform length:sizeof(uniform) atIndex:SSVertexInputIndexUniforms];
				[renderEncoder setFragmentTexture:texture atIndex:SSFragmentTextureAttachmentIndex];
				[renderEncoder setFragmentBytes:&alpha length:sizeof(float) atIndex:0];
				[renderEncoder drawPrimitives:overlayItem.primitiveType vertexStart:0 vertexCount:overlayItem.vertexCount instanceCount:1];
			}
		}

		[renderEncoder endEncoding];
		[commandBuffer commit];
		[commandBuffer waitUntilCompleted];
	}

	return outputPixels;
}

#pragma mark - dealloc
- (void)dealloc {
	[self dispose];
#if DEBUG
	NSLog(@"[%@ dealloc]", self.class);
#endif
}
@end

