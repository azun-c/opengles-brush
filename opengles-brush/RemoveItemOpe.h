//
//  RemoveItemOpe.h
//  i-Reporter
//
//  Created by 高津 洋一 on 13/02/07.
//  Copyright (c) 2013 CIMTOPS CORPORATION. All rights reserved.
//

#import "IFreeDrawOperation.h"
#import "IDrawItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface RemoveItemOpe : IFreeDrawOperation

- (id)initWithItems:(NSMutableArray<__kindof IDrawItem *> *)items removeIndex:(NSUInteger)theRemoveIndex;

@end
NS_ASSUME_NONNULL_END
