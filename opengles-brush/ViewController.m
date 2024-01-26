//
//  ViewController.m
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import "ViewController.h"
#import "SelectingItemState.h"
#import "DrawingCurveState.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray<NSNumber *> *colorComponents;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.freeDrawView = [[FreeDrawView alloc] initWithFrame:self.view.bounds];
    self.freeDrawView.delegate = self;
    
    [self loadLastFreeDrawViewState];
    
    [self.view addSubview:_freeDrawView];
}

- (void)loadLastFreeDrawViewState {
    DrawingCurveState *drawingCurveState = [[DrawingCurveState alloc] initWithIsFluorescence:NO];
    IFreeDrawViewState *state = drawingCurveState;
    state.view = self.freeDrawView;
    state.viewController = self;
    self.freeDrawView.viewState = state;
    [self.freeDrawView.viewState onBeginState];
}

#pragma mark - FreeDrawViewDelegate
- (float)getLineWidth {
    return 12;
}

- (NSArray<NSNumber *> *)getColorComponents {
    NSMutableArray<NSNumber *> *components = @[].mutableCopy;
    components[0] = @(1);
    components[1] = @(0);
    components[2] = @(0);
    components[3] = @(1);
    return components;
}
@end
