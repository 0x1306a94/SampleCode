//
//  Shader.metal
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#include <metal_stdlib>
#include "SSShaderTypes.h"
using namespace metal;

typedef struct {
    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
    float2 textureCoordinate; // 纹理坐标，会做插值处理

} RasterizerData;


vertex RasterizerData // 返回给片元着色器的结构体
vertex_main(uint vid [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
             constant SSVertex *vertexArray [[ buffer(SSVertexInputIndexVertexs) ]]) { // buffer表明是缓存数据，SSVertexInputIndexVertexs是索引
    RasterizerData out;
	out.clipSpacePosition = vertexArray[vid].position;
    out.textureCoordinate = vertexArray[vid].textureCoordinate;
    return out;
}

fragment half4 //
fragment_main(RasterizerData input [[stage_in]],
              texture2d<half> texture [[ texture(SSFragmentTextureVideoIndex) ]]) {

    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器

    half4 textureColor = texture.sample(textureSampler, input.textureCoordinate);
    return textureColor;
}

vertex RasterizerData // 返回给片元着色器的结构体
vertex_attachment_main(uint vid [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
			 constant SSVertex *vertexArray [[ buffer(SSVertexInputIndexVertexs) ]], // buffer表明是缓存数据，SSVertexInputIndexVertexs是索引
			constant SSUniform & uniforms [[ buffer(SSVertexInputIndexUniforms) ]]) { // buffer表明是缓存数据，SSVertexInputIndexUniforms是索引
	RasterizerData out;
	if (uniforms.transformed) {
//		out.clipSpacePosition = uniforms.projection * uniforms.view * uniforms.model * vertexArray[vid].position;
        out.clipSpacePosition = uniforms.projection * uniforms.model * vertexArray[vid].position;
//		out.clipSpacePosition = uniforms.model * vertexArray[vid].position;
	} else {
		out.clipSpacePosition = vertexArray[vid].position;
	}
	out.textureCoordinate = vertexArray[vid].textureCoordinate;
	return out;
}

fragment float4 //
fragment_attachment_main(RasterizerData input [[stage_in]],
              texture2d<float> texture [[ texture(SSFragmentTextureAttachmentIndex) ]],
                         constant float & alpha [[ buffer(0) ]]) {

    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器

    float4 textureColor = texture.sample(textureSampler, input.textureCoordinate);
    return float4(textureColor.rgb, alpha);
}

//fragment float4 //
//fragment_attachment_main(RasterizerData input [[stage_in]],
//              texture2d_ms<half> texture [[ texture(SSFragmentTextureAttachmentIndex) ]]) {
//
//
//    const uint num_samples      = texture.get_num_samples();
//    const uint2 tex_coord       = uint2(input.textureCoordinate.x * 1000, input.textureCoordinate.y * 1000);
//    half4 color_totals          = half4(0,0,0,0);
//
//    for (uint sample_num=0; sample_num<num_samples; ++sample_num) {
//        const half4 sample      = texture.read(tex_coord, sample_num);
//        color_totals            += sample;
//    }
//
//    float4 color                = float4(color_totals);
//    color /= float(num_samples);
//
//    return color;
//}
