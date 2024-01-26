//
//  IFreeDrawViewState.h
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/29.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

@class FreeDrawView;

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewState : NSObject 

@property (nonatomic, weak) FreeDrawView *view;

- (void)onBeginState;
- (void)onRender;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
NS_ASSUME_NONNULL_END
