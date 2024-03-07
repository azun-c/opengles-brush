//
//  FreeDrawShaderTypes.h
//  i-Reporter
//
//  Created by azun on 19/01/2024.
//  Copyright (c) 2024 CIMTOPS CORPORATION. All rights reserved.
//

#ifndef FreeDrawShaderTypes_h
#define FreeDrawShaderTypes_h

#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs
// match Metal API buffer set calls.
typedef enum FreeDrawVertexInputIndex
{
    FreeDrawVertexInputIndexVertices    = 0,
    FreeDrawVertexInputIndexDrawColor   = 1,
} FreeDrawVertexInputIndex;

typedef enum FreeDrawTextureInputIndex
{
    FreeDrawTextureInputIndexColor = 0
} FreeDrawTextureInputIndex;

typedef enum FreeDrawSamplerInputIndex
{
    FreeDrawSamplerInputIndexSampler = 0
} FreeDrawSamplerInputIndex;


//  This structure defines the layout of vertices sent to the vertex
//  shader. This header is shared between the .metal shader and C code, to guarantee that
//  the layout of the vertex array in the C code matches the layout that the .metal
//  vertex shader expects.
typedef struct
{
    // Positions in clip space
    vector_float2 position;
    
    // 2D texture coordinate
    vector_float2 texcoord;
} FreeDrawTextureVertex;

#endif /* FreeDrawShaderTypes_h */
