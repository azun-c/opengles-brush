//
//  FreeDrawView.h
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FreeHandCurve.h"

@class IFreeDrawViewState;

typedef struct ColorBuffer {
    GLuint framebuffer;
    GLuint renderbuffer;
} ColorBuffer;

typedef struct FBO {
    GLuint framebuffer;
    GLuint texture;
} FBO;

typedef struct Program {
    // Program name;
    GLuint name;
    // VertexShader Slot
    GLuint positionAttrib;
    GLuint texCodAttrib;
    GLuint drawColorUniform;
    GLuint projectionUniform;
    GLuint modelviewUniform;
    // FragmentShader Slot
    GLuint pixelTex; // 1pxあたりのテクスチャ座標差分
    GLuint sampler0Uniform;
    GLuint sampler1Uniform;
} Program;

typedef NS_ENUM(NSInteger, ProgramType) {
    ProgramTypeNormalProgram,
    ProgramTypeWhiteAsAlphaProgram,
    ProgramTypeDiscardAlphaZero,
    ProgramTypeNoTexture,
    ProgramTypeForImage,
    ProgramTypeBlur,
};

NS_ASSUME_NONNULL_BEGIN

@protocol FreeDrawViewDelegate

- (float)getLineWidth;
- (NSArray<NSNumber *> *)getColorComponents;

@end

@interface FreeDrawView : UIView
@property (nonatomic, strong, nullable) EAGLContext *m_context;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *m_drawColor;
@property (nonatomic, strong) IFreeDrawViewState * __nullable viewState;
@property (nonatomic, weak) id<FreeDrawViewDelegate> delegate;

@property (nonatomic, assign) float m_scaleFactor; // [UIScreen mainScreen].scale
@property (nonatomic, assign) GLuint m_penGray_2_32;
@property (nonatomic, assign) GLuint m_penGray_2_16;
@property (nonatomic, assign) GLuint m_penGray_2_8;
@property (nonatomic, assign) GLuint m_penGray_32;
@property (nonatomic, assign) GLuint m_penGray_16;
@property (nonatomic, assign) GLuint m_penMono_32;
@property (nonatomic, assign) GLuint m_penMono_16;

@property (nonatomic, assign) ColorBuffer m_onScreen;
@property (nonatomic, assign) FBO m_offScreen;
@property (nonatomic, assign) FBO m_finished;

//@property (nonatomic, assign) FBO m_forSelection;
//@property (nonatomic, assign) FBO m_forMove;
//@property (nonatomic, assign) FBO m_forAccumulate;

@property (nonatomic, assign) Program *m_pProgram;
@property (nonatomic, assign) Program m_normalProgram;
@property (nonatomic, assign) Program m_whiteAsAlphaProgram;
@property (nonatomic, assign) Program m_discardAlphaZeroProgram;
@property (nonatomic, assign) Program m_noTextureProgram;
@property (nonatomic, assign) Program m_forImageProgram;
@property (nonatomic, assign) Program m_blurProgram;

@property (nonatomic, assign) GLuint m_backgroundTexture;

- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)isAnimating;

- (void)drawView:(nullable CADisplayLink *)displayLink;

- (void)drawBegin;
- (void)drawEnd;
- (void)drawTexture:(GLuint)texture toFramebuffer:(GLuint)framebuffer;
- (void)renderFinishedToOnScreen;
- (void)renderOffscreenToOnscreen;
- (void)renderToFinished;
- (void)clearFrameBuffer:(GLuint)framebuffer
                  withRed:(float)r
                    green:(float)g
                     blue:(float)b
                    alpha:(float)a;
- (void)setPenTextureWithWidth:(float)width;
- (void)useProgram:(ProgramType)type;
- (void)applyDrawColorRed:(float)r withGreen:(float)g withBlue:(float)b withAlpha:(float)a;

- (BOOL)renderFreeHandCurve:(FreeHandCurve *)item asIndex:(int)index;

- (void)turnOnColorBlending:(BOOL)toTurnOn;
- (void)blendAlpha;
@end

NS_ASSUME_NONNULL_END

#ifdef DEBUG

#define CHECK_GL_ERROR()    { int err = glGetError(); \
if (err != GL_NO_ERROR) { NSLog(@"glGetError() = 0x%x\n", err); glGetError(); assert(false); } }

#else

#define CHECK_GL_ERROR()

#endif
