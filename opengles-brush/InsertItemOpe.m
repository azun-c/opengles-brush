//
//  InsertItemOpe.m
//  i-Reporter
//
//  Created by 高津 洋一 on 13/02/07.
//  Copyright (c) 2013 CIMTOPS CORPORATION. All rights reserved.
//

#import "InsertItemOpe.h"
#import "RemoveItemOpe.h"

NS_ASSUME_NONNULL_BEGIN

@interface InsertItemOpe ()

@property (nonatomic, strong) IDrawItem *insertItem;
@property (nonatomic, assign) NSUInteger insertIndex;
@property (nonatomic, strong) NSMutableArray<__kindof IDrawItem *> *drawItems;

@end

@implementation InsertItemOpe

@synthesize insertItem;
@synthesize insertIndex;
@synthesize drawItems;

- (id)initWithItems:(NSMutableArray<__kindof IDrawItem *> *)items insertItems:(IDrawItem *)insert insertIndex:(NSUInteger)theInsertIndex {
    if (self = [super init]) {
        self.drawItems = items;
        self.insertItem = insert;
        self.insertIndex = theInsertIndex;
    }
    return self;
}

#pragma mark - IFreeDrawOperation
- (IFreeDrawOperation *)oppositeOperation {
    return [[RemoveItemOpe alloc] initWithItems:self.drawItems removeIndex:self.insertIndex];
}

- (void)execute {
    [self.drawItems insertObject:self.insertItem atIndex:self.insertIndex];
}

@end
NS_ASSUME_NONNULL_END
