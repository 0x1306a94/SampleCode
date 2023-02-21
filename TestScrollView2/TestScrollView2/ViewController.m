//
//  ViewController.m
//  TestScrollView2
//
//  Created by king on 2023/2/20.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *richTextScrollView;
@property (nonatomic, strong) UIScrollView *listScrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIScrollView *richTextScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    richTextScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    richTextScrollView.backgroundColor = UIColor.orangeColor;
    UIView *richTextItemView = [[UIView alloc] initWithFrame:self.view.bounds];
    richTextItemView.backgroundColor = UIColor.yellowColor;
    [richTextScrollView addSubview:richTextItemView];

    self.richTextScrollView = richTextScrollView;
    UIScrollView *listScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    listScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    listScrollView.backgroundColor = UIColor.clearColor;

    UIView *listItemView = [[UIView alloc] initWithFrame:self.view.bounds];
    listItemView.backgroundColor = UIColor.cyanColor;
    [listScrollView addSubview:listItemView];
    listScrollView.delegate = self;
    self.listScrollView = listScrollView;

    [self.view addSubview:richTextScrollView];
    [self.view addSubview:listScrollView];

    CGFloat richTextContentHeight = CGRectGetHeight(self.view.bounds) * 1.5;
    CGFloat listContentHeight = CGRectGetHeight(self.view.bounds) * 3.0;
    richTextScrollView.contentSize = CGSizeMake(0, richTextContentHeight);
    listScrollView.contentSize = CGSizeMake(0, listContentHeight);

    richTextScrollView.contentInset = UIEdgeInsetsMake(0, 0, listContentHeight, 0);
    listScrollView.contentInset = UIEdgeInsetsMake(richTextContentHeight, 0, 0, 0);
    listScrollView.contentOffset = CGPointMake(0, -richTextContentHeight);
}

// MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;

    CGFloat fixOffset = offset + scrollView.contentInset.top;
    NSLog(@"%f ~> %f", offset, fixOffset);
    [self.richTextScrollView setContentOffset:CGPointMake(0, fixOffset) animated:NO];
}
@end
