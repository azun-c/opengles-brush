//
//  IFreeDrawViewState.m
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/29.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "IFreeDrawViewState.h"

NS_ASSUME_NONNULL_BEGIN

@implementation IFreeDrawViewState

- (void)onBeginState {
}

- (void)onEndState {
}

- (void)onRender {    
}

- (void)onDidShowKeyboard {
}

- (void)onWillHideKeyboard {
}

- (void)onDidHideKeyboard {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)doubleTapped:(CGPoint)point {
}

- (void)endEditingText {
}

- (FreeDrawViewStateType)stateType {
    return FreeDrawViewStateTypeUnknown;
}

@end
NS_ASSUME_NONNULL_END
