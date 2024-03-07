//
//  VertexObj.m
//  i-Reporter
//
//  Created by azun on 17/01/2024.
//  Copyright (c) 2024 CIMTOPS CORPORATION. All rights reserved.
//

#import "VertexObj.h"
#import "FreeDrawShaderTypes.h"
#include <simd/simd.h>

@implementation VertexObj
- (FreeDrawTextureVertex)asFreeDrawVertex {
    FreeDrawTextureVertex v;
    v.position = simd_make_float2(self.x, self.y);
    v.texcoord = simd_make_float2(self.texPosX, self.texPosY);
    return v;
}
@end
