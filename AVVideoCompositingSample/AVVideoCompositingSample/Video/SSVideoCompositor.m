//
//  SSVideoCompositor.m
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import "SSVideoCompositor.h"

#import "SSMetalRenderer.h"
#import "SSRenderer.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface SSVideoCompositor ()
@property (nonatomic, strong) dispatch_queue_t renderContextQueue;
@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (nonatomic, assign) BOOL renderContextDidChange;
@property (nonatomic, assign) BOOL shouldCancelAllRequests;
@property (nonatomic, strong) AVVideoCompositionRenderContext *renderContext;

@property (nonatomic, strong) id<SSRenderer> renderer;

@end

@implementation SSVideoCompositor

- (instancetype)init {
    if (self == [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _renderContextQueue      = dispatch_queue_create("com.0x1306a94.videoeditor.renderContextQueue", DISPATCH_QUEUE_SERIAL);
    _renderingQueue          = dispatch_queue_create("com.0x1306a94.videoeditor.renderingQueue", DISPATCH_QUEUE_SERIAL);
    _renderContextDidChange  = NO;
    _shouldCancelAllRequests = NO;

    NSError *error = nil;
    _renderer      = [[SSMetalRenderer alloc] initWithError:&error];
    if (error) {
        NSAssert(NO, @"%@", error);
    }
    _sourcePixelBufferAttributes = _renderer.sourcePixelBufferAttributes;

    _requiredPixelBufferAttributesForRenderContext = _renderer.requiredPixelBufferAttributesForRenderContext;
}

#pragma mark - private
- (CVPixelBufferRef)newRenderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request {
    return [self.renderer renderedPixelBufferForRequest:request];
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.renderContextQueue, ^{
        __strong typeof(self) self = weakSelf;
        if (!self) {
            return;
        }

        self.renderContext          = newRenderContext;
        self.renderContextDidChange = YES;
    });
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.renderingQueue, ^{
        __strong typeof(self) self = weakSelf;
        if (!self) {
            [request finishCancelledRequest];
            return;
        }
        if (self.shouldCancelAllRequests) {
            [request finishCancelledRequest];
            return;
        }
        @autoreleasepool {
            CVPixelBufferRef resultPixels = [self newRenderedPixelBufferForRequest:request];
            if (resultPixels) {
                [request finishWithComposedVideoFrame:resultPixels];
                // 释放内存,否则会持续增长内存,最终导致crash
                CVPixelBufferRelease(resultPixels);
            } else {
                [request finishWithError:[NSError errorWithDomain:@"VideoEditor" code:400 userInfo:nil]];
            }
        }
    });
}

- (void)cancelAllPendingVideoCompositionRequests {
    self.shouldCancelAllRequests = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.renderingQueue, ^{
        __strong typeof(self) self = weakSelf;
        if (!self) {
            return;
        }
        self.shouldCancelAllRequests = NO;
    });
}

- (void)dealloc {
    _renderer = nil;
#if DEBUG
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
#endif
}
@end

