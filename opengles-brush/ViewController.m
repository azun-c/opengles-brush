//
//  ViewController.m
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import "ViewController.h"
#import "SelectingItemState.h"
#import "DrawingCurveState.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.freeDrawView = [[FreeDrawView alloc] initWithFrame:self.view.bounds];
    [self loadLastFreeDrawViewState];
    [self.view addSubview:_freeDrawView];
}

- (void)loadLastFreeDrawViewState {
    IFreeDrawViewState *state = [[DrawingCurveState alloc] init];
    state.view = self.freeDrawView;
    self.freeDrawView.viewState = state;
    [self.freeDrawView.viewState onBeginState];
}

@end
