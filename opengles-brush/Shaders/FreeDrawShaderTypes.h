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
    FreeDrawVertexInputIndexVertices     = 0,
    FreeDrawVertexInputIndexViewportSize = 1,
} FreeDrawVertexInputIndex;

typedef enum FreeDrawTextureIndex
{
    FreeDrawTextureIndexBaseColor = 0,
} FreeDrawTextureIndex;

//  This structure defines the layout of vertices sent to the vertex
//  shader. This header is shared between the .metal shader and C code, to guarantee that
//  the layout of the vertex array in the C code matches the layout that the .metal
//  vertex shader expects.
typedef struct
{
    // Positions in pixel space. A value of 100 indicates 100 pixels from the origin/center.
    vector_float2 position;
    
    // 2D texture coordinate
    vector_float2 textureCoordinate;
} FreeDrawVertex;

#endif /* FreeDrawShaderTypes_h */
