//
//  Normal.metal
//  i-Reporter
//
//  Created by azun on 16/01/2024.
//  Copyright (c) 2024 CIMTOPS CORPORATION. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands.
#include "FreeDrawShaderTypes.h"

// Vertex shader outputs and fragment shader inputs
struct RasterizerData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Since this member does not have a special attribute qualifier, the rasterizer
    // will interpolate its value with values of other vertices making up the triangle
    // and pass that interpolated value to the fragment shader for each fragment in
    // that triangle.
    float2 textureCoordinate;
};

vertex RasterizerData
normal_vertex(uint vertexID [[vertex_id]],
             constant FreeDrawVertex *vertices [[buffer(FreeDrawVertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(FreeDrawVertexInputIndexViewportSize)]])
{
    RasterizerData out;

    // Index into the array of positions to get the current vertex.
    // The positions are specified in pixel dimensions (i.e. a value of 100
    // is 100 pixels from the origin).
    float2 pixelSpacePosition = vertices[vertexID].position.xy;

    // Get the viewport size and cast to float.
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    

    // To convert from positions in pixel space to positions in clip-space,
    //  divide the pixel coordinates by half the size of the viewport.
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
//    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    /// migration
//    float halfWidth = viewportSize.x / 2;
//    float halfHeight = viewportSize.y / 2;
//    matrix_float4x4 projection = {
//        {1, 0, 0, 0},
//        {0, 1, 0, 0},
//        {0, 0, 1, 0},
//        {0, 0, 0, 1}
//    };
//    
//    matrix_float4x4 modelView = {
//        {1.0/halfWidth, 0, 0, 0},
//        {0, -1/halfHeight, 0, 0},
//        {0, 0, 1, 0},
//        {-1, 1, 0, 1}
//    };
//    out.position.xy = (projection * modelView * vector_float4(pixelSpacePosition, 0, 1)).xy;
    out.position.xy = pixelSpacePosition;
    /// migration

    // Pass the input textureCoordinate straight to the output RasterizerData. This value will be
    //   interpolated with the other textureCoordinate values in the vertices that make up the
    //   triangle.
    out.textureCoordinate = vertices[vertexID].textureCoordinate;

    return out;
}

fragment float4 normal_fragment(RasterizerData in [[stage_in]],
                                texture2d<half> colorTexture [[ texture(FreeDrawTextureIndexBaseColor) ]])
{
//    gl_FragColor = texture2d(Sampler0, TextureCoordOut);
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    // Sample the texture to obtain a color
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    return float4(colorSample);
}
