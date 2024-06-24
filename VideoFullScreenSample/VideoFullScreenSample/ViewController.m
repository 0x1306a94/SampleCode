//
//  ViewController.m
//  VideoFullScreenSample
//
//  Created by king on 2024/6/20.
//

#import "ViewController.h"

#import "KKPlayerLandscapeController.h"

#import "KKPlayerLandscapeTransition.h"

#import <Masonry/Masonry.h>

@interface KKTransitionAnimationView : UIView

@end

@implementation KKTransitionAnimationView

- (void)layoutSubviews {
    [super layoutSubviews];

    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end

@interface ViewController () <KKPlayerLandscapeControllerDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) KKTransitionAnimationView *transitionAnimationView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.lightGrayColor;

    self.containerView = [UIView new];
    self.containerView.backgroundColor = UIColor.orangeColor;

    [self.view addSubview:self.containerView];

    self.transitionAnimationView = [KKTransitionAnimationView new];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = ceil(width / 16.0 * 9.0);
    CGFloat top = 210;
#if USE_AUTOLAYOUT
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
        make.top.mas_equalTo(self.view.mas_top).offset(top);
    }];
#else
    self.containerView.frame = CGRectMake(0, top, width, height);
#endif

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = UIColor.redColor;
    [button setTitle:@"全屏" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.containerView.mas_centerX);
    }];
}

- (void)buttonAction:(UIButton *)sender {
    KKPlayerLandscapeController *vc = [[KKPlayerLandscapeController alloc] initWithSourceView:self.containerView delegate:self];
    [self presentViewController:vc animated:YES completion:^{

    }];
}

// MARK: - KKPlayerLandscapeControllerDelegate
- (__kindof UIView *)onsiteExperiencePostFeedImmersionPlayerLandscapeControllerAnimationView:(KKPlayerLandscapeController *)controller sourceFrame:(CGRect *)sourceFrame {
#if USE_AUTOLAYOUT
    self.transitionAnimationView.backgroundColor = UIColor.redColor;
    CGRect frame = self.containerView.frame;
    [self.view addSubview:self.transitionAnimationView];
    [self.transitionAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(frame.origin.x);
        make.top.mas_equalTo(self.view.mas_top).offset(frame.origin.y);
        make.size.mas_equalTo(frame.size);
    }];

    [self.view layoutIfNeeded];
    *sourceFrame = [self.transitionAnimationView convertRect:self.transitionAnimationView.bounds toView:self.view.window];
    return self.transitionAnimationView;
#else
    self.transitionAnimationView.backgroundColor = UIColor.redColor;
    CGRect frame = self.containerView.frame;
    [self.view addSubview:self.transitionAnimationView];
    self.transitionAnimationView.frame = frame;
    *sourceFrame = [self.containerView convertRect:self.containerView.bounds toView:self.view.window];
    return self.transitionAnimationView;
#endif
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
