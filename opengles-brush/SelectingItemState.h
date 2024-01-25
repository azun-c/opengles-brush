//
//  SelectingItemState.h
//  i-Reporter
//
//  Created by 高津 洋一 on 13/01/12.
//  Copyright (c) 2013 CIMTOPS CORPORATION. All rights reserved.
//

#import "IFreeDrawViewState.h"
#import "IDrawItem.h"
#import "StretchRect.h"
#import "DraggableView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SelectingItemState : IFreeDrawViewState<StretchRectDelegate,DraggableViewDelegate>

@property (nonatomic, strong) NSArray<__kindof IDrawItem *> *selectingItems; // 選択要素
@property (nonatomic, strong) IFreeDrawViewState * __nullable backState;

- (void)clearSelecting;
- (CGPoint)getCenterOfItems;

@end
NS_ASSUME_NONNULL_END
