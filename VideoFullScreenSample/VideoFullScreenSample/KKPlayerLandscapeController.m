//
//  KKPlayerLandscapeController.m
//  ShowStart
//
//  Created by king on 2024/6/20.
//  Copyright © 2024 taihe. All rights reserved.
//

#import "KKPlayerLandscapeController.h"

#import "KKPlayerLandscapeController+Private.h"

#import "KKPlayerLandscapeTransition.h"

#import <Masonry/Masonry.h>

@interface KKPlayerLandscapeController ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) __kindof UIView *sourceView;
@property (nonatomic, assign) CGRect sourceRect;
@property (nonatomic, weak, nullable) id<KKPlayerLandscapeControllerDelegate> delegate;
@property (nonatomic, assign) BOOL performFullScreen;

@property (nonatomic, strong) KKPlayerLandscapeTransition *landscapeTransition;

@property (nonatomic, strong, nullable) void (^portraitEnd)(void);
@end

@implementation KKPlayerLandscapeController
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}
#endif

- (instancetype)initWithSourceView:(__kindof UIView *)sourceView delegate:(id<KKPlayerLandscapeControllerDelegate>)delegate {
    NSCParameterAssert(delegate != nil);
    if (self == [super initWithNibName:nil bundle:nil]) {
        _sourceView = sourceView;
        _delegate = delegate;
        _performFullScreen = NO;
        _landscapeTransition = [KKPlayerLandscapeTransition new];

        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.transitioningDelegate = _landscapeTransition;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor;
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupPlayerEvent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupSubViews {
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)setupPlayerEvent {
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    __weak typeof(self) weakSelf = self;
    void (^dismissHandler)(void) = self.dismissHandler;
    [weakSelf dismissViewControllerAnimated:YES completion:^{
        !dismissHandler ?: dismissHandler();
    }];
}
#pragma mark - Transitions
- (__kindof UIView *)destinationContainerView {
    return self.containerView;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - getters and setters
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor redColor];
    }
    return _containerView;
}

@end
