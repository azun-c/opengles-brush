//
//  IFreeDrawOperation.m
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/21.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "IFreeDrawOperation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation IFreeDrawOperation

- (IFreeDrawOperation *)oppositeOperation {
    // 要オーバーライド
    assert(NO);
    return nil;
}

- (void)execute {
    // 要オーバーライド
    assert(NO);
}

@end
NS_ASSUME_NONNULL_END
