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

@implementation FreeDrawView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
//        self.viewState = nil;
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)super.layer;
        eaglLayer.opaque = YES;

        // 長押し時のイベント
//        UILongPressGestureRecognizer *longPressRecoginizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//        [self addGestureRecognizer:longPressRecoginizer];

        // デバッグ用に境界線を表示
//        self.borderLayer = [[CALayer alloc] init];
//        self.borderLayer.borderWidth = 2.0;
//        self.borderLayer.borderColor = [UIColor grayColor].CGColor;
//        [self.layer addSublayer:self.borderLayer];
        
        // Retina用 scaleFactorをRetinaに対応させると拡大時に書き味が落ちるため1.0fに
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
//    [self.viewState onRender];
    
    // レンダーバッファをコンテキストに反映
    // Reflect renderbuffer in context
    [_m_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)setUpGL {
    self.m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_m_context || ![EAGLContext setCurrentContext:_m_context]) {
        return NO;
    }
    
    // オンスクリーンフレームバッファとレンダーバッファ
    [self setUpOnScreen];
    
    [self setUpFBOs];
    
    // 前面用のFBO
    [self clearFrameBuffer:_m_forMove.framebuffer withRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
    
    // プログラム
    [self setUpProgram];
    [self useProgram:ProgramTypeWhiteAsAlphaProgram];
    
    // ペンのテクスチャを作成
    _m_penGray_2_32 = [self createTexture:@"FreeDrawPenGray-2_32.png" withFormat:GL_RGBA];
    _m_penGray_2_16 = [self createTexture:@"FreeDrawPenGray-2_16.png" withFormat:GL_RGBA];
    _m_penGray_2_8 = [self createTexture:@"FreeDrawPenGray-2_8.png" withFormat:GL_RGBA];
    _m_penGray_32 = [self createTexture:@"FreeDrawPenGray_32.png" withFormat:GL_RGBA];
    _m_penGray_16 = [self createTexture:@"FreeDrawPenGray_16.png" withFormat:GL_RGBA];
    _m_penMono_32 = [self createTexture:@"FreeDrawPenMono_32.png" withFormat:GL_RGBA];
    _m_penMono_16 = [self createTexture:@"FreeDrawPenMono_16.png" withFormat:GL_RGBA];
    
    // 背景用のテクスチャはとりあえず0で初期化
    _m_backgroundTexture = 0;
    
    // 描画色設定
    _m_drawColor = @[].mutableCopy;
    _m_drawColor[0] = @1.0f;
    _m_drawColor[1] = @0.0f;
    _m_drawColor[2] = @0.0f;
    _m_drawColor[3] = @0.5f;
    
    // 初期化
    [self initializeLayers];
    
    // アルファブレンドを有効にする
    // Enable alpha blending
    glEnable(GL_BLEND);CHECK_GL_ERROR();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);CHECK_GL_ERROR();
    
    return YES;
}

- (void)setUpOnScreen {
    glGenFramebuffers(1, &_m_onScreen.framebuffer);CHECK_GL_ERROR();
    glBindFramebuffer(GL_FRAMEBUFFER, _m_onScreen.framebuffer);CHECK_GL_ERROR();
    
    glGenRenderbuffers(1, &_m_onScreen.renderbuffer);CHECK_GL_ERROR();
    glBindRenderbuffer(GL_RENDERBUFFER, _m_onScreen.renderbuffer);CHECK_GL_ERROR();
    [_m_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)super.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _m_onScreen.renderbuffer);CHECK_GL_ERROR();
    
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
    [self setUpFBO:_m_finished];
    // セレクション用のFBO
    [self setUpFBO:_m_forSelection];
    // 前面用のFBO
    [self setUpFBO:_m_forMove];
    // 画像生成用のFBO
    [self setUpFBO:_m_forAccumulate];
}

- (void)setUpFBO:(FBO&)fbo {
    glGenFramebuffers(1, &fbo.framebuffer);CHECK_GL_ERROR();
    glBindFramebuffer(GL_FRAMEBUFFER, fbo.framebuffer);CHECK_GL_ERROR();
    
    glGenTextures(1, &fbo.texture);CHECK_GL_ERROR();
    glBindTexture(GL_TEXTURE_2D, fbo.texture);CHECK_GL_ERROR();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);CHECK_GL_ERROR();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);CHECK_GL_ERROR();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);CHECK_GL_ERROR();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);CHECK_GL_ERROR();
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.bounds.size.width*_m_scaleFactor, self.bounds.size.height*_m_scaleFactor, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);CHECK_GL_ERROR();
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbo.texture, 0);CHECK_GL_ERROR();
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        assert(NO);
        return;
    }
}


- (void)clearFrameBuffer:(GLuint)framebuffer withRed:(float)r green:(float)g blue:(float)b alpha:(float)a {
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glClearColor(r, g, b, a);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)setUpProgram {
    _m_normalProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" withFragmentShader:@"Normal.frag"];
    [self initializeProgram:&_m_normalProgram];
    _m_whiteAsAlphaProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" withFragmentShader:@"WhiteAsAlpha.frag"];
    [self initializeProgram:&_m_whiteAsAlphaProgram];
    _m_discardAlphaZeroProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" withFragmentShader:@"DiscardAlphaZero.frag"];
    [self initializeProgram:&_m_discardAlphaZeroProgram];
    _m_noTextureProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" withFragmentShader:@"NoTexture.frag"];
    [self initializeProgram:&_m_noTextureProgram];
    _m_forImageProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" withFragmentShader:@"ForImage.frag"];
    [self initializeProgram:&_m_forImageProgram];
    _m_blurProgram.name = [self createProgramWithVertexShaderSource:@"Normal.vert" withFragmentShader:@"Blur.frag"];
    [self initializeProgram:&_m_blurProgram];
}

- (void)useProgram:(ProgramType)type {
    switch (type) {
        case ProgramTypeNormalProgram:
            _m_pProgram = &_m_normalProgram;
            break;
        case ProgramTypeWhiteAsAlphaProgram:
            _m_pProgram = &_m_whiteAsAlphaProgram;
            break;
        case ProgramTypeDiscardAlphaZero:
            _m_pProgram = &_m_discardAlphaZeroProgram;
            break;
        case ProgramTypeNoTexture:
            _m_pProgram = &_m_noTextureProgram;
            break;
        case ProgramTypeForImage:
            _m_pProgram = &_m_forImageProgram;
            break;
        case ProgramTypeBlur:
            _m_pProgram = &_m_blurProgram;
            break;
        default:
            assert(NO);
            break;
    }
    glUseProgram(_m_pProgram->name);
    [self setModelview:_m_pProgram];
    [self setProjection:_m_pProgram];
    [self setSampler:_m_pProgram];
    [self setPixelTex:_m_pProgram];
}

- (void)setModelview:(Program *)pProgram {
    float modelview[16] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    
    glUniformMatrix4fv(pProgram->modelviewUniform, 1, GL_FALSE, &modelview[0]);CHECK_GL_ERROR();
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
    
    glUniformMatrix4fv(pProgram->projectionUniform, 1, GL_FALSE, &ortho[0]);CHECK_GL_ERROR();
}

- (void)setPixelTex:(Program *)pProgaram {
    GLfloat dx = 1.0/self.bounds.size.width;
    GLfloat dy = 1.0/self.bounds.size.height;
    glUniform2f(pProgaram->pixelTex, dx, dy);CHECK_GL_ERROR();
}

- (void)setSampler:(Program *)pProgram {
    glUniform1i(pProgram->sampler0Uniform, 0);CHECK_GL_ERROR();
    glUniform1i(pProgram->sampler1Uniform, 1);CHECK_GL_ERROR();
}

- (GLuint)createTexture:(NSString *)filename withFormat:(GLint)format {
    GLenum texelFormat = GL_UNSIGNED_BYTE;
    GLuint texture;
    glGenTextures(1, &texture);CHECK_GL_ERROR();
    glBindTexture(GL_TEXTURE_2D, texture);CHECK_GL_ERROR();
    
    IResourceManager *resourceManager = CreateResourceManager();

    resourceManager->LoadPngImage([filename UTF8String]);
    void *pixels = resourceManager->GetImageData();
    ivec2 size = resourceManager->GetImageSize();
    glTexImage2D(GL_TEXTURE_2D, 0, format, size.x, size.y, 0, format, texelFormat, pixels);
    resourceManager->UnloadImage();

    delete resourceManager;
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);CHECK_GL_ERROR();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);CHECK_GL_ERROR();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);CHECK_GL_ERROR();
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);CHECK_GL_ERROR();
    
    return texture;
}
@end
