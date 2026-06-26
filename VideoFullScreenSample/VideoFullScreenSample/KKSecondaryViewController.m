//
//  KKSecondaryViewController.m
//  VideoFullScreenSample
//
//  Created by king on 2026/6/26.
//

#import "KKSecondaryViewController.h"

@interface KKSecondaryViewController ()

@end

@implementation KKSecondaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.cyanColor;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
