//
//  DrawingCurveState.m
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/29.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DrawingCurveState.h"
#import "FreeDrawView.h"
#import "Polyline.hpp"
#import "Triangles.hpp"
#import "VertexObj.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawingCurveState ()
// 描画折れ線
@property (nonatomic, assign) Polyline currentPolyline;
@end

@implementation DrawingCurveState

- (void)onBeginState {
    // アニメーションスタート
    [self.view startAnimation];
    _currentPolyline.m_points.reserve(1000);
}

- (void)onRender {    
    [self.view drawBegin];
    
    [self renderCurveToOffscreen];
    [self.view renderFinishedTextureToOnScreen];
    [self.view renderOffscreenTextureToOnscreen];
    
    [self.view drawEnd];
}

-(void)onRenderFinished {
    [self.view drawBegin];
    
    [self renderCurveToOffscreen];
    [self.view renderOffscreenTextureToFinished]; // <----
    [self.view renderFinishedTextureToOnScreen];
    
    [self.view drawEnd];
}

- (void)renderCurveToOffscreen {
    [self.view turnONColorBlending];
    [self.view blendAlpha];
    // Clear the offscreen color buffer with black
    [self.view clearOffscreenColor]; // C_destination (black transparent)
    
    if (_currentPolyline.m_points.empty()) {
        BOOL shouldReset = self.view.vertices.count > 0;
        if (shouldReset) {
            self.view.vertices = [[NSMutableArray alloc] init];
        }
        return;
    }
    
    // 太さ取得
    float curveWidth = self.view.lineWidth;
    
    // ペン先設定
    [self.view setPenTextureWithWidth:curveWidth];

    Polyline interpolated;
    InterpolateAsSNS(_currentPolyline, &interpolated);
    
    Triangles tris;
    PolylineToTriangles(interpolated, curveWidth, &tris);

    [self.view useProgram:ProgramTypeNormalProgram];
    
#if SHOULD_USE_OPENGL_FOR_DRAWING_CURVE_STATE
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBlendEquation(GL_MAX_EXT);
    glVertexAttribPointer(self.view.m_pProgram->positionAttrib, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), tris.ptrToPoints());
    glVertexAttribPointer(self.view.m_pProgram->texCodAttrib, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), tris.ptrToTexCod());
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)(3*tris.m_triangles.size()));
    
    glBlendEquation(GL_FUNC_ADD);
#elif SHOULD_USE_METAL
    [self convertTrianglesFrom:tris];
#endif
}

-(void)convertTrianglesFrom:(Triangles)tris {
    // converting vector to an array
    NSMutableArray *trianglesArray = [NSMutableArray arrayWithCapacity:tris.m_triangles.size() * 3];
    std::for_each(tris.m_triangles.begin(), tris.m_triangles.end(), ^(Triangle triangle) {
        VertexObj *t1 = [[VertexObj alloc] init];
        t1.x = triangle.p1.position.x;
        t1.y = triangle.p1.position.y;
        t1.texPosX = triangle.p1.texPos.x;
        t1.texPosY = triangle.p1.texPos.y;
        [trianglesArray addObject:t1];
        
        VertexObj *t2 = [[VertexObj alloc] init];
        t2.x = triangle.p2.position.x;
        t2.y = triangle.p2.position.y;
        t2.texPosX = triangle.p2.texPos.x;
        t2.texPosY = triangle.p2.texPos.y;
        [trianglesArray addObject:t2];
        
        VertexObj *t3 = [[VertexObj alloc] init];
        t3.x = triangle.p3.position.x;
        t3.y = triangle.p3.position.y;
        t3.texPosX = triangle.p3.texPos.x;
        t3.texPosY = triangle.p3.texPos.y;
        [trianglesArray addObject:t3];
    });
    self.view.vertices = trianglesArray;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count > 1) {
        _currentPolyline.m_points.clear();
        return;
    }
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    _currentPolyline.m_points.clear();
    [self addNew:point];
    
    [self onRender];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count > 1) {
        _currentPolyline.m_points.clear();
        return;
    }
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [self addNew:point];
    
    // マルチタッチの時
    if ([event allTouches].count > 1) {
        _currentPolyline.m_points.clear();
    }
    
    [self onRender];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count > 1) {
        _currentPolyline.m_points.clear();
        return;
    }
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [self addAnExtraPointBeside:point];
    [self onRenderFinished];
    _currentPolyline.m_points.clear();
}

-(void)addAnExtraPointBeside:(CGPoint)point {
    if (_currentPolyline.count() > 1) {
        return;
    }
    
    CGPoint nearbyPoint = CGPointMake(point.x + 0.1, point.y + 0.1);
    // 点の描画は、２つ目の点を少しずらすと表示される（同じ座標では長さが０になるので表示されない）
    // The drawing of the point will be displayed by slightly shifting the second point
    // (at the same coordinates, the length will be 0, so it will not be displayed)
    if (_currentPolyline.count() == 0) {
        [self addNew:point];
        [self addNew:nearbyPoint];
        // １以上の時に最後の点を追加してしまうと、曲線の補完が変になる
        // If you add the last point when it is 1 or more, the curve completion will be strange.
    } else {
        [self addNew:nearbyPoint];
    }
}

-(void)addNew:(CGPoint)point {
    _currentPolyline.addPoint(vec2(point.x, point.y));
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // マルチタッチでキャンセルされた時
    if ([event allTouches].count > 1) {
        _currentPolyline.m_points.clear();
    }
}

@end
NS_ASSUME_NONNULL_END
