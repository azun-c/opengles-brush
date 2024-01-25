//
//  ViewController.h
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#import <UIKit/UIKit.h>
#import "FreeDrawView.h"

@interface ViewController : UIViewController<FreeDrawViewDelegate>

@property (nonatomic, strong, nullable) FreeDrawView *freeDrawView;
@end

