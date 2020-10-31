//
//  CommentListViewController.m
//  TestTableView
//
//  Created by 0x1306a94 on 2020/10/31.
//  Copyright © 2020 0x1306a94. All rights reserved.
//

#import "CommentListViewController.h"

#import "CommentListTableView.h"

@interface CommentListViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) CommentListTableView *tableView;
@property (nonatomic, assign) BOOL panGestureEnable;
@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor;

    self.containerView                     = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(UIScreen.mainScreen.bounds) * 0.3, CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds) * 0.7)];
    self.containerView.backgroundColor     = UIColor.orangeColor;
    self.containerView.layer.cornerRadius  = 10;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.containerView.layer.masksToBounds = YES;

    self.headerView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 100)];
    self.headerView.backgroundColor = UIColor.redColor;

    self.tableView                 = [[CommentListTableView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds) - 100) style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.dataSource      = self;
    self.tableView.delegate        = self;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];

    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.headerView];
    [self.containerView addSubview:self.tableView];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    pan.delegate                = self;
    self.panGestureEnable       = NO;
    [self.containerView addGestureRecognizer:pan];

    self.view.hidden             = YES;
    CGAffineTransform transform  = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerView.frame));
    self.containerView.transform = transform;
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)pan {
    if (self.tableView.isDragging) {
        return;
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            [pan setTranslation:CGPointZero inView:pan.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation   = [pan translationInView:pan.view];
            CGPoint contentOffset = self.tableView.contentOffset;
            if (contentOffset.y > 0) {
                // 这段代码用于处理, tableView 已经往上滑动一部分后
                // 从 headerView 区域 触发手势, 无法滑动 tableView
                // 还有另一个功能就是,用于修正 tableView
                contentOffset.y -= translation.y;
                [pan setTranslation:CGPointZero inView:pan.view];
                [self.tableView setContentOffset:contentOffset animated:NO];
                return;
            }

            // 如果去掉这段代码,会出现 突然往下跳动, 具体现象可以,注释掉这部分代码
            if (contentOffset.y == 0.0 && !self.panGestureEnable) {
                self.panGestureEnable = YES;
                [pan setTranslation:CGPointZero inView:pan.view];
                return;
            }

            [self updatePresentedViewForTranslation:translation.y];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            self.panGestureEnable          = NO;
            CGAffineTransform curTransform = self.containerView.transform;
            CGAffineTransform transform    = CGAffineTransformIdentity;
            // 200 这个临界值可以修改为自己项目合适的值
            if (curTransform.ty >= 200) {
                [self hide];
            } else {
                /* clang-format off */
                [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut| UIViewAnimationOptionAllowUserInteraction animations:^{
                    self.containerView.transform = transform;
                } completion:^(BOOL finished) {

                }];
                /* clang-format on */
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark - updatePresentedViewForTranslation
- (void)updatePresentedViewForTranslation:(CGFloat)translation {
    if (translation < 0) {
        self.containerView.transform = CGAffineTransformIdentity;
        [self.tableView setContentOffset:CGPointMake(0, -translation) animated:NO];
        return;
    }

    self.containerView.transform = CGAffineTransformMakeTranslation(0, translation);
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 关键点: 允许同时识别多个手势
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text   = @(indexPath.row).stringValue;
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 关键点: 当 tableView 下滑到顶以后, 交由 containerView 的手势处理
    // 这样就不需要下滑到顶以后,需要松开手指 再次触发手势
    if (scrollView.contentOffset.y <= -scrollView.contentInset.top && scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"tableview top");
        scrollView.panGestureRecognizer.state = UIGestureRecognizerStateEnded;
        [scrollView setContentOffset:CGPointZero animated:NO];
        return;
    }
}

#pragma mark - public method
- (void)show {
    self.view.hidden            = NO;
    CGAffineTransform transform = CGAffineTransformIdentity;
    /* clang-format off */
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut| UIViewAnimationOptionAllowUserInteraction animations:^{
        self.containerView.transform = transform;
    } completion:^(BOOL finished) {

    }];
    /* clang-format on */
}

- (void)hide {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerView.frame));
    /* clang-format off */
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut| UIViewAnimationOptionAllowUserInteraction animations:^{
        self.containerView.transform = transform;
    } completion:^(BOOL finished) {
        if (finished) {
            self.view.hidden = YES;
        }
    }];
    /* clang-format on */
}
@end

