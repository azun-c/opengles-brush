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
    
    [self renderCurveOnOffscreen];
    [self.view renderOffscreenTextureToOnscreen];
    
    [self.view drawEnd];
}

-(void)onRenderFinished {
//    [self.view drawBegin];
//    
//    [self renderCurveOnOffscreen];
//    [self.view renderOffscreenTextureToFinished]; // <----
//    [self.view renderFinishedTextureToOnScreen];
//    
//    [self.view drawEnd];
}

- (void)renderCurveOnOffscreen {
    [self.view turnONColorBlending];
    [self.view blendAlpha];
    // Clear the offscreen color buffer with black
    [self.view clearOffscreenColor]; // C_destination (black transparent)
    
    if (_currentPolyline.m_points.empty()) {
        return;
    }
    
    glBlendEquation(GL_MAX_EXT);
    
    [self renderTriangles];
    
    glBlendEquation(GL_FUNC_ADD);
}

-(void)renderTriangles {
    Triangles tris = [self generateTriangles];
    [self.view useProgram:ProgramTypeNormalProgram];

    // pass triangle points to `positionAttrib` (shader attribute: `Position`)
    glVertexAttribPointer(self.view.m_pProgram->positionAttrib, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), tris.ptrToPoints());
    // pass triangle texture coord to `texCodAttrib` (shader attribute: `TextureCoord`)
    glVertexAttribPointer(self.view.m_pProgram->texCodAttrib, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), tris.ptrToTexCod());
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)(3*tris.m_triangles.size()));
}

-(Triangles)generateTriangles {
    // 太さ取得
    float curveWidth = 25.0f;
    
    // ペン先設定
    [self.view setPenTextureWithWidth:curveWidth];

    
    Polyline interpolated;
    InterpolateAsSNS(_currentPolyline, &interpolated);
    
    Triangles tris;
    PolylineToTriangles(interpolated, curveWidth, &tris);
    return tris;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    _currentPolyline.m_points.clear();
    _currentPolyline.addPoint(vec2(point.x, point.y));
    
    [self addAnExtraPointBeside:point];
    
//    [self onRender];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    _currentPolyline.addPoint(vec2(point.x, point.y));
    
    
    // マルチタッチの時
    if ([event allTouches].count > 1) {
        _currentPolyline.m_points.clear();
    }
    
//    [self onRender];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    _currentPolyline.addPoint(vec2(point.x, point.y));
    [self addAnExtraPointBeside:point];
    [self onRenderFinished];
    _currentPolyline.m_points.clear();
}

-(void)addAnExtraPointBeside:(CGPoint)currentPoint {
    // workaround: 1 point won't show on screen
    _currentPolyline.addPoint(vec2(currentPoint.x + 0.03, currentPoint.y + 0.03));
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // マルチタッチでキャンセルされた時
    if ([event allTouches].count > 1) {
        _currentPolyline.m_points.clear();
    }
}

@end
NS_ASSUME_NONNULL_END
