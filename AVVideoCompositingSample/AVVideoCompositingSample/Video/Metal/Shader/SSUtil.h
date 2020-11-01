//
//  SSUtil.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#ifndef SSUtil_h
#define SSUtil_h

#import <CoreGraphics/CGGeometry.h>
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMTimeRange.h>
#import <GLKit/GLKMatrix4.h>
#import <simd/simd.h>

typedef struct {
    CGFloat x, y, a, b;
} CGPointRotation;

static CGPointRotation CGPointMakeRotation(CGPoint center, CGFloat angle) {
    CGPointRotation t = {
        .x = center.x,
        .y = center.y,
        .a = cos(angle * (M_PI / 180.0)),
        .b = sin(angle * (M_PI / 180.0)),
    };
    return t;
}
/*

 以(x0,y0)为旋转中心点，
 已经知旋转前点的位置(x1,y1)和旋转的角度a，求旋转后点的新位置(x2,y2)

 如果是逆时针旋转：
 x2 = (x1 - x0) * cosa - (y1 - y0) * sina + x0
 y2 = (y1 - y0) * cosa + (x1 - x0) * sina + y0
 如果是顺时针旋转：
 x2 = (x1 - x0) * cosa + (y1 - y0) * sina + x0
 y2 = (y1 - y0) * cosa - (x1 - x0) * sina + y0
 */

/// 点旋转
/// @param p 待旋转点
/// @param t 变换
static CGPoint CGPointToRotation(CGPoint p, CGPointRotation t) {
    //    if (a > 0.0) {
    //        CGFloat x2 = (x1 - x0) * cosf(a) - (y1 - y0) * sinf(a) + x0;
    //        CGFloat y2 = (y1 - y0) * cosf(a) + (x1 - x0) * sinf(a) + y0;
    //        return CGPointMake(x2, y2);
    //    }
    CGFloat x = (p.x - t.x) * t.a + (p.y - t.y) * t.b + t.x;
    CGFloat y = (p.y - t.y) * t.a - (p.x - t.x) * t.b + t.y;
    return CGPointMake(x, y);
}

static float const kMTLTextureCoordinatesIdentity[8] = {
    0.0, 1.0,  //
    0.0, 0.0,  //
    1.0, 1.0,  //
    1.0, 0.0   //
};

static void replaceArrayElements(float arr0[], float arr1[], int size) {

    if ((arr0 == NULL || arr1 == NULL) && size > 0) {
        assert(0);
    }
    if (size < 0) {
        assert(0);
    }
    for (int i = 0; i < size; i++) {
        arr0[i] = arr1[i];
    }
}

///倒N形
static void genMTLVertices(CGRect rect, CGSize containerSize, float vertices[16], BOOL reverse, BOOL normalized) {
    if (vertices == NULL) {
        NSLog(@"generateMTLVertices params illegal.");
        assert(0);
        return;
    }
    if (containerSize.width <= 0 || containerSize.height <= 0) {
        NSLog(@"generateMTLVertices params containerSize illegal.");
        assert(0);
        return;
    }
    float originX, originY, width, height;
    if (normalized) {
        originX = -1 + 2 * rect.origin.x / containerSize.width;
        originY = 1 - 2 * rect.origin.y / containerSize.height;
        width   = 2 * rect.size.width / containerSize.width;
        height  = 2 * rect.size.height / containerSize.height;
    } else {
        originX = rect.origin.x;
        originY = rect.origin.y;
        width   = rect.size.width;
        height  = rect.size.height;
    }

    if (reverse) {

        if (normalized) {
            float tempVertices[] = {
                originX, originY - height, 0.0, 1.0,          //
                originX, originY, 0.0, 1.0,                   //
                originX + width, originY - height, 0.0, 1.0,  //
                originX + width, originY, 0.0, 1.0            //
            };
            replaceArrayElements(vertices, tempVertices, 16);
            return;
        }
        float tempVertices[] = {
            originX, originY + height, 0.0, 1.0,          //
            originX, originY, 0.0, 1.0,                   //
            originX + width, originY + height, 0.0, 1.0,  //
            originX + width, originY, 0.0, 1.0            //
        };
        replaceArrayElements(vertices, tempVertices, 16);
        return;
    }
    if (normalized) {
        float tempVertices[] = {
            originX, originY, 0.0, 1.0,                  //
            originX, originY - height, 0.0, 1.0,         //
            originX + width, originY, 0.0, 1.0,          //
            originX + width, originY - height, 0.0, 1.0  //
        };
        replaceArrayElements(vertices, tempVertices, 16);
        return;
    }
    float tempVertices[] = {
        originX, originY, 0.0, 1.0,                  //
        originX, originY + height, 0.0, 1.0,         //
        originX + width, originY, 0.0, 1.0,          //
        originX + width, originY + height, 0.0, 1.0  //
    };
    replaceArrayElements(vertices, tempVertices, 16);
}

static simd_float4x4 getMetalMatrixFromGLKMatrix(GLKMatrix4 matrix) {
    simd_float4x4 ret = (simd_float4x4){
        simd_make_float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
        simd_make_float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
        simd_make_float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
        simd_make_float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33),
    };
    return ret;
}

static void GLKMatrix4Show(GLKMatrix4 matrix) {
    printf("GLKMatrix4:\n{\n%f,%f,%f,%f\n%f,%f,%f,%f\n%f,%f,%f,%f\n%f,%f,%f,%f\n}\n",
           matrix.m00, matrix.m01, matrix.m02, matrix.m03,
           matrix.m10, matrix.m11, matrix.m12, matrix.m13,
           matrix.m20, matrix.m21, matrix.m22, matrix.m23,
           matrix.m30, matrix.m31, matrix.m32, matrix.m33);
}

/// 由屏幕坐标转换到归一化坐标
/// @param pt_dc 屏幕坐标
/// @param size 屏幕大小
/// @return 归一化坐标
static CGPoint dc_to_ndc(CGPoint pt_dc, CGSize size) {
    CGFloat x = (pt_dc.x + 0.5) / size.width;
    CGFloat y = (pt_dc.y + 0.5) / size.height;
    return CGPointMake(x * 2.0 - 1.0, -(y * 2.0 - 1.0));
}

/// 由归一化坐标转换到屏幕坐标
/// @param pt_ndc 归一化坐标
/// @param size 屏幕大小
/// @return 屏幕坐标
static CGPoint ndc_to_dc(CGPoint pt_ndc, CGSize size) {
    CGFloat x = (pt_ndc.x + 1.0) * 0.5;
    CGFloat y = (-pt_ndc.y + 1.0) * 0.5;
    x         = x * size.width - 0.5;
    y         = y * size.height - 0.5;

    return CGPointMake(x, y);
}

CM_INLINE Float64 factorForTimeInRange(CMTime time, CMTimeRange range) {
    CMTime elapsed = CMTimeSubtract(time, range.start);
    return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration);
}
#endif /* SSUtil_h */

