//
//  DraggableView.h
//  i-Reporter
//
//  Created by 高津 洋一 on 13/01/07.
//  Copyright (c) 2013 CIMTOPS CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DraggableView;

NS_ASSUME_NONNULL_BEGIN

@protocol DraggableViewDelegate <NSObject>

@optional
- (void)draggableViewBeginMoving:(DraggableView *)dragView;
- (void)draggableViewMoving:(DraggableView *)dragView;
- (void)draggableViewEndMoving:(DraggableView *)dragView;

@end

@interface DraggableView : UIView

@property (nonatomic, assign) CGPoint prevPoint;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, weak) id<DraggableViewDelegate> delegate;

@end
NS_ASSUME_NONNULL_END
