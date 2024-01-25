//
//  StretchRect.h
//  i-Reporter
//
//  Created by doi on 2012/11/28.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

// 1 - 2 - 3
// 4 - 5 - 6
// 7 - 8 - 9
typedef NS_ENUM(NSInteger, DragState) {
    INITIAL_STATE = 0,
    TOP_LEFT_CORNER,// self.rect.originを中心とした幅がCORNER_WIDTHの正方形
    TOP_EDGE,
    TOP_RIGHT_CORNER,
    LEFT_EDGE,
    RIGHT_EDGE,
    BOTTOM_LEFT_CORNER,
    BOTTOM_EDEG,
    BOTTOM_RIGHT_CORNER,
    INNER_SIDE,
    ROTATION_RIGHT,
    ROTATION_LEFT,
    DRAG_STATE_MAX
};

@class StretchRect;

NS_ASSUME_NONNULL_BEGIN

@protocol StretchRectDelegate <NSObject>

@optional
- (void)stretchRectBeginChanging:(StretchRect *)rect;
- (void)stretchRectChanging:(StretchRect *)rect;
- (void)stretchRectEndChanging:(StretchRect *)rect;
- (void)tapInRect:(StretchRect *)rect atPointInRect:(CGPoint)point;

@end

@interface StretchRect : UIView

@property (nonatomic, readonly) CGRect displayRect;// 表示矩形
@property (nonatomic, weak) id<StretchRectDelegate> delegate;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) NSArray<UIGestureRecognizer *> *ignoreGestures;

- (id)initWithDisplayRect:(CGRect)frame rotatable:(BOOL)rotatable;
- (float)getRotationAngle;

@end
NS_ASSUME_NONNULL_END
