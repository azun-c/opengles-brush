//
//  ViewController.m
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import "ViewController.h"
#import "DrawingCurveState.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    FreeDrawView *freeDrawView = [[FreeDrawView alloc] initWithFrame:self.view.bounds];
    freeDrawView.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.9];
    
    BaseViewState *state = [[DrawingCurveState alloc] init];
    state.view = freeDrawView;
    freeDrawView.viewState = state;
    [state onBeginState];
    
    [self.view addSubview:freeDrawView];
}

@end
