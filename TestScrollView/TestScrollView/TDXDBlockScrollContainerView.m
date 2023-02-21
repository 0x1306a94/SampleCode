//
//  TDXDBlockScrollContainerView.m
//  TestScrollView
//
//  Created by king on 2023/2/20.
//

#import "TDXDBlockScrollContainerView.h"

static void *MainScrollMonitorContext = &MainScrollMonitorContext;
@interface TDXDBlockScrollContainerView ()
@property (nonatomic, strong) UIView *componentsView;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSLayoutConstraint *componentsViewTopConstraint;
@property (nonatomic, strong) NSMapTable<id<TDXDBlockScrollComponent>, NSLayoutConstraint *> *componentHeigtConstraints;
@end

@implementation TDXDBlockScrollContainerView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Initial Methods
- (void)commonInit {
    /*custom view u want draw in here*/
    self.backgroundColor = [UIColor whiteColor];
    self.componentHeigtConstraints = [NSMapTable<id<TDXDBlockScrollComponent>, NSLayoutConstraint *> weakToWeakObjectsMapTable];
    [self setupComponentsView];
    [self setupMainScrollView];
    [self setupMainScrollMonitor];
}

- (void)setupComponentsView {
    UIView *componentsView = [[UIView alloc] initWithFrame:self.bounds];
    componentsView.userInteractionEnabled = NO;
    self.componentsView = componentsView;
    componentsView.backgroundColor = UIColor.clearColor;
    componentsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:componentsView];

    NSLayoutConstraint *componentsViewTopConstraint = [componentsView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0];
    self.componentsViewTopConstraint = componentsViewTopConstraint;
    [NSLayoutConstraint activateConstraints:@[
        componentsViewTopConstraint,
        [componentsView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [componentsView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
        [componentsView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
    ]];
}

- (void)setupMainScrollView {
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.mainScrollView = mainScrollView;
    mainScrollView.backgroundColor = UIColor.clearColor;
    mainScrollView.userInteractionEnabled = NO;
    mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self addSubview:mainScrollView];
    [self addGestureRecognizer:mainScrollView.panGestureRecognizer];

    [NSLayoutConstraint activateConstraints:@[
        [mainScrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [mainScrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
        [mainScrollView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [mainScrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
    ]];
}

- (void)setupMainScrollMonitor {
    [self.mainScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:MainScrollMonitorContext];
}

- (void)updateContentSize {
    CGSize contentSize = self.mainScrollView.contentSize;
    CGPoint contentOffset = self.mainScrollView.contentOffset;

    CGFloat totalHeight = 0;
    for (id<TDXDBlockScrollComponent> component in self.componentsView.subviews) {
        CGFloat height = [component conetntHeight];
        totalHeight += height;
    }

    contentSize.height = totalHeight;
    self.mainScrollView.contentSize = contentSize;
}

- (CGPoint)maxContentOffset {
    CGSize contentSize = self.mainScrollView.contentSize;
    CGRect bounds = self.mainScrollView.bounds;
    UIEdgeInsets contentInset = self.mainScrollView.contentInset;
    return CGPointMake(
        contentSize.width - bounds.size.width + contentInset.right,
        contentSize.height - bounds.size.height + contentInset.bottom);
}

- (void)updateContentOffsetChange:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
    NSLog(@"%f", offsetY);
    //    self.componentsViewTopConstraint.constant = -offsetY;
    //    return;
    if (offsetY <= 0) {
        self.componentsViewTopConstraint.constant = -offsetY;
        for (id<TDXDBlockScrollComponent> component in self.componentsView.subviews) {
            [component updateScrollOffset:0];
        }
        return;
    }

//    CGPoint max1 = [self maxContentOffset];
//    if (offsetY >= max1.y) {
//        CGFloat totalHeight = CGRectGetMaxY(self.componentsView.subviews.lastObject.frame);
//        CGFloat fixY = offsetY - max1.y;
//        CGFloat top = totalHeight - CGRectGetHeight(self.frame) + fixY;
//        self.componentsViewTopConstraint.constant = -top;
//        return;
//    }
    
    CGSize viewportSize = self.frame.size;
    CGFloat subviewOffset = 0;

    CGFloat unconsumedOffsetY = offsetY;
//    id<TDXDBlockScrollComponent> findComponent = nil;
    for (id<TDXDBlockScrollComponent> component in self.componentsView.subviews) {
        CGFloat height = [component conetntHeight];
        CGFloat maxConsumableOffsetY = MAX(0, (height - viewportSize.height));
        CGFloat consumedOffsetY = MIN(unconsumedOffsetY, maxConsumableOffsetY);
        unconsumedOffsetY -= consumedOffsetY;
        [component updateScrollOffset:consumedOffsetY];
        if (unconsumedOffsetY > 0) {
            // Scroll up the next element before scrolling its contents.
            maxConsumableOffsetY = MIN(height, viewportSize.height);
            consumedOffsetY = MIN(unconsumedOffsetY, maxConsumableOffsetY);
            unconsumedOffsetY -= consumedOffsetY;
            subviewOffset += consumedOffsetY;
        }
    }
    
    NSLog(@"offset: %@", @(subviewOffset));
    
    for (id<TDXDBlockScrollComponent> component in self.componentsView.subviews) {
        ((UIView *) component).transform = CGAffineTransformMakeTranslation(0, -subviewOffset);
    }
    
//    CGFloat totalHeight = 0;
//    for (id<TDXDBlockScrollComponent> component in self.componentsView.subviews) {
//        CGFloat height = [component conetntHeight];
//        CGPoint max = [component maxContentOffset];
//        if (offsetY >= totalHeight && offsetY < (totalHeight + height)) {
//            findComponent = component;
//            break;
//        }
//        totalHeight += height;
//    }
//    if (findComponent) {
//        CGFloat fixOffset = (offsetY - totalHeight);
//        [findComponent updateScrollOffset:fixOffset];
//    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (context != MainScrollMonitorContext) {
        return;
    }

    CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
    [self updateContentOffsetChange:contentOffset];
}

// MARK: - public
- (void)addComponents:(NSArray<id<TDXDBlockScrollComponent>> *)components {
    BOOL needUpdateContentSize = NO;
    for (id<TDXDBlockScrollComponent> component in components) {
        NSCParameterAssert([component isKindOfClass:UIView.class]);
        NSCParameterAssert([component conformsToProtocol:@protocol(TDXDBlockScrollComponent)]);
        UIView *view = (UIView *)component;
        if ([self.componentsView.subviews containsObject:view]) {
            continue;
        }

        needUpdateContentSize = YES;

        UIView *lastView = (UIView *)self.componentsView.subviews.lastObject;

        [self.componentsView addSubview:view];

        view.translatesAutoresizingMaskIntoConstraints = NO;

        CGFloat conetntHeight = [component conetntHeight];
        CGFloat height = MIN(conetntHeight, CGRectGetHeight(self.frame));
        NSLayoutConstraint *heightConstraint = [view.heightAnchor constraintEqualToConstant:height];

        if (lastView) {
            [NSLayoutConstraint activateConstraints:@[
                [view.leadingAnchor constraintEqualToAnchor:self.componentsView.leadingAnchor constant:0],
                [view.trailingAnchor constraintEqualToAnchor:self.componentsView.trailingAnchor constant:0],
                [view.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:0],
                heightConstraint,
            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [view.leadingAnchor constraintEqualToAnchor:self.componentsView.leadingAnchor constant:0],
                [view.trailingAnchor constraintEqualToAnchor:self.componentsView.trailingAnchor constant:0],
                [view.topAnchor constraintEqualToAnchor:self.componentsView.topAnchor constant:0],
                heightConstraint,
            ]];
        }
        [self.componentHeigtConstraints setObject:heightConstraint forKey:component];
    }

    if (needUpdateContentSize) {
        [self updateContentSize];
    }

    [self updateContentOffsetChange:self.mainScrollView.contentOffset];
}
@end
