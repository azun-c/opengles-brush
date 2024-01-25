//
//  IFreeDrawViewState.h
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/29.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FreeDrawViewStateType) {
    FreeDrawViewStateTypeSelection = 0,
    FreeDrawViewStateTypePen,
    FreeDrawViewStateTypeFluorescencePen,
    FreeDrawViewStateTypeFigureEllipse,
    FreeDrawViewStateTypeFigureBox,
    FreeDrawViewStateTypeFigureTriangle,
    FreeDrawViewStateTypeFigureCross,
    FreeDrawViewStateTypeFigureLeftArrow,
    FreeDrawViewStateTypeFigureRightArrow,
    FreeDrawViewStateTypeFigureDownArrow,
    FreeDrawViewStateTypeFigureUpArrow,
    FreeDrawViewStateTypeLine,
    FreeDrawViewStateTypeArrow,
    FreeDrawViewStateTypeBothArrow,
    FreeDrawViewStateTypeCircleNumber,
    FreeDrawViewStateTypeView,
    FreeDrawViewStateTypeDimensionLine,
    FreeDrawViewStateTypeDimensionArrow,
    FreeDrawViewStateTypeDimensionBothArrow,
    FreeDrawViewStateTypeDimensionCircle,
    FreeDrawViewStateTypeUnknown
};

@class FreeDrawView;

NS_ASSUME_NONNULL_BEGIN

@interface IFreeDrawViewState : NSObject 

@property (nonatomic, weak) FreeDrawView *view;
@property (nonatomic, weak) UIViewController *viewController;

- (void)onBeginState;
- (void)onEndState;
- (void)onRender;
- (void)onDidShowKeyboard;
- (void)onWillHideKeyboard;
- (void)onDidHideKeyboard;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)doubleTapped:(CGPoint)point;
- (void)endEditingText;
- (FreeDrawViewStateType)stateType;

@end
NS_ASSUME_NONNULL_END
