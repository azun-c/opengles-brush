//
//  RemoveItemOpe.m
//  i-Reporter
//
//  Created by 高津 洋一 on 13/02/07.
//  Copyright (c) 2013 CIMTOPS CORPORATION. All rights reserved.
//

#import "RemoveItemOpe.h"
#import "InsertItemOpe.h"

NS_ASSUME_NONNULL_BEGIN

@interface RemoveItemOpe ()

@property (nonatomic, assign) NSUInteger removeIndex;
@property (nonatomic, strong) NSMutableArray<__kindof IDrawItem *> *drawItems;

@end

@implementation RemoveItemOpe

- (id)initWithItems:(NSMutableArray<__kindof IDrawItem *> *)items removeIndex:(NSUInteger)theRemoveIndex {
    if (self = [super init]) {
        self.drawItems = items;
        self.removeIndex = theRemoveIndex;
    }
    return self;
}

#pragma mark - IFreeDrawOperation
- (IFreeDrawOperation *)oppositeOperation {
    return [[InsertItemOpe alloc] initWithItems:self.drawItems insertItems:self.drawItems[self.removeIndex] insertIndex:self.removeIndex];
}

- (void)execute {
    [self.drawItems removeObjectAtIndex:self.removeIndex];
}

@end
NS_ASSUME_NONNULL_END
