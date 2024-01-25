//
//  FreeDrawViewingState.h
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/29.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "IFreeDrawViewState.h"

NS_ASSUME_NONNULL_BEGIN

@interface FreeDrawViewingState : IFreeDrawViewState 

@property (nonatomic, strong) IFreeDrawViewState *previousState;

@end
NS_ASSUME_NONNULL_END
