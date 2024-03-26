//
//  FreeDrawView.h
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>

@class BaseViewState;
@class VertexObj;

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
    GLuint sampler0Uniform;
} Program;

typedef NS_ENUM(NSInteger, ProgramType) {
    ProgramTypeNormalProgram,
    ProgramTypeWhiteAsAlphaProgram,
};

typedef NS_ENUM(NSInteger, DrawingMode) {
    DrawingModeBrush,
    DrawingModeHighlighter,
};

NS_ASSUME_NONNULL_BEGIN

@interface FreeDrawView : UIView
@property (nonatomic, strong, nullable) EAGLContext *m_context;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *m_drawColor;
@property (nonatomic, strong) BaseViewState * __nullable viewState;
@property (nonatomic) float lineWidth;

@property (nonatomic, assign) GLuint m_penGray_2_32;
@property (nonatomic, assign) GLuint m_penGray_2_16;
@property (nonatomic, assign) GLuint m_penGray_32;
@property (nonatomic, assign) GLuint m_penGray_16;

@property (nonatomic, assign) ColorBuffer m_onScreen;
@property (nonatomic, assign) FBO m_offScreen;
@property (nonatomic, assign) FBO m_finished;

@property (nonatomic, assign) Program *m_pProgram;
@property (nonatomic, assign) Program m_normalProgram;
@property (nonatomic, assign) Program m_whiteAsAlphaProgram;

@property (nonatomic, strong) NSMutableArray<VertexObj *> *vertices;

- (void)startAnimation;

- (void)drawView:(nullable CADisplayLink *)displayLink;

- (void)drawBegin;
- (void)drawEnd;
- (void)drawTexture:(GLuint)texture toFramebuffer:(GLuint)framebuffer;
- (void)renderOffscreenTextureToOnscreen;
- (void)renderOffscreenTextureToFinished;
- (void)renderFinishedTextureToOnScreen;
- (void)clearOffscreenColor;
- (void)setPenTextureWithWidth:(float)width;
- (void)useProgram:(ProgramType)type;
- (void)applyDrawColorWith:(NSArray<NSNumber *>*)drawColor;

- (void)turnONColorBlending;
- (void)turnOFFColorBlending;
- (void)blendAlpha;

-(void)changeBg;
-(void)changeColor;
-(void)changeWidth;
-(void)clearDrawings;
-(void)changeModeTo:(DrawingMode)mode;
@end

NS_ASSUME_NONNULL_END
