//
//  ViewController.m
//  CustomScrollBar
//
//  Created by king on 2022/9/19.
//

#import "ViewController.h"

CGFloat const kScrollBarNormalWidth = 45;
CGFloat const kScrollBarExpandWidth = 120;
CGFloat const kScrollBarHeight = 40;

@interface UIScrollView (TDXDContentOffset)
- (CGPoint)tdxd_minContentOffset;

- (CGPoint)tdxd_maxContentOffset;
@end

@implementation UIScrollView (TDXDContentOffset)
- (CGPoint)tdxd_minContentOffset {
    return CGPointMake(
        -self.contentInset.left,
        -self.contentInset.top);
}

- (CGPoint)tdxd_maxContentOffset {
    return CGPointMake(
        self.contentSize.width - self.bounds.size.width + self.contentInset.right,
        self.contentSize.height - self.bounds.size.height + self.contentInset.bottom);
}
@end

typedef struct {
    CGPoint startPoint;
    CGPoint contentOffset;
    CGRect startFrame;
} ScrollBarStart;

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL enableScrollBar;
@property (nonatomic, assign) ScrollBarStart barStartInfo;
@property (nonatomic, strong) UIView *scrollBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width * 0.2);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = UIColor.yellowColor;
    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];

    self.collectionView.contentInset = UIEdgeInsetsMake(40, 0, 40, 0);
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    //    self.collectionView.userInteractionEnabled = NO;
    [self.view addSubview:self.collectionView];

    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];

    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scrollBar) {
        return;
    }
    self.scrollBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.collectionView.frame), 0, kScrollBarExpandWidth, kScrollBarHeight)];
    self.scrollBar.backgroundColor = UIColor.redColor;
    [self.collectionView addSubview:self.scrollBar];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    //    longGes.delaysTouchesBegan = YES;
    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:pan];
    [self.scrollBar addGestureRecognizer:pan];
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture {
    UIGestureRecognizerState state = gesture.state;
    switch (state) {
        case UIGestureRecognizerStateBegan: {

            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScroll:) object:nil];

            CGRect frame = self.scrollBar.frame;
            frame.origin.x = CGRectGetWidth(self.collectionView.frame) - kScrollBarExpandWidth;
            [UIView animateWithDuration:0.15 animations:^{
                self.scrollBar.frame = frame;
            }];
            
            self.enableScrollBar = NO;
            self.barStartInfo = (ScrollBarStart){
                .startPoint = [gesture locationInView:self.view],
                .contentOffset = self.collectionView.contentOffset,
                .startFrame = self.scrollBar.frame,
            };
            NSLog(@"start: %f %f", self.barStartInfo.contentOffset.y, self.barStartInfo.startFrame.origin.y);
            self.enableScrollBar = YES;
            [gesture setTranslation:CGPointZero inView:self.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.enableScrollBar) {
                return;
            }
            //            return;
            CGPoint startPoint = self.barStartInfo.startPoint;
            CGPoint contentOffset = self.barStartInfo.contentOffset;
            CGRect startFrame = self.barStartInfo.startFrame;

            CGPoint location = [gesture locationInView:self.view];
            CGPoint translation = [gesture translationInView:self.view];
            // 手势滑动的距离
            CGFloat deltaY = translation.y;  //location.y - startPoint.y;
            NSLog(@"%f", deltaY);

            startFrame.origin.y += deltaY;

            CGPoint minContentOffset = [self.collectionView tdxd_minContentOffset];
            CGPoint maxContentOffset = [self.collectionView tdxd_maxContentOffset];
            UIEdgeInsets contentInset = self.collectionView.contentInset;

            CGFloat superHeight = CGRectGetHeight(self.collectionView.frame);
            CGFloat barHeight = CGRectGetHeight(self.scrollBar.frame);

            // 1.0
            //            CGFloat barLenght = (superHeight - barHeight);
            //            CGFloat minBarY = MAX(0, startFrame.origin.y - contentOffset.y);
            //            CGFloat progress = MAX(0, MIN(1.0, minBarY / barLenght));
            //
            //            CGFloat newOffsetY = (fabs(minContentOffset.y) + maxContentOffset.y) * progress - fabs(minContentOffset.y);
            //
            //            NSLog(@"progress: %f %f %f", progress, minBarY, newOffsetY);
            //
            //            contentOffset.y = newOffsetY;
            //            startFrame.origin.y = newOffsetY + progress * barLenght;

            // 3.0
            maxContentOffset.y += contentInset.top;
            contentOffset.y += contentInset.top;

            CGFloat barLenght = (superHeight - barHeight - contentInset.top - contentInset.bottom);
            CGFloat minBarY = MAX(0, startFrame.origin.y - contentOffset.y);
            CGFloat progress = MAX(0, MIN(1.0, minBarY / barLenght));

            CGFloat newOffsetY = progress * maxContentOffset.y - contentInset.top;

            NSLog(@"progress: %f %f %f", progress, minBarY, newOffsetY);

            contentOffset.y = newOffsetY;
            startFrame.origin.y = newOffsetY + contentInset.top + progress * barLenght;
            self.scrollBar.frame = startFrame;
            [self.collectionView setContentOffset:contentOffset animated:NO];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.enableScrollBar = NO;
            [self performSelector:@selector(stopScroll:) withObject:nil afterDelay:1.0];
            break;
        }
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {

    if (self.scrollBar == nil || self.enableScrollBar) {
        return;
    }

    CGPoint old = [change[NSKeyValueChangeOldKey] CGPointValue];
    CGPoint new = [change[NSKeyValueChangeNewKey] CGPointValue];

    CGFloat superHeight = CGRectGetHeight(self.collectionView.frame);
    CGFloat barHeight = CGRectGetHeight(self.scrollBar.frame);

    CGPoint minContentOffset = [self.collectionView tdxd_minContentOffset];
    CGPoint maxContentOffset = [self.collectionView tdxd_maxContentOffset];
    UIEdgeInsets contentInset = self.collectionView.contentInset;

    // 1.0
    //  CGFloat newOffsetY = (fabs(minContentOffset.y) + maxContentOffset.y) * progress - fabs(minContentOffset.y);
    //    CGFloat progress = MAX(0, MIN(1.0, new.y / maxContentOffset.y));
    //    CGFloat barLenght = (superHeight - barHeight);

    // 2.0
    //    CGFloat progress = MAX(0, MIN(1.0, (new.y + fabs(minContentOffset.y)) / (fabs(minContentOffset.y) + fabs(maxContentOffset.y))));
    //    CGFloat barLenght = (superHeight - barHeight - contentInset.top - contentInset.bottom);

    // 3.0
    maxContentOffset.y += contentInset.top;
    new.y += contentInset.top;
    CGFloat progress = MAX(0, MIN(1.0, new.y / maxContentOffset.y));
    CGFloat barLenght = (superHeight - barHeight - contentInset.top - contentInset.bottom);

    CGRect frame = self.scrollBar.frame;
    CGFloat fixY = barLenght * progress;
    frame.origin.y = fixY + new.y;
    self.scrollBar.frame = frame;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor orangeColor];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = CGRectGetWidth(collectionView.frame);
    CGFloat h = ceil(w * 0.2);
    return CGSizeMake(w, h);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGRect frame = self.scrollBar.frame;
    frame.origin.x = CGRectGetWidth(scrollView.frame) - kScrollBarNormalWidth;
    [UIView animateWithDuration:0.15 animations:^{
        self.scrollBar.frame = frame;
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        return;
    }
    BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (!dragToDragStop) {
        return;
    }
    [self stopScroll:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (!scrollToScrollStop) {
        return;
    }
    [self stopScroll:nil];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScroll:) object:nil];
    [self performSelector:@selector(stopScroll:) withObject:nil afterDelay:1.0];
}

- (void)stopScroll:(NSNumber *)stub {
    if (self.enableScrollBar) {
        return;
    }
    CGRect frame = self.scrollBar.frame;
    frame.origin.x = CGRectGetWidth(self.collectionView.frame);
    [UIView animateWithDuration:0.15 animations:^{
        self.scrollBar.frame = frame;
    } completion:^(BOOL finished){
    }];
}
@end

