//
//  ViewController.m
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import "ViewController.h"
#import "DrawingCurveState.h"
#import "opengles_brush-Swift.h"

@interface ViewController ()
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, assign) CGPoint lastPoint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupEffects];
}

-(void)setupUI {
    [self setupFreeDrawView];
    [self updateTitleIfNeeded];
    [self setupButtons];
}

-(void)setupFreeDrawView {
    CGSize viewSize = self.view.bounds.size;
    CGSize drawSize = CGSizeMake(viewSize.width, viewSize.width / 1.7);
    CGRect drawRect = CGRectMake(0, (viewSize.height - drawSize.height)/2, drawSize.width, drawSize.height);
    
    self.freeDrawView = [[FreeDrawView alloc] initWithFrame:drawRect];
    self.freeDrawView.backgroundColor = [UIColor whiteColor];
    
    BaseViewState *state = [[DrawingCurveState alloc] init];
    state.view = self.freeDrawView;
    self.freeDrawView.viewState = state;
    [state onBeginState];
    
    [self.view addSubview:self.freeDrawView];
}

-(void)updateTitleIfNeeded {
#if SHOULD_USE_METAL && !SHOULD_USE_OPENGL_FOR_DRAWING_CURVE_STATE
    UILabel *label;
    for(UIView *view in self.view.subviews) {
        UILabel *found = (UILabel *)view;
        if(found && [found.text hasPrefix:@"OpenGL ES"]) {
            label = found;
            break;
        }
    }
    if (label) {
        label.text = @"OpenGL ES to Metal";
    }

#endif
}

-(void)setupEffects {
//    [self setupBackgroundEffect];
    [self setupZoomInEffect];
}

-(void)setupBackgroundEffect {
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
        int seconds = (int)currentTime % 10;
        self.freeDrawView.backgroundColor = seconds % 10 >= 4 ? UIColor.whiteColor : UIColor.cyanColor;
    }];
    [timer fire];
}

-(void)setupZoomInEffect {
    self.lastPoint = CGPointZero;
    self.lastScale = 1;
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.view addGestureRecognizer:gesture];
}

-(void)pinchAction:(UIPinchGestureRecognizer*)sender {
    if (sender.numberOfTouches < 2) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.0;
        self.lastPoint = [sender locationInView:self.view];
    }
    
    // Scale
    CGFloat scale = 1.0 - (self.lastScale - sender.scale);
    [self.view.layer setAffineTransform:
     CGAffineTransformScale([self.view.layer affineTransform],
                            scale,
                            scale)];
    self.lastScale = sender.scale;
    
    // Translate
    CGPoint point = [sender locationInView:self.view];
    [self.view.layer setAffineTransform:
     CGAffineTransformTranslate([self.view.layer affineTransform],
                                point.x - self.lastPoint.x,
                                point.y - self.lastPoint.y)];
    self.lastPoint = [sender locationInView:self.view];
}
@end
