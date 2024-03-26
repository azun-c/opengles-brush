//
//  FreeDrawView.m
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import "FreeDrawView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/gl.h>
#import "DrawingCurveState.h"

#import "IResourceManager.hpp"
#import "opengles_brush-Swift.h"

static const float kAlphaForFluorescence = 0.62f; // 蛍光ペン透明度

@interface FreeDrawView ()

@property (nonatomic, strong) CADisplayLink * __nullable displayLink;
@property BOOL shouldShowBlendingOnOffEffect;
@property (nonatomic, assign) int colorIndex;
@property (nonatomic, assign) float strokeWidth;
@property (nonatomic, assign) DrawingMode drawingMode;
@end


@implementation FreeDrawView

@synthesize lineWidth = _lineWidth;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.viewState = nil;
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)super.layer;
        eaglLayer.opaque = YES;

        if ([self setUpGL] == NO) {
            return nil;
        }
    }
#if SHOULD_USE_METAL
        [self setupMetalView];
#endif
    [self setupExtraConfigs];
    
    return self;
}

-(void)setupExtraConfigs {
    self.shouldShowBlendingOnOffEffect = NO;
    self.strokeWidth = 15.0f;
}

-(float)lineWidth {
    return self.strokeWidth;
}

// to demonstrate some effects/ideas
-(void)performExtraHandlers {
    long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    int seconds = (int)currentTime % 10;
    if (self.shouldShowBlendingOnOffEffect) {
        if (seconds >= 4) {
            [self turnOFFColorBlending];
        }
        else {
            glEnable(GL_BLEND);
        }
    }
}

-(void)updateDrawingColor {
    UIColor *color = [self fetchNextColor];
    
    CGFloat red, green, blue, alpha;
    
    [color getRed: &red
            green: &green
             blue: &blue
            alpha: &alpha];
    CGFloat finalAlpha = self.drawingMode == DrawingModeHighlighter ? kAlphaForFluorescence : alpha;
    _m_drawColor[0] = [[NSNumber alloc] initWithDouble:red];
    _m_drawColor[1] = [[NSNumber alloc] initWithDouble:green];
    _m_drawColor[2] = [[NSNumber alloc] initWithDouble:blue];
    _m_drawColor[3] = [[NSNumber alloc] initWithDouble:finalAlpha];
}

-(UIColor *)fetchNextColor {
    switch (self.colorIndex % 4) {
        case 0:
            return UIColor.systemRedColor;
        case 1:
            return UIColor.systemGreenColor;
        case 2:
            return [[UIColor alloc] initWithRed:1 green:1 blue:0.6 alpha:1];
        default:
            return [[UIColor alloc] initWithRed:0.6 green:1 blue:0 alpha:1];
    }
}

- (void)drawView:(nullable CADisplayLink *)displayLink {
    [self performExtraHandlers];
    
    [self.viewState onRender];
    
    // Reflect renderbuffer in context (present onScreen buffer)
    [_m_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)startAnimation {
    if (self.displayLink) {
        return;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (BOOL)setUpGL {
    // Inspired by: `Rendering to a Core Animation Layer`
    //https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithEAGLContexts/WorkingwithEAGLContexts.html#//apple_ref/doc/uid/TP40008793-CH103-SW8
    
    self.m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_m_context || ![EAGLContext setCurrentContext:_m_context]) {
        return NO;
    }
    
    // Onscreen framebuffer and renderbuffer
    [self setUpOnScreen];
    
    [self setUpFBOs];
    
    [self setUpProgram];
    [self useProgram:ProgramTypeNormalProgram];
    
    [self setupPenTextures];
    [self setupDefaultPenColor];
    [self setupViewport];
    
    return YES;
}

-(void)setupDefaultPenColor {
    // 描画色設定
    _m_drawColor = @[].mutableCopy;
    [self updateDrawingColor];
    [self changeWidth];
}

- (void)clearOffscreenColor {
    // black transparent // if not calling this, the final brush color will be white :D
    [self clearFrameBuffer:_m_offScreen.framebuffer withRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
}

- (void)clearFinishedColor {
    [self clearFrameBuffer:_m_finished.framebuffer withRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
}

-(void)setupPenTextures {
    // ペンのテクスチャを作成
    _m_penGray_2_32 = [self createTexture:@"FreeDrawPenGray-2_32.png" withFormat:GL_RGBA];
    _m_penGray_2_16 = [self createTexture:@"FreeDrawPenGray-2_16.png" withFormat:GL_RGBA];
    _m_penGray_16 = [self createTexture:@"FreeDrawPenGray_16.png" withFormat:GL_RGBA];
    _m_penGray_32 = [self createTexture:@"FreeDrawPenGray_32.png" withFormat:GL_RGBA];
}

- (void) turnONColorBlending {
    // https://learnopengl.com/Advanced-OpenGL/Blending
    if (self.shouldShowBlendingOnOffEffect) {
        return;
    }
    glEnable(GL_BLEND);
}

- (void) turnOFFColorBlending {
    glDisable(GL_BLEND);
}

- (void) blendAlpha {
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)setUpOnScreen {
    // Read more at: https://www.opengles-book.com/OpenGL_ES_20_Programming_Guide_iPhone_eChapter.pdf
    // Using a Framebuffer Object for Rendering
    
    // create onScreen's FrameBuffer
    glGenFramebuffers(1, &_m_onScreen.framebuffer);
    // bind onScreen's FrameBuffer to GL_FRAMEBUFFER
    glBindFramebuffer(GL_FRAMEBUFFER, _m_onScreen.framebuffer);
    
    // create onScreen's RenderBuffer
    glGenRenderbuffers(1, &_m_onScreen.renderbuffer);
    // bind onScreen's RenderBuffer to GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, _m_onScreen.renderbuffer);
    
    // binds drawable object’s storage to the renderbuffer object.
    [_m_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)super.layer];
    
    // attach the RenderBuffer as a logical buffer of a FrameBuffer object
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _m_onScreen.renderbuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        assert(NO);
        return;
    }
}

- (void)setUpFBOs {
    // オフスクリーンFBO
    [self setUpFBO:_m_offScreen];
    
    // 描画済み保持用FBO - Framebuffer object for holding all drawn drawings
    [self setUpFBO:_m_finished];
}

- (void)setUpFBO:(FBO&)fbo {
    [self setupFrameBufferFor:fbo];
    [self setupTextureFor:fbo];
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        assert(NO);
        return;
    }
}

-(void)setupTextureFor:(FBO&)fbo {
    glGenTextures(1, &fbo.texture);
    glBindTexture(GL_TEXTURE_2D, fbo.texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                 self.bounds.size.width,
                 self.bounds.size.height,
                 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    // Attach the texture buffer (fbo.texture - which is a TEXTURE_2D buffer) as a color attachment
    // of the active framebuffer object (which is the fbo.framebuffer)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbo.texture, 0);
    
    // All subsequent rendering operations will now render to the attachments of the currently bound framebuffer
    // link: https://learnopengl.com/Advanced-OpenGL/Framebuffers
    // which means: all rendering operations to fbo.framebuffer will render to fbo.texture)
}

-(void)setupFrameBufferFor:(FBO&)fbo {
    glGenFramebuffers(1, &fbo.framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo.framebuffer);
}

- (void)clearFrameBuffer:(GLuint)framebuffer withRed:(float)r green:(float)g blue:(float)b alpha:(float)a {
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glClearColor(r, g, b, a);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)setUpProgram {
    _m_normalProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" 
                                                   withFragmentShader:@"Normal.frag"];
    [self initializeProgram:&_m_normalProgram];
    
    _m_whiteAsAlphaProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" 
                                                         withFragmentShader:@"WhiteAsAlpha.frag"];
    [self initializeProgram:&_m_whiteAsAlphaProgram];
}

- (GLuint)createShader:(NSString *)filename withType:(GLenum)shaderType {
    // 拡張子
    NSString *type = [filename pathExtension];
    // パス名
    NSRange extRange = [filename rangeOfString:type];
    NSString *file = [filename substringToIndex:extRange.location - 1];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:type];
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    GLuint shaderHandle = glCreateShader(shaderType);
    glShaderSource(shaderHandle, 1, &source, 0);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"Failed compiling shader : %s", messages);
        exit(1);
    }
    return shaderHandle;
}

- (GLuint)createProgramWithVertexShaderSource:(NSString *)vShaderSource withFragmentShader:(NSString *)fShaderSource {
    GLuint vertexShader = [self createShader:vShaderSource withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self createShader:fShaderSource withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, &message[0]);
        NSLog(@"Failed linking program : %s", message);
        exit(1);
    }
    return programHandle;
}

- (void)initializeProgram:(Program *)pProgram {
    pProgram->positionAttrib = glGetAttribLocation(pProgram->name, "Position");
    pProgram->texCodAttrib = glGetAttribLocation(pProgram->name, "TextureCoord");
    pProgram->drawColorUniform = glGetUniformLocation(pProgram->name, "DrawColor");
    pProgram->projectionUniform = glGetUniformLocation(pProgram->name, "Projection");
    pProgram->modelviewUniform = glGetUniformLocation(pProgram->name, "Modelview");
    
    pProgram->sampler0Uniform = glGetUniformLocation(pProgram->name, "Sampler0");
}

- (void)useProgram:(ProgramType)type {
    switch (type) {
        case ProgramTypeNormalProgram:
            _m_pProgram = &_m_normalProgram;
            break;
        case ProgramTypeWhiteAsAlphaProgram:
            _m_pProgram = &_m_whiteAsAlphaProgram;
            break;
        default:
            assert(NO);
            break;
    }
    glUseProgram(_m_pProgram->name);
    [self setModelview:_m_pProgram];
    [self setProjection:_m_pProgram];
    [self setSampler:_m_pProgram];
}

- (void)setModelview:(Program *)pProgram {
    float modelview[16] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    
    glUniformMatrix4fv(pProgram->modelviewUniform, 1, GL_FALSE, &modelview[0]);
}

- (void)setProjection:(Program *)pProgram {
    GLfloat halfWidth = 0.5*self.bounds.size.width;
    GLfloat halfHeight = 0.5*self.bounds.size.height;
    // GLは列順であることに注意 {a11, a21, a31, a41, a12, a22, ...}
    GLfloat ortho[16] = {
        1.0f/halfWidth,  0,  0,  0,
        0, -1.0f/halfHeight,  0,  0,
        0,  0,  1,  0,
        -1,  1,  0,  1
    };
    
    glUniformMatrix4fv(pProgram->projectionUniform, 1, GL_FALSE, &ortho[0]);
}

- (void)setSampler:(Program *)pProgram {
    // set the sampler0 to use image unit 0
    glUniform1i(pProgram->sampler0Uniform, 0);
}

- (GLuint)createTexture:(NSString *)filename withFormat:(GLint)format {
    GLenum texelFormat = GL_UNSIGNED_BYTE;
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    IResourceManager *resourceManager = CreateResourceManager();

    resourceManager->LoadPngImage([filename UTF8String]);
    void *pixels = resourceManager->GetImageData();
    ivec2 size = resourceManager->GetImageSize();
    glTexImage2D(GL_TEXTURE_2D, 0, format, size.x, size.y, 0, format, texelFormat, pixels);
    resourceManager->UnloadImage();

    delete resourceManager;
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    return texture;
}

- (void)setPenTextureWithWidth:(float)width {
    if (width > 24.0f) {
        glBindTexture(GL_TEXTURE_2D, self.m_penGray_32);
    } else if (width > 12.0f) {
        glBindTexture(GL_TEXTURE_2D, self.m_penGray_16);
    } else if (width > 6.0f) {
        glBindTexture(GL_TEXTURE_2D, self.m_penGray_2_32);
    } else {
        glBindTexture(GL_TEXTURE_2D, self.m_penGray_2_16);
    }
}

- (void)setupViewport {
    NSLog(@"layoutSubviews bounds = (%f, %f)",
          self.bounds.size.width, self.bounds.size.height);
    [self clearFinishedColor];
    glViewport(0, 0,  self.bounds.size.width, self.bounds.size.height);
}

- (void)applyDrawColorWith:(NSArray<NSNumber *>*)drawColor {
    glUniform4f(_m_pProgram->drawColorUniform, 
                drawColor[0].floatValue,
                drawColor[1].floatValue,
                drawColor[2].floatValue,
                drawColor[3].floatValue);
}

- (void)drawBegin {
    glEnableVertexAttribArray(_m_pProgram->positionAttrib);
    glEnableVertexAttribArray(_m_pProgram->texCodAttrib);
}

- (void)drawEnd {
    glDisableVertexAttribArray(_m_pProgram->positionAttrib);
    glDisableVertexAttribArray(_m_pProgram->texCodAttrib);
}

- (void)drawTexture:(GLuint)texture toFramebuffer:(GLuint)framebuffer {
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    float positionTexCod[] = {
        // top left
        0.0, 0.0, // Position
        0.0, 1.0, // TextCoord (positionTexCod+2)
        
        // top right
        static_cast<float>(self.bounds.size.width), 0.0, // Position
        1.0, 1.0, // TextCoord
        
        // bottom left
        0.0, static_cast<float>(self.bounds.size.height), // Position
        0.0, 0.0, // TextCoord
        
        static_cast<float>(self.bounds.size.width), 0.0, 1.0, 1.0, // top right
        0.0, static_cast<float>(self.bounds.size.height), 0.0, 0.0, // bottom left
        
        // bottom right
        static_cast<float>(self.bounds.size.width), static_cast<float>(self.bounds.size.height), // Position
        1.0, 0.0 // TextCoord
    };
    
    glVertexAttribPointer(_m_pProgram->positionAttrib, 2, GL_FLOAT, GL_FALSE, 
                          4*sizeof(float), positionTexCod);
    glVertexAttribPointer(_m_pProgram->texCodAttrib, 2, GL_FLOAT, GL_FALSE, 
                          4*sizeof(float), positionTexCod+2);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}


- (void)renderOffscreenTextureToOnscreen {
    // Draw offScreen to onScreen
    [self useProgram:ProgramTypeWhiteAsAlphaProgram];
    [self applyDrawColorWith:_m_drawColor];
    
    [self drawTexture:_m_offScreen.texture toFramebuffer:_m_onScreen.framebuffer];
}

- (void)renderOffscreenTextureToFinished {
    [self useProgram:ProgramTypeWhiteAsAlphaProgram];
    [self applyDrawColorWith:_m_drawColor];
    
    [self drawTexture:_m_offScreen.texture toFramebuffer:_m_finished.framebuffer];
}

- (void)renderFinishedTextureToOnScreen {
    // 記入済みレイヤをオンスクリーンにブレンドせずに描画
    // Draw filled layers onscreen without blending
    [self turnOFFColorBlending];
    [self useProgram:ProgramTypeNormalProgram];
    [self drawTexture:_m_finished.texture toFramebuffer:_m_onScreen.framebuffer];
    [self turnONColorBlending];
}

-(void)changeBg { }

-(void)changeColor {
    self.colorIndex += 1;
    [self updateDrawingColor];
}

-(void)changeWidth {
    int width = (int)self.strokeWidth;
    width += 4;
    
    self.strokeWidth = (float)MAX(width % 25, 6);
}

-(void)clearDrawings {
    [self clearFrameBuffer:_m_offScreen.framebuffer withRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    [self clearFrameBuffer:_m_finished.framebuffer withRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
}

-(void)changeModeTo:(DrawingMode)mode {
    self.drawingMode = mode;
    [self updateDrawingColor];
}

#pragma mark - touchesEvent
- (void)touchesBegan:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self.viewState touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self.viewState touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self.viewState touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self.viewState touchesCancelled:touches withEvent:event];
}
@end
