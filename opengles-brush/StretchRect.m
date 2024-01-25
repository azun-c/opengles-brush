//
//  StretchRect.m
//  i-Reporter
//
//  Created by doi on 2012/11/28.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "StretchRect.h"
#import<QuartzCore/QuartzCore.h>

static const float CORNER_WIDTH = 30.0;
static const float EDGE_WIDTH = 20.0;// エッジの選択矩形の幅
static const float INNER_PADDING = 10.0;// 矩形の内側へのパディング
static float OUTER_WIDTH = CORNER_WIDTH - INNER_PADDING;//矩形の外側
static const float MINIMUM_WIDTH =30.0;//CORNER_WIDTH*2.0 -> TODO:30.0

@interface StretchRect ()
@property (nonatomic, assign) DragState dragState;
@property (nonatomic, assign) CGPoint priorPoint;// rotationの時はtouchesBeganの点のまま
@property (nonatomic, assign) CGPoint currentRotationPoint;// used for rotation
@property (nonatomic, assign) CGPoint priorRotationPoint;
@property (nonatomic, assign) CGRect priorFrame;
@property (nonatomic, assign) CGRect priorDisplayRect;
@property (nonatomic, assign) BOOL isRotatable;
@property (nonatomic, assign) BOOL isMoving;
@end

NS_ASSUME_NONNULL_BEGIN

@implementation StretchRect

+ (CGRect)viewFrameFromDisplayFrame:(CGRect)frame {
    // 対角線
    float diagonal = sqrt(frame.size.height * frame.size.height + frame.size.width*frame.size.width);
    
    // LEFT_EDGE/RIGHT_EDGEの横にROTATION用のタッチスペースを考慮する
    float longestWidth = MAX(frame.size.height, frame.size.width) + CORNER_WIDTH * 4 - INNER_PADDING * 2;
    
    float width = MAX(diagonal,longestWidth);
    
    return CGRectMake(frame.origin.x - (width - frame.size.width)/2.0 , frame.origin.y - (width - frame.size.height)/2.0, width, width);
}

- (CGRect)displayRectFromViewFrame:(CGSize)displayRectSize {
    return CGRectMake((self.frame.size.width - displayRectSize.width)/2.0, (self.frame.size.height - displayRectSize.height)/2.0, displayRectSize.width, displayRectSize.height);
}

- (id)initWithDisplayRect:(CGRect)theDisplayRect rotatable:(BOOL)rotatable{
    CGRect viewFrame = [StretchRect viewFrameFromDisplayFrame:theDisplayRect];
    
    self = [super initWithFrame:viewFrame];
    if (self) {
        _displayRect = [self displayRectFromViewFrame:theDisplayRect.size];
        self.backgroundColor = [UIColor clearColor];
        _isRotatable = rotatable;
        
        self.delegate = nil;
        
        self.lineColor = [UIColor grayColor];
        _isMoving = NO;
    }
    return self;
}

- (float)getRotationAngle {
    if (_dragState != ROTATION_LEFT && _dragState != ROTATION_RIGHT) {
        return 0.0f;
    }

    NSLog(@"prior = %@", NSStringFromCGPoint(_priorPoint));
    NSLog(@"current = %@", NSStringFromCGPoint(_currentRotationPoint));
    
    CGPoint origin = self.frame.origin;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGPoint point0 = CGPointMake(_priorPoint.x - origin.x, _priorPoint.y - origin.y);
    CGPoint point1 = CGPointMake(_currentRotationPoint.x - origin.x, _currentRotationPoint.y - origin.y);

    CGPoint vec0 = CGPointMake(point0.x - center.x, point0.y - center.y);
    float len_vec0 = sqrt(vec0.x*vec0.x + vec0.y*vec0.y);
    CGPoint vec1 = CGPointMake(point1.x - center.x, point1.y - center.y);
    float len_vec1 = sqrt(vec1.x*vec1.x + vec1.y*vec1.y);
    
    float sin = (vec0.x*vec1.y - vec0.y*vec1.x)/(len_vec0*len_vec1);
    float cos = (vec0.x*vec1.x + vec0.y*vec1.y)/(len_vec0*len_vec1);
  
    return atan2(sin, cos);
}

- (CGRect)displayRectInSuperView {
    return CGRectMake(self.frame.origin.x + _displayRect.origin.x, self.frame.origin.y + _displayRect.origin.y, _displayRect.size.width, _displayRect.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    // 無視するジェスチャーを無効にしておく
    for (UIGestureRecognizer *gesture in self.ignoreGestures) {
        gesture.enabled = NO;
    }
    
    // 状態判定
    _isMoving = NO;
	CGPoint location = [[touches anyObject] locationInView:self];
    [self calcState:location];
    
    // 座標は親のビューの位置で覚えないと動かしてるビューが振動する。
    _priorPoint = [[touches anyObject] locationInView:self.superview];
    _priorRotationPoint = _priorPoint;
    _priorFrame = self.frame;
    _priorDisplayRect = [self displayRectInSuperView];
    
    // デリゲートに通知
    if ([self.delegate respondsToSelector:@selector(stretchRectBeginChanging:)]) {
        [self.delegate stretchRectBeginChanging:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    _isMoving = YES;
	CGPoint location = [[touches anyObject] locationInView:self.superview];
    [self updateWithLastPoint:location];
    // 親ビューからはみ出さないように
    [self containedInSuperView];
    
    [self setNeedsDisplay];
    
    // 回転以外
    if (_dragState != ROTATION_LEFT && _dragState != ROTATION_RIGHT) {
        _priorPoint = location;
        _priorFrame = self.frame;
        _priorDisplayRect = [self displayRectInSuperView];
    
    // 回転
    } else {
        _priorRotationPoint = _currentRotationPoint;
    }
    
    // デリゲートに通知
    if ([self.delegate respondsToSelector:@selector(stretchRectChanging:)]) {
        [self.delegate stretchRectChanging:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    // 無視していたジェスチャーを有効に戻しておく
    for (UIGestureRecognizer *gesture in self.ignoreGestures) {
        gesture.enabled = YES;
    }
    
    if (_dragState == INITIAL_STATE || _dragState == DRAG_STATE_MAX) {
        [self.nextResponder touchesEnded:touches withEvent:event];
        return;
    }
    _dragState = INITIAL_STATE;
    [self setNeedsDisplay];
    
    // タップの時
    if (!_isMoving) {
        [self handleTap:[touches anyObject]];
    } else {
        // デリゲートに通知
        if ([self.delegate respondsToSelector:@selector(stretchRectEndChanging:)]) {
            [self.delegate stretchRectEndChanging:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    // 無視していたジェスチャーを有効に戻しておく
    for (UIGestureRecognizer *gesture in self.ignoreGestures) {
        gesture.enabled = YES;
    }
    
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)drawRect:(CGRect)theRect {
    NSArray *points =
            @[[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.displayRect), CGRectGetMinY(self.displayRect))],
             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.displayRect), CGRectGetMinY(self.displayRect))],
             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.displayRect), CGRectGetMaxY(self.displayRect))],
             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.displayRect), CGRectGetMaxY(self.displayRect))]];
    
    NSArray *rotationPoints = nil;
    if (_isRotatable) {
        CGRect leftRect = [self rectForState:ROTATION_LEFT];
        CGPoint leftCenter = CGPointMake(CGRectGetMidX(leftRect), CGRectGetMidY(leftRect));
        CGRect rightRect = [self rectForState:ROTATION_RIGHT];
        CGPoint rightCenter = CGPointMake(CGRectGetMidX(rightRect), CGRectGetMidY(rightRect));
        rotationPoints = @[[NSValue valueWithCGPoint:leftCenter], [NSValue valueWithCGPoint:rightCenter]];
    }
    
    if (_dragState == ROTATION_LEFT || _dragState == ROTATION_RIGHT) {
        // self.viewの座標系で計算
        CGPoint origin = self.frame.origin;
        CGPoint point0 = CGPointMake(_priorPoint.x - origin.x, _priorPoint.y - origin.y);
        CGPoint point1 = CGPointMake(_currentRotationPoint.x - origin.x, _currentRotationPoint.y - origin.y);
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        points = [StretchRect rotatePoints:points
                                    point0:point0
                                    point1:point1
                                    center:center];
        if (rotationPoints) {
            rotationPoints = [StretchRect rotatePoints:rotationPoints
                                                point0:point0
                                                point1:point1
                                                center:center];
        }
    }
    
    [self drawWithPoints:points];
    
    if (rotationPoints) {
        [self drawCircles:rotationPoints];
    }
}

// 親ビューからはみ出さないように
- (void)containedInSuperView {
    NSArray *points =
    @[[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.displayRect), CGRectGetMinY(self.displayRect))],
     [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.displayRect), CGRectGetMinY(self.displayRect))],
     [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.displayRect), CGRectGetMaxY(self.displayRect))],
     [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.displayRect), CGRectGetMaxY(self.displayRect))]];
    
    if (_dragState == ROTATION_LEFT || _dragState == ROTATION_RIGHT) {
        // self.viewの座標系で計算
        CGPoint origin = self.frame.origin;
        CGPoint point0 = CGPointMake(_priorPoint.x - origin.x, _priorPoint.y - origin.y);
        CGPoint point1 = CGPointMake(_currentRotationPoint.x - origin.x, _currentRotationPoint.y - origin.y);
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        points = [StretchRect rotatePoints:points
                                    point0:point0
                                    point1:point1
                                    center:center];
    }
    
    for (NSValue *value in points) {
        CGPoint point = [self.superview convertPoint:[value CGPointValue] fromView:self];
        if (!CGRectContainsPoint(self.superview.bounds, point)) {
            float minX = CGRectGetMinX(self.superview.bounds);
            float maxX = CGRectGetMaxX(self.superview.bounds);
            float minY = CGRectGetMinY(self.superview.bounds);
            float maxY = CGRectGetMaxY(self.superview.bounds);
            CGRect newRect = [self displayRectInSuperView];
            
            // 回転の時
            if (_dragState == ROTATION_LEFT || _dragState == ROTATION_RIGHT) {
                _currentRotationPoint = _priorRotationPoint;
                break;
            
            // それ以外は、全点チェックする
            } else {
                if (point.x < minX) {
                    newRect.size.width = _priorDisplayRect.size.width;
                    newRect.origin.x = minX;
                }
                if (maxX < point.x) {
                    newRect.size.width = _priorDisplayRect.size.width;
                    newRect.origin.x = maxX - newRect.size.width;
                }
                if (point.y < minY) {
                    newRect.size.height = _priorDisplayRect.size.height;
                    newRect.origin.y = minY;
                }
                if (maxY < point.y) {
                    newRect.size.height = _priorDisplayRect.size.height;
                    newRect.origin.y = maxY - newRect.size.height;
                }

                self.frame = [StretchRect viewFrameFromDisplayFrame:newRect];
                _displayRect = [self displayRectFromViewFrame:newRect.size];
            }
        }
    }
}

- (void)updateWithLastPoint:(CGPoint)lastPoint {
    CGRect theFrame = _priorFrame;
    CGRect theRect = _priorDisplayRect;
    float vecX = lastPoint.x - _priorPoint.x;
    float vecY = lastPoint.y - _priorPoint.y;
    
    switch (_dragState) {
        case TOP_LEFT_CORNER: {
            float newWidth = theRect.size.width - vecX;
            float newHeight = theRect.size.height - vecY;
            float ratio = MIN(newWidth/theRect.size.width, newHeight/theRect.size.height);
            newWidth = ratio * theRect.size.width;
            newHeight = ratio * theRect.size.height;
            vecX = theRect.size.width - newWidth;
            vecY = theRect.size.height - newHeight;
            
            if (MINIMUM_WIDTH <= newWidth && MINIMUM_WIDTH <= newHeight) {
                theRect.size.width = newWidth;
                theRect.origin.x += vecX;
                
                theRect.size.height = newHeight;
                theRect.origin.y += vecY;
            }
            break;
        }
        case TOP_EDGE: {
            float newHeight = theRect.size.height - vecY;
            if (MINIMUM_WIDTH <= newHeight) {
                theRect.size.height = newHeight;
                theRect.origin.y += vecY;
            }
            break;
        }
        case TOP_RIGHT_CORNER: {
            float newWidth = theRect.size.width + vecX;
            float newHeight = theRect.size.height - vecY;
            float ratio = MIN(newWidth/theRect.size.width, newHeight/theRect.size.height);
            newWidth = ratio * theRect.size.width;
            newHeight = ratio * theRect.size.height;
            vecY = theRect.size.height - newHeight;
            
            if (MINIMUM_WIDTH <= newWidth && MINIMUM_WIDTH <= newHeight) {
                theRect.size.width = newWidth;
                
                theRect.size.height = newHeight;
                theRect.origin.y += vecY;
            }
            break;
        }
        case LEFT_EDGE: {
            float newWidth = theRect.size.width - vecX;
            if (MINIMUM_WIDTH <= newWidth) {
                theRect.size.width = newWidth;
                theRect.origin.x += vecX;
            }
            break;
        }
        case INNER_SIDE:
            theFrame.origin.x += vecX;
            theFrame.origin.y += vecY;
            self.frame = theFrame;
            return;
            break;
        case RIGHT_EDGE: {
            float newWidth = theRect.size.width + vecX;
            if (MINIMUM_WIDTH <= newWidth) {
                theRect.size.width = newWidth;
            }
            break;
        }
        case BOTTOM_LEFT_CORNER: {
            float newWidth = theRect.size.width - vecX;
            float newHeight = theRect.size.height + vecY;
            float ratio = MIN(newWidth/theRect.size.width, newHeight/theRect.size.height);
            newWidth = ratio * theRect.size.width;
            newHeight = ratio * theRect.size.height;
            vecX = theRect.size.width - newWidth;
            
            if (MINIMUM_WIDTH <= newWidth && MINIMUM_WIDTH <= newHeight) {
                theRect.size.width = newWidth;
                theRect.origin.x += vecX;
                
                theRect.size.height = newHeight;
            }
            break;
        }
        case BOTTOM_EDEG: {
            float newHeight = theRect.size.height + vecY;
            if (MINIMUM_WIDTH <= newHeight) {
                theRect.size.height = newHeight;
            }
            break;
        }
        case BOTTOM_RIGHT_CORNER: {
            float newWidth = theRect.size.width + vecX;
            float newHeight = theRect.size.height + vecY;
            float ratio = MIN(newWidth/theRect.size.width, newHeight/theRect.size.height);
            newWidth = ratio * theRect.size.width;
            newHeight = ratio * theRect.size.height;
            
            if (MINIMUM_WIDTH <= newWidth && MINIMUM_WIDTH <= newHeight) {
                theRect.size.width = newWidth;
                theRect.size.height = newHeight;
            }
            break;
        }
        case ROTATION_LEFT:
        case ROTATION_RIGHT:
            _currentRotationPoint = lastPoint;
            break;
        default:
            break;
    }
    
    self.frame = [StretchRect viewFrameFromDisplayFrame:theRect];
    _displayRect = [self displayRectFromViewFrame:theRect.size];
}

- (CGRect)rectForState:(DragState)state {
    switch (state) {
        case TOP_LEFT_CORNER:
            return CGRectMake(self.displayRect.origin.x - OUTER_WIDTH, self.displayRect.origin.y - OUTER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
            break;
        case TOP_EDGE:
            return CGRectMake(self.displayRect.origin.x + self.displayRect.size.width/2.0 - EDGE_WIDTH/2.0, self.displayRect.origin.y - OUTER_WIDTH, EDGE_WIDTH, CORNER_WIDTH);
            break;
        case TOP_RIGHT_CORNER:
            return CGRectMake(self.displayRect.origin.x + self.displayRect.size.width - INNER_PADDING, self.displayRect.origin.y - OUTER_WIDTH, CORNER_WIDTH, CORNER_WIDTH);
            break;
        case LEFT_EDGE:
            return CGRectMake(self.displayRect.origin.x - OUTER_WIDTH, self.displayRect.origin.y + self.displayRect.size.height/2.0 - EDGE_WIDTH/2.0, CORNER_WIDTH, EDGE_WIDTH);
            break;
        case INNER_SIDE:
            return self.displayRect;
            break;
        case RIGHT_EDGE:
            return CGRectMake(self.displayRect.origin.x + self.displayRect.size.width - INNER_PADDING, self.displayRect.origin.y + self.displayRect.size.height/2.0 - EDGE_WIDTH/2.0, CORNER_WIDTH, EDGE_WIDTH);
            break;
        case BOTTOM_LEFT_CORNER:
            return CGRectMake(self.displayRect.origin.x - OUTER_WIDTH, self.displayRect.origin.y + self.displayRect.size.height - INNER_PADDING, CORNER_WIDTH, CORNER_WIDTH);
            break;
        case BOTTOM_EDEG:
            return CGRectMake(self.displayRect.origin.x + self.displayRect.size.width/2.0 - EDGE_WIDTH/2.0, self.displayRect.origin.y + self.displayRect.size.height - INNER_PADDING, EDGE_WIDTH, CORNER_WIDTH);
            break;
        case BOTTOM_RIGHT_CORNER:
            return CGRectMake(self.displayRect.origin.x + self.displayRect.size.width - INNER_PADDING, self.displayRect.origin.y + self.displayRect.size.height - INNER_PADDING, CORNER_WIDTH, CORNER_WIDTH);
            break;
        case ROTATION_LEFT:
            return CGRectMake(self.displayRect.origin.x - CORNER_WIDTH - OUTER_WIDTH, self.displayRect.origin.y + self.displayRect.size.height/2.0 - CORNER_WIDTH/2.0, CORNER_WIDTH, CORNER_WIDTH);
            break;
        case ROTATION_RIGHT:
            return CGRectMake(self.displayRect.origin.x + self.displayRect.size.width + OUTER_WIDTH, self.displayRect.origin.y + self.displayRect.size.height/2.0 - CORNER_WIDTH/2.0, CORNER_WIDTH, CORNER_WIDTH);
            break;
        default:
            return CGRectZero;
            break;
    }
}

- (void)calcState:(CGPoint)point {
    _dragState = INITIAL_STATE;
    int stateMax = _isRotatable ? DRAG_STATE_MAX:ROTATION_RIGHT;
    for (int i = TOP_LEFT_CORNER; i < stateMax; i++) {
        if (CGRectContainsPoint([self rectForState:i], point)) {
            _dragState = i;
            break;
        }
    }
}

- (void)drawWithPoints:(NSArray<NSValue *> *)points {
	//コンテキストとか準備
    const float lineWidth = 5.0;
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
	CGContextSetLineWidth(context, lineWidth);
    const CGFloat dashStyle[] = {4.0};
    CGContextSetLineDash(context, 0.0, dashStyle, 1);
    
	[_lineColor setStroke];
	
	//このあたりはCGPathでも同じことができる
	CGContextBeginPath(context);
	//描画していくよ
	int i=0;
	for (NSValue *value in points) {
		CGPoint point = [value CGPointValue];
		if (i == 0) {
			CGContextMoveToPoint(context, point.x, point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, point.y);
		}
		i++;
	}
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
	CGContextSetLineWidth(context, lineWidth);
	[_lineColor setStroke];
	[_lineColor setFill];
    for (i = 0; i < points.count; i++) {
        CGPoint point0 = points[i].CGPointValue;
        int next = (i == points.count - 1) ? 0:i+1;
        CGPoint point1 = points[next].CGPointValue;
        CGContextAddArc(context, point0.x, point0.y, lineWidth, 0.0, 2.0*M_PI, 0);
        CGContextFillPath(context);
        CGContextDrawPath(context, kCGPathStroke);
        
        CGContextAddArc(context, (point0.x + point1.x)/2.0, (point0.y + point1.y)/2.0, lineWidth, 0.0, 2.0*M_PI, 0);
        CGContextFillPath(context);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    CGContextRestoreGState(context);
}

- (void)drawCircles:(NSArray<NSValue *> *)points {
    const float lineWidth = 3.0;
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
	CGContextSetLineWidth(context, lineWidth);
	[_lineColor setStroke];

	for (NSValue *value in points) {
		CGPoint point = [value CGPointValue];
        CGContextAddArc(context, point.x, point.y, lineWidth*2.0, 0.0, 2.0*M_PI, 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    CGContextRestoreGState(context);
}

- (void)handleTap:(UITouch *)touch {
    CGPoint tapPoint = [touch locationInView:self];
    if (!CGRectContainsPoint(_displayRect, tapPoint)) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(tapInRect:atPointInRect:)]) {
        [self.delegate tapInRect:self atPointInRect:tapPoint];
    }
}

+ (NSArray<NSValue *> *)rotatePoints:(NSArray<NSValue *> *)points point0:(CGPoint)point0 point1:(CGPoint)point1 center:(CGPoint)center {
    CGPoint vec0 = CGPointMake(point0.x - center.x, point0.y - center.y);
    float len_vec0 = sqrt(vec0.x*vec0.x + vec0.y*vec0.y);
    CGPoint vec1 = CGPointMake(point1.x - center.x, point1.y - center.y);
    float len_vec1 = sqrt(vec1.x*vec1.x + vec1.y*vec1.y);
    
    float sin = (vec0.x*vec1.y - vec0.y*vec1.x)/(len_vec0*len_vec1);
    float cos = (vec0.x*vec1.x + vec0.y*vec1.y)/(len_vec0*len_vec1);
    
    NSMutableArray *result = @[].mutableCopy;
    for (NSValue *value in points) {
        CGPoint valuePoint = [value CGPointValue];
        // centerを中心に回転
        CGPoint rotatedValue = [StretchRect rotatePoint:CGPointMake(valuePoint.x - center.x, valuePoint.y - center.y) sin:sin cos:cos];
        // center分移動
        [result addObject:[NSValue valueWithCGPoint:CGPointMake(rotatedValue.x + center.x, rotatedValue.y + center.y)]];
    }
    return result;
}

+ (CGPoint)rotatePoint:(CGPoint)point sin:(float)sin cos:(float)cos {
    return CGPointMake(point.x * cos - point.y * sin,
                       point.x * sin + point.y * cos);
}

@end
NS_ASSUME_NONNULL_END
