//
//  VertexObj.h
//  i-Reporter
//
//  Created by azun on 17/01/2024.
//  Copyright (c) 2024 CIMTOPS CORPORATION. All rights reserved.
//

#import "FreeDrawShaderTypes.h"

#ifndef VertexObj_h
#define VertexObj_h

@interface VertexObj: NSObject
/// Stores the X coordinate of a vertex.
@property (nonatomic, assign) GLfloat x;
/// Stores the Y coordinate of a vertex.
@property (nonatomic, assign) GLfloat y;

@property (nonatomic, assign) GLfloat texPosX;
@property (nonatomic, assign) GLfloat texPosY;

- (FreeDrawTextureVertex)asFreeDrawVertex;
@end

#endif /* VertexObj_h */
