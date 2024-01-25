//
//  IFreeDrawOperation.h
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/21.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFreeDrawOperation : NSObject 

- (IFreeDrawOperation *)oppositeOperation;
- (void)execute;

@end
NS_ASSUME_NONNULL_END
