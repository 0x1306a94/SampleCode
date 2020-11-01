//
//  SSShaderTypes.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#ifndef SSShaderTypes_h
#define SSShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float4 position;
    vector_float2 textureCoordinate;
} SSVertex;

typedef struct {
    bool transformed;
    matrix_float4x4 projection;
//    matrix_float4x4 view;
    matrix_float4x4 model;
} SSUniform;

typedef enum SSVertexInputIndex {
    SSVertexInputIndexVertexs  = 0,
    SSVertexInputIndexUniforms = 1,
} SSVertexInputIndex;

typedef enum SSFragmentTextureIndex {
    SSFragmentTextureVideoIndex      = 0,
    SSFragmentTextureAttachmentIndex = 1,
} SSFragmentTextureIndex;

#endif /* SSShaderTypes_h */

