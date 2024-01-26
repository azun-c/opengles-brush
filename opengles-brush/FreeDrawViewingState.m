//
//  FreeDrawViewingState.m
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/29.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "FreeDrawViewingState.h"
#import "FreeDrawView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FreeDrawViewingState ()


@end

@implementation FreeDrawViewingState

- (void)dealloc {
}

- (void)onBeginState {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view.nextResponder touchesEnded:touches withEvent:event];
}

@end
NS_ASSUME_NONNULL_END
