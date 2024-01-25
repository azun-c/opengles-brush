//
//  FreeDrawViewingState.m
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/29.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "FreeDrawViewingState.h"
#import "FreeDrawView.h"
#import "TapAndPanGestureRecognizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface FreeDrawViewingState ()

@property (nonatomic, strong) TapAndPanGestureRecognizer *tapPanRecognizer;

@end

@implementation FreeDrawViewingState

- (id)init {
    if (self = [super init]) {
        self.tapPanRecognizer = [[TapAndPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPan:)];
    }
    return self;
}

- (void)dealloc {
}

- (void)onBeginState {
//    [self.viewController changeUIForViewMode];
    [self.view addGestureRecognizer:self.tapPanRecognizer];
}

- (void)onEndState {
//    [self.viewController changeUIForEditMode];
    [self.view removeGestureRecognizer:self.tapPanRecognizer];
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

- (FreeDrawViewStateType)stateType {
    return FreeDrawViewStateTypeView;
}

- (void)handleTapPan:(TapAndPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
            break;
        default:
//            if (recognizer.translation.y < 0) {
//                self.viewController.scrollView.zoomScale *= 1.05;
//            } else {
//                self.viewController.scrollView.zoomScale /= 1.05;
//            }
            break;
    }
}

@end
NS_ASSUME_NONNULL_END
