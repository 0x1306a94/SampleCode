//
//  ViewController.m
//  TestScrollView2
//
//  Created by king on 2023/2/20.
//

#import "ViewController.h"

@interface CustomRichTextScrollView : UIScrollView
@end

@implementation CustomRichTextScrollView

@end

@interface CustomMainScrollView : UIScrollView
@end

@implementation CustomMainScrollView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < 0) {
        return false;
    }
    return [super pointInside:point withEvent:event];
}

@end
@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) CustomRichTextScrollView *richTextScrollView;
@property (nonatomic, strong) CustomMainScrollView *listScrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CustomRichTextScrollView *richTextScrollView = [[CustomRichTextScrollView alloc] initWithFrame:self.view.bounds];
    richTextScrollView.scrollsToTop = NO;
    richTextScrollView.showsVerticalScrollIndicator = NO;
    richTextScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    richTextScrollView.backgroundColor = UIColor.orangeColor;
    UIView *richTextItemView = [[UIView alloc] initWithFrame:self.view.bounds];
    richTextItemView.backgroundColor = UIColor.yellowColor;
    [richTextScrollView addSubview:richTextItemView];

    self.richTextScrollView = richTextScrollView;

    CustomMainScrollView *listScrollView = [[CustomMainScrollView alloc] initWithFrame:self.view.bounds];
    //    listScrollView.scrollsToTop = NO;
    listScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    listScrollView.backgroundColor = UIColor.clearColor;

    UIView *listItemView = [[UIView alloc] initWithFrame:self.view.bounds];
    listItemView.backgroundColor = UIColor.cyanColor;
    [listScrollView addSubview:listItemView];
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

    [richTextScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    [listScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

// 这里epsilon 不能用 DBL_EPSILON
#define __FLOAT_EQ_ZERO__(val) (((val) >= -FLT_EPSILON) && ((val) <= FLT_EPSILON))

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (object == self.listScrollView) {
        CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat fixOffset = contentOffset.y + self.listScrollView.contentInset.top;
        CGFloat old = self.richTextScrollView.contentOffset.y;
        CGFloat diff = fabs(fixOffset - old);
        //    NSLog(@"%f ~> %f", offset, fixOffset);
        if (!__FLOAT_EQ_ZERO__(diff)) {
            [self.richTextScrollView setContentOffset:CGPointMake(0, fixOffset) animated:NO];
        }

        return;
    }

    if (object == self.richTextScrollView) {
        CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat fixOffset = contentOffset.y + (-self.listScrollView.contentInset.top);
        //        NSLog(@"%f ~> %f", offset, fixOffset);
        CGFloat old = self.listScrollView.contentOffset.y;
        CGFloat diff = fabs(fixOffset - old);
        if (!__FLOAT_EQ_ZERO__(diff)) {
            [self.listScrollView setContentOffset:CGPointMake(0, fixOffset) animated:NO];
        }
        return;
    }
}
#undef __CGFLOAT_EQ_ZERO__
@end
