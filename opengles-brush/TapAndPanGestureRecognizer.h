//
//  TapAndPanGestureRecognizer.h
//  i-Reporter
//
//  Created by 高津 洋一 on 2015/09/28.
//  Copyright (c) 2015 CIMTOPS CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapAndPanGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) CGPoint translation;

@end
NS_ASSUME_NONNULL_END
