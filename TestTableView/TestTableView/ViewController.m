//
//  ViewController.m
//  TestTableView
//
//  Created by king on 2020/8/20.
//  Copyright © 2020 0x1306a94. All rights reserved.
//

#import "ViewController.h"

@interface CustomTableView : UITableView <UIGestureRecognizerDelegate>

@end

@implementation CustomTableView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
		UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
		CGPoint contentOffset       = self.contentOffset;
		CGPoint velocity            = [pan velocityInView:pan.view];
		CGAffineTransform transform = self.superview.transform;
		if (transform.ty != 0) {
			return NO;
		}
		if (contentOffset.y == -self.contentInset.top) {
			NSLog(@"%@", NSStringFromCGPoint(velocity));
			// 当前是最顶点
			if (velocity.y > 0) {
				// 向下
				return NO;
			}
		}
	}
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}
@end

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) CustomTableView *tableView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.bgView                 = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
	self.bgView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
	[self.view addSubview:self.bgView];

	self.containerView                     = [[UIView alloc] initWithFrame:CGRectMake(0, 120, CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds) - 120)];
	self.containerView.backgroundColor     = UIColor.orangeColor;
	self.containerView.layer.cornerRadius  = 10;
	self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
	self.containerView.layer.masksToBounds = YES;

	self.topView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 60)];
	self.topView.backgroundColor = UIColor.redColor;

	self.tableView                 = [[CustomTableView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds) - 60) style:UITableViewStylePlain];
	self.tableView.backgroundColor = UIColor.whiteColor;
	self.tableView.dataSource      = self;
	self.tableView.delegate        = self;
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];

	[self.view addSubview:self.containerView];
	[self.containerView addSubview:self.topView];
	[self.containerView addSubview:self.tableView];
	//	self.tableView.scrollEnabled = NO;

	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
	self.panGesture             = pan;
	//	pan.delegate = self;
	//	[pan requireGestureRecognizerToFail:self.tableView.panGestureRecognizer];
	//	[self.tableView.panGestureRecognizer requireGestureRecognizerToFail:pan];
	[self.containerView addGestureRecognizer:pan];
}

- (void)panHandler:(UIPanGestureRecognizer *)pan {
	if (self.tableView.isDragging) {
		return;
	}

	NSLog(@"panHandler: Changed");

	switch (pan.state) {
		case UIGestureRecognizerStateBegan: {
			[pan setTranslation:CGPointZero inView:pan.view];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			CGPoint translation   = [pan translationInView:pan.view];
			CGPoint contentOffset = self.tableView.contentOffset;
			if (contentOffset.y > 0) {
				contentOffset.y -= translation.y;
				[pan setTranslation:CGPointZero inView:pan.view];
				[self.tableView setContentOffset:contentOffset animated:NO];
				return;
			}
			[self updatePresentedViewForTranslation:translation.y];
			break;
		}
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateFailed: {
			CGAffineTransform curTransform = self.containerView.transform;
			CGAffineTransform transform    = CGAffineTransformIdentity;
			if (curTransform.ty >= 200) {
				transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerView.frame));
			}
			/* clang-format off */
			[UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
				self.containerView.transform = transform;
			} completion:^(BOOL finished) {

			}];
			/* clang-format on */
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
		//		NSLog(@"%f", translation);
		[self.tableView setContentOffset:CGPointMake(0, -(translation)) animated:NO];
		return;
	}

	self.containerView.transform = CGAffineTransformMakeTranslation(0, translation);
}
#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//	if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] && self.tableView.panGestureRecognizer.state != UIGestureRecognizerStatePossible) {
////		CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view];
////		return ABS(velocity.y) > ABS(velocity.x);
//		if (self.tableView.contentOffset.y == 0) {
//			return YES;
//		}
//	}
//	return NO;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//	return YES;
//}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	cell.textLabel.text   = @(indexPath.row).stringValue;
	return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//	NSLog(@"contentOffset: %@", NSStringFromCGPoint(scrollView.contentOffset));
	if (scrollView.contentOffset.y <= 0 && scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
		NSLog(@"tableview top");
		scrollView.panGestureRecognizer.state = UIGestureRecognizerStateEnded;
		[scrollView setContentOffset:CGPointZero animated:NO];
		return;
	}
}
@end

