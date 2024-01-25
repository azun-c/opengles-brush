//
//  FreeHandCurve.h
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/21.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "IDrawItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FreeHandCurve : IDrawItem 

@property (nonatomic, assign) int pointCount; // 点数
@property (nonatomic, assign) float lineWidth; // 線幅
@property (nonatomic, strong) NSData *pointsData; // float配列

- (id)initWithPoints:(int)count withData:(float *)pData;

@end
NS_ASSUME_NONNULL_END
