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

- (void)onEndState {
    // アニメーション終了
    _currentPolyline.m_points.clear();
    [self.view stopAnimation];
}

- (void)onRender {    
    [self.view drawBegin];
    
    [self renderCurveOnOffscreen];
    [self.view renderFinishedTextureToOnScreen];
    [self.view renderOffscreenTextureToOnscreen];
    
    [self.view drawEnd];
}

-(void)onRenderFinished {
    [self.view drawBegin];
    
    [self renderCurveOnOffscreen];
    [self.view renderOffscreenTextureToFinished]; // <----
    [self.view renderFinishedTextureToOnScreen];
    
    [self.view drawEnd];
}

- (void)renderCurveOnOffscreen {
    [self.view turnOnColorBlending:YES];
    [self.view blendAlpha];
    // オフスクリーンのカラーバッファを黒でクリア
    [self.view clearFrameBuffer:self.view.m_offScreen.framebuffer
                        withRed:0.0f green:0.0f blue:0.0f alpha:0.0f];

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
    [self.view applyDrawColorRed:1.0f withGreen:1.0f withBlue:1.0f withAlpha:1.0f];

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
    float curveWidth = 12.0f;
    
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
    
    // workaround: 1 point won't show on screen
    _currentPolyline.addPoint(vec2(point.x + 0.01, point.y + 0.01));
    
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
    // workaround: 1 point won't show on screen
    _currentPolyline.addPoint(vec2(point.x + 0.03, point.y + 0.03));
    [self onRenderFinished];
    _currentPolyline.m_points.clear();
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // マルチタッチでキャンセルされた時
    if ([event allTouches].count > 1) {
        _currentPolyline.m_points.clear();
    }
}

@end
NS_ASSUME_NONNULL_END
