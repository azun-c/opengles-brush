//
//  SelectingItemState.m
//  i-Reporter
//
//  Created by 高津 洋一 on 13/01/12.
//  Copyright (c) 2013 CIMTOPS CORPORATION. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES3/gl.h>
#import "SelectingItemState.h"
#import "FreeDrawView.h"
//#import "FreeDrawViewController.h"
//#import "GLDebug.h"
#import "StretchRect.h"
#import "DraggableView.h"
#import "DirectTextItem.h"
//#import "CalloutItem.h"
//#import "DimensionLine.h"
//#import "EditingDirectTextState.h"
//#import "EditingCalloutState.h"
//#import "ReplaceItemOpe.h"
//#import "EditingDimensionState.h"
//#import "TapAndPanGestureRecognizer.h"
//#import "Log.h"
//#import "i_Reporter-Swift.h"

CGAffineTransform CalcTransform(CGRect prev, float prevAngle, CGRect toRect,float angle) {
    // 前の矩形中央からビュー原点への移動
    CGAffineTransform prevToViewOrigin = CGAffineTransformMakeTranslation(-CGRectGetMidX(prev), -CGRectGetMidY(prev));
    // スケーリング
    CGAffineTransform scale = CGAffineTransformMakeScale(toRect.size.width/prev.size.width, toRect.size.height/prev.size.height);
    // 回転
    CGAffineTransform rotate = CGAffineTransformMakeRotation(angle - prevAngle);
    // ビュー原点からの矩形中央への移動
    CGAffineTransform viewOriginToRect = CGAffineTransformMakeTranslation(CGRectGetMidX(toRect), CGRectGetMidY(toRect));
    CGAffineTransform result =  CGAffineTransformConcat(prevToViewOrigin, CGAffineTransformConcat(rotate, CGAffineTransformConcat(scale, viewOriginToRect)));
    return result;
}

NS_ASSUME_NONNULL_BEGIN

@interface SelectingItemState ()
@property (nonatomic, strong) StretchRect * __nullable selectingRect; // 選択矩形
@property (nonatomic, strong) DraggableView * __nullable draggableView; // アンカー位置変更ビュー
@property (nonatomic, assign) CGRect previousRect; // 矩形変更中 変更前の矩形
@property (nonatomic, assign) float previousAngle; // 矩形回転中 変更前の回転
@property (nonatomic, strong) UIView *pasteTargetView;
@property (nonatomic, strong) IDrawItem *editingItem;
@property (nonatomic, strong) NSArray<__kindof IDrawItem *> * __nullable copiedSelectingItems;
@property (nonatomic, strong) TapAndPanGestureRecognizer *tapPanRecognizer;

@end

@implementation SelectingItemState

- (id)init {
    if (self = [super init]) {
        self.selectingItems = @[];
        self.copiedSelectingItems = nil;
        self.backState = nil;
        self.tapPanRecognizer = [[TapAndPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPan:)];
    }
    return self;
}

- (void)onBeginState {
    [self selectObjects:self.selectingItems needPopover:YES];
    self.viewController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1; // 選択モードでは1本指でもパンできるように
    [self.view addGestureRecognizer:self.tapPanRecognizer];
}

- (void)onEndState {
    self.viewController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2; // 2本指でのパンに戻す
    // m_forMoveをクリア
    [self.view clearFrameBuffer:self.view.m_forMove.framebuffer withRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    // 再描画
    [self.view redraw:self.viewController.drawItems exceptFor:nil];
    
    // 後片付け
    if (_selectingRect) {
        [_selectingRect removeFromSuperview];
        self.selectingRect = nil;
    }
    
    if (_draggableView) {
        [_draggableView removeFromSuperview];
        self.draggableView = nil;
    }
    
    [self.view removeGestureRecognizer:self.tapPanRecognizer];
}

- (void)onRender {
    [self.view drawBegin];

    [self.view renderFinishedToOnScreen];
    // 前面描画
    [self.view useProgram:ProgramTypeNormalProgram];
    [self.view drawTexture:self.view.m_forMove.texture toFramebuffer:self.view.m_onScreen.framebuffer];
    
    [self.view drawEnd];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.viewController clearSelectPopover];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.backState) {
        [self.viewController setViewState:_backState];
        return;
    }
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    NSArray *selected = [self pickAt:point];
    
    [self selectObjects:selected needPopover:YES];
    
    return;
}

- (void)doubleTapped:(CGPoint)point {
    NSArray *selected = [self pickAt:point];
    // ダブルタップしたものが寸法線の場合テキスト編集へ
    if (selected.count != 1) {
        return;
    }
    
    IDrawItem *item = selected[0];
    if (![item isKindOfClass:DimensionLine.class]) {
        return;
    }

    [self editDimension:(DimensionLine *)item];
}

- (void)editDimension:(DimensionLine *)dimensionLine {
    EditingDimensionState *state = [[EditingDimensionState alloc] init];
    state.edit = YES;
    state.backState = self;
    state.dimensionLine = dimensionLine;
    [self.viewController setViewState:state];
}

- (FreeDrawViewStateType)stateType {
    return FreeDrawViewStateTypeSelection;
}

#pragma mark -
- (void)renderToForMoveSelecting:(NSArray<__kindof NSObject *> *)items {
    [self.view drawBegin];
    // m_forMoveをクリア
    [self.view clearFrameBuffer:self.view.m_forMove.framebuffer withRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    // 選択状態のアイテムを再描画
    for (IDrawItem *eachItem in items) {
        [eachItem acceptRendererForSelection:self.view];
    }
    [self.view drawEnd];
    // オフスクリーンをクリアしておく(viewのrenderOnScreenで影響が出るため)
    [self.view clearFrameBuffer:self.view.m_offScreen.framebuffer withRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
        
    [self.view drawView:nil];
}

- (NSArray<__kindof IDrawItem *> *)pickAt:(CGPoint)point {
    // 選択窓の幅/高さ
    static const int kSelectionMaxWidth = 20;
    static const int kSelectionMaxHeight = 20;
    
    NSMutableArray *selected = @[].mutableCopy;

    // ビュー外で離した場合は除外
    if (!CGRectContainsPoint(self.view.bounds, point)) {
        return selected;
    }
    
    GLsizei pixelWidth = self.view.bounds.size.width*self.view.contentScaleFactor;
    GLsizei pixelHeight = self.view.bounds.size.height*self.view.contentScaleFactor;
    
    GLint xOnFramebuffer = point.x *self.view.contentScaleFactor;
    GLint yOnFramebuffer = (self.view.bounds.size.height - point.y) * self.view.contentScaleFactor;
    glBindFramebuffer(GL_FRAMEBUFFER, self.view.m_forSelection.framebuffer);CHECK_GL_ERROR();
    
    GLint selectLeft = xOnFramebuffer - kSelectionMaxWidth/2;
    GLint selectDown = yOnFramebuffer - kSelectionMaxHeight/2;
    GLint selectRight = selectLeft + kSelectionMaxWidth - 1;
    GLint selectUp = selectDown + kSelectionMaxHeight - 1;
    if (selectLeft < 0) {
        selectLeft = 0;
    }
    if (selectDown < 0) {
        selectUp = 0;
    }
    if (selectRight >= pixelWidth) {
        selectRight = pixelWidth - 1;
    }
    if (selectUp >= pixelHeight) {
        selectDown = pixelHeight - 1;
    }
    
    int selectionWidth = selectRight - selectLeft + 1;
    int selectionHeight = selectUp - selectDown + 1;
    
    GLubyte *pixels = (GLubyte *)calloc(selectionWidth*selectionHeight*4, sizeof(GLubyte));
    
    glReadPixels(selectLeft, selectDown, selectionWidth, selectionHeight, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)pixels);CHECK_GL_ERROR();
    
    // タップ位置に近いものを選択
    double minDstSqr = DBL_MAX;
    IDrawItem *nearestItem = nil;
    int halfSelectionWidth = selectionWidth/2;
    int halfSelectionHeight = selectionHeight/2;
    
    IDrawItem *nearestSelected = nil;
    for (int i = 0; i < selectionHeight; ++i) {
        for (int j = 0; j < selectionWidth; ++j) {
            // タップ位置からの距離
            double dstSqr = (j - halfSelectionWidth)*(j - halfSelectionWidth) + (i - halfSelectionHeight)*(i - halfSelectionHeight);
            if (dstSqr >= minDstSqr) {
                continue;
            }
            
            GLubyte eachR = pixels[4 * (selectionWidth*i + j)];
            GLubyte eachG = pixels[4 * (selectionWidth*i + j) + 1];
            GLubyte eachB = pixels[4 * (selectionWidth*i + j) + 2];
            
            int index = (eachB << 16) | (eachG << 8) | eachR;
            
            if (index > 0 && index <= [self.view.delegate getDrawItems].count) {
                IDrawItem *item = [self.view.delegate getDrawItems][index - 1];
                // 選択済みのものはとりあえず別に記憶
                if ([self.selectingItems containsObject:item]) {
                    nearestSelected = item;
                    continue;
                }
                
                nearestItem = item;
                minDstSqr = dstSqr;
            } else {
                // 0は何もないところ
                if (index != 0) {
                    LogDebug(commonLogger, @"Indexがおかしい！！！！！！！！！！！！！！！！ touchesEnded index=%d", index);
                }
            }
        }
    }
    free(pixels);
    
    // 最も近いものを格納
    if (nearestItem) {
        [selected addObject:nearestItem];
    // 選択済みのものしかなければそれを格納
    } else if (nearestSelected) {
        [selected addObject:nearestSelected];
    }
    return selected;
}

- (void)selectObjects:(NSArray<__kindof IDrawItem *> *)selected needPopover:(BOOL)needPopover {
    // 選択矩形があれば削除
    if (self.selectingRect) {
        [self.selectingRect removeFromSuperview];
        self.selectingRect = nil;
    }
    // アンカーポイント
    if (self.draggableView) {
        [self.draggableView removeFromSuperview];
        self.draggableView = nil;
    }
    
    self.selectingItems = selected;
    
    // 選択されていないもので描画済み画面を再描画
    [self.view redraw:self.viewController.drawItems];
    
    // 選択矩形を作成
    if (self.selectingItems.count != 0) {
        // 選択矩形を先にaddSubviewする。そうしないとdraggableViewが選択矩形のビューと重なった時、draggableViewがドラッグできない。
        CGRect rect = CGRectNull;
        BOOL isRotatable = YES;
        for (IDrawItem *eachItem in self.selectingItems) {
            rect = CGRectUnion(rect, [eachItem boundingBox]);
            if (![eachItem isRotatable]) {
                isRotatable = NO;
            }
        }
        self.selectingRect = [[StretchRect alloc] initWithDisplayRect:rect rotatable:isRotatable];
        self.selectingRect.ignoreGestures = @[self.viewController.scrollView.panGestureRecognizer]; // 矩形操作中はスクロールビューの平行移動を無効にする
        self.selectingRect.lineColor = [UIColor greenColor];
        self.selectingRect.delegate = self;
        [self.view addSubview:self.selectingRect];
        
        for (IDrawItem *eachItem in self.selectingItems) {
            if ([eachItem isKindOfClass:CalloutItem.class]) {
                if (self.draggableView) {
                    [self.draggableView removeFromSuperview];
                    self.draggableView = nil;
                }
                
                CalloutItem *callOut = (CalloutItem *)eachItem;
                CGPoint anchorPoint = callOut.anchor;
                
                CGRect rect = CGRectMake(anchorPoint.x - 0.5*50, anchorPoint.y - 0.5*50, 50, 50);
                
                self.draggableView = [[DraggableView alloc] initWithFrame:rect];
                _draggableView.delegate = self;
                
                [self.view addSubview:_draggableView];
            }
        }
        
        if (needPopover) {
            NSMutableArray *views = @[self.view].mutableCopy;
            
            if (self.selectingRect) {
                [views addObject:self.selectingRect];
            }
            
            if (self.draggableView) {
                [views addObject:self.draggableView];
            }
            
            [self.viewController displaySelectPopover:self.selectingRect.displayRect
                                               inView:self.selectingRect
                                     passThroughViews:views.copy];
        }
    }
    [self renderToForMoveSelecting:self.selectingItems];
}

- (void)clearSelecting {
    // 選択矩形があれば削除
    if (self.selectingRect) {
        [self.selectingRect removeFromSuperview];
        self.selectingRect = nil;
    }
    // アンカーポイント
    if (self.draggableView) {
        [self.draggableView removeFromSuperview];
        self.draggableView = nil;
    }
    
    self.selectingItems = @[];
    self.copiedSelectingItems = nil;
}

- (CGPoint)getCenterOfItems {
    CGRect rectInView = [self.view convertRect:self.selectingRect.displayRect fromView:self.selectingRect];
    return CGPointMake(CGRectGetMidX(rectInView), CGRectGetMidY(rectInView));
}

- (void)handleTapPan:(TapAndPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
            break;
        default:
            if (recognizer.translation.y < 0) {
                self.viewController.scrollView.zoomScale *= 1.05;
            } else {
                self.viewController.scrollView.zoomScale /= 1.05;
            }
            break;
    }
}

#pragma mark - StretchRectDelegate
- (void)stretchRectBeginChanging:(StretchRect *)rect {
    [self.viewController clearSelectPopover];
    
    // 変更開始
    CGRect rectInView = [self.view convertRect:rect.displayRect fromView:rect];
    
    self.previousRect = rectInView;
    self.previousAngle = 0.0f;
    
    self.copiedSelectingItems = [[NSArray alloc] initWithArray:self.selectingItems copyItems:YES];
}

- (void)stretchRectChanging:(StretchRect *)rect {
    // 変更中
    CGRect rectInView = [self.view convertRect:rect.displayRect fromView:rect];
    float angle = [rect getRotationAngle];
    
    // 前回の状態からの変換を計算
    CGAffineTransform affine = CalcTransform(self.previousRect, self.previousAngle, rectInView, angle);
    
    // 変換を適用
    for (IDrawItem *eachItem in self.copiedSelectingItems) {
        [eachItem applyTransform:affine];
    }

    [self renderToForMoveSelecting:self.copiedSelectingItems];
    
    self.previousRect = rectInView;
    self.previousAngle = angle;
}

- (void)stretchRectEndChanging:(StretchRect *)rect {
    // 変更終了
    self.previousRect = CGRectNull;
    self.previousAngle = 0.0f;
    
    // 変換したcopiedItemsをselectingItemsと置き換え
    [self replaceSelectingToCopiedItems];
    
    // 矩形再描画のため再選択　異動後にポップオーバーはいらない（NoteAnytimeと同じ）
    [self selectObjects:_selectingItems needPopover:NO];
}

- (void)tapInRect:(StretchRect *)rect atPointInRect:(CGPoint)point {
    CGPoint pointInFreeDrawView = [self.view convertPoint:point fromView:rect];
    NSArray *picked = [self pickAt:pointInFreeDrawView];
    if (picked.count == 0) {
        return;
    }
    
    IDrawItem *pickedItem = picked[0];

    IDrawItem *selectingItem = _selectingItems[0];
    if (picked.count == 1 && selectingItem == pickedItem) {
        if ([selectingItem isKindOfClass:DirectTextItem.class]) {
            EditingDirectTextState *state = [[EditingDirectTextState alloc] init];
            state.editingItem = (DirectTextItem *)selectingItem;
            [self.viewController setViewState:state];
        } else if ([selectingItem isKindOfClass:CalloutItem.class]) {
            EditingCalloutState *state = [[EditingCalloutState alloc] init];
            state.editingItem = (CalloutItem *)selectingItem;
            [self.viewController setViewState:state];
        }
    } else {
        [self selectObjects:picked needPopover:YES];
    }
}

// 変換したcopiedItemsをselectingItemsと置き換え
- (void)replaceSelectingToCopiedItems {
    // undo/redo
    NSMutableArray *indexes = @[].mutableCopy;
    for (IDrawItem *item in self.selectingItems) {
        NSUInteger index = [[self.view.delegate getDrawItems] indexOfObject:item];
        [indexes addObject:@(index)];
    }
    ReplaceItemOpe *ope = [[ReplaceItemOpe alloc] initWithItems:[self.view.delegate getDrawItems]
                                                 replacingItems:self.copiedSelectingItems
                                                replacedIndexes:indexes];
    [self.viewController executeOperation:ope];
    self.selectingItems = self.copiedSelectingItems;
    self.copiedSelectingItems = nil;
}

#pragma mark - DraggableViewDelegate
- (void)draggableViewBeginMoving:(DraggableView *)dragView {
    // 親のスクロールビューをスクロール可能に戻す
    self.viewController.scrollView.scrollEnabled = NO;
    
    [self.viewController clearSelectPopover];
    self.copiedSelectingItems = [[NSArray alloc] initWithArray:self.selectingItems copyItems:YES];
}

- (void)draggableViewMoving:(DraggableView *)dragView {
    CalloutItem *item = nil;
    for (IDrawItem *eachSelected in self.copiedSelectingItems) {
        if ([eachSelected isKindOfClass:CalloutItem.class]) {
            item = (CalloutItem *)eachSelected;
            break;
        }
    }
    item.anchor = dragView.center;
    [self renderToForMoveSelecting:self.copiedSelectingItems];
}

- (void)draggableViewEndMoving:(DraggableView *)dragView {
    // 親のスクロールビューをスクロール可能に戻す
    self.viewController.scrollView.scrollEnabled = YES;
    // 変換したcopiedItemsをselectingItemsと置き換え
    [self replaceSelectingToCopiedItems];
    
    [self selectObjects:_selectingItems needPopover:NO];
}

@end
NS_ASSUME_NONNULL_END
