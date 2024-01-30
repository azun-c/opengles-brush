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

@interface FreeDrawView ()

@property (nonatomic, strong) CADisplayLink * __nullable displayLink;

@end


@implementation FreeDrawView

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

        _m_scaleFactor = 1.0f; //[UIScreen mainScreen].scale;
        self.contentScaleFactor = _m_scaleFactor;
        eaglLayer.contentsScale = _m_scaleFactor;
        
        if ([self setUpGL] == NO) {
            return nil;
        }
        
        [self drawView:nil];
    }
    return self;
}

- (void)drawView:(nullable CADisplayLink *)displayLink {
    // レンダリング
    [self.viewState onRender];
    
    // レンダーバッファをコンテキストに反映
    // Reflect renderbuffer in context
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
    
    // オンスクリーンフレームバッファとレンダーバッファ
    // Onscreen framebuffer and renderbuffer
    [self setUpOnScreen];
    
    [self setUpFBOs];
    
    // プログラム
    [self setUpProgram];
    [self useProgram:ProgramTypeNormalProgram];
    
    [self setupPenTextures];
    
    [self setupDefaultPenColor];
    
    // 初期化
    [self initializeLayers];
    
    return YES;
}

-(void)setupDefaultPenColor {
    // 描画色設定
    _m_drawColor = @[].mutableCopy;
    _m_drawColor[0] = @1.0f;
    _m_drawColor[1] = @1.0f;
    _m_drawColor[2] = @0.0f;
    _m_drawColor[3] = @1.0f;
}

-(void)setupDefaultBackgroundColor {
//    [self clearFrameBuffer:_m_finished.framebuffer withRed:0.5f green:0.5f blue:1.0f alpha:0.0f];
}

- (void)clearOffscreenColor {
    // back transparent // if don't call this. the final brush color will be white :D 
    [self clearFrameBuffer:_m_offScreen.framebuffer withRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
}

-(void)setupPenTextures {
    // ペンのテクスチャを作成
    _m_penGray_2_32 = [self createTexture:@"FreeDrawPenGray-2_32.png" withFormat:GL_RGBA];
    _m_penGray_2_16 = [self createTexture:@"FreeDrawPenGray-2_16.png" withFormat:GL_RGBA];
    _m_penGray_16 = [self createTexture:@"FreeDrawPenGray_16.png" withFormat:GL_RGBA];
    _m_penGray_32 = [self createTexture:@"FreeDrawPenGray_32.png" withFormat:GL_RGBA];
}

- (void) turnONColorBlending {
    glEnable(GL_BLEND);
}

- (void) turnOFFColorBlending {
    glDisable(GL_BLEND);
}

- (void) blendAlpha {
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)setUpOnScreen {
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
    // 描画済み保持用FBO
//    [self setUpFBO:_m_finished];
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
                 self.bounds.size.width*_m_scaleFactor,
                 self.bounds.size.height*_m_scaleFactor,
                 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbo.texture, 0);
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
    
//    pProgram->pixelTex = glGetUniformLocation(pProgram->name, "PixelTex");
    pProgram->sampler0Uniform = glGetUniformLocation(pProgram->name, "Sampler0");
//    pProgram->sampler1Uniform = glGetUniformLocation(pProgram->name, "Sampler1");
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
//    [self setSampler:_m_pProgram];
//    [self setPixelTex:_m_pProgram];
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

//- (void)setPixelTex:(Program *)pProgaram {
//    GLfloat dx = 1.0/self.bounds.size.width;
//    GLfloat dy = 1.0/self.bounds.size.height;
//    glUniform2f(pProgaram->pixelTex, dx, dy);
//}

//- (void)setSampler:(Program *)pProgram {
//    glUniform1i(pProgram->sampler0Uniform, 0);
//    glUniform1i(pProgram->sampler1Uniform, 1);
//}

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

- (void)initializeLayers {
    NSLog(@"layoutSubviews bounds = (%f, %f)", self.bounds.size.width, self.bounds.size.height);
    
    // 記入済みレイヤを透明色でクリア
    [self setupDefaultBackgroundColor];
    
    // ピューポートを設定
    glViewport(0, 0, 
               self.bounds.size.width*_m_scaleFactor,
               self.bounds.size.height*_m_scaleFactor);
}

- (void)applyDrawColorRed:(float)r withGreen:(float)g withBlue:(float)b withAlpha:(float)a {
    glUniform4f(_m_pProgram->drawColorUniform, r, g, b, a);
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
        0.0, 0.0, 0.0, 1.0, // bottom left (vec4)
        static_cast<float>(self.bounds.size.width), 0.0, 1.0, 1.0, // bottom right
        0.0, static_cast<float>(self.bounds.size.height), 0.0, 0.0, // top left
        
        static_cast<float>(self.bounds.size.width), 0.0, 1.0, 1.0, // bottom right
        0.0, static_cast<float>(self.bounds.size.height), 0.0, 0.0, // top left
        static_cast<float>(self.bounds.size.width), static_cast<float>(self.bounds.size.height), 1.0, 0.0 // top right
    };
    
    glVertexAttribPointer(_m_pProgram->positionAttrib, 2, GL_FLOAT, GL_FALSE, 
                          4*sizeof(float), positionTexCod);
    glVertexAttribPointer(_m_pProgram->texCodAttrib, 2, GL_FLOAT, GL_FALSE, 
                          4*sizeof(float), positionTexCod+2);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

//- (void)renderOffscreenTextureToFinished {
//    [self useProgram:ProgramTypeWhiteAsAlphaProgram];
//    [self applyDrawColorRed:_m_drawColor[0].floatValue
//                  withGreen:_m_drawColor[1].floatValue
//                   withBlue:_m_drawColor[2].floatValue
//                  withAlpha:_m_drawColor[3].floatValue];
//    
//    [self drawTexture:_m_offScreen.texture toFramebuffer:_m_finished.framebuffer];
//}

//- (void)renderBackgroundColor {
//    // 記入済みレイヤをオンスクリーンにブレンドせずに描画
//    // Draw filled layers onscreen without blending
//    [self turnOFFColorBlending];
//    [self useProgram:ProgramTypeNormalProgram];
//    [self drawTexture:_m_finished.texture toFramebuffer:_m_onScreen.framebuffer];
//    [self turnONColorBlending];
//}

- (void)renderOffscreenTextureToOnscreen {
    // オフスクリーンをオンスクリーンに描画
    // Draw offscreen to onscreen
    [self useProgram:ProgramTypeWhiteAsAlphaProgram];
    [self applyDrawColorRed:_m_drawColor[0].floatValue
                  withGreen:_m_drawColor[1].floatValue
                   withBlue:_m_drawColor[2].floatValue
                  withAlpha:_m_drawColor[3].floatValue];
    
    [self drawTexture:_m_offScreen.texture toFramebuffer:_m_onScreen.framebuffer];
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
