//
//  ViewController.m
//  testxxx
//
//  Created by king on 2021/8/17.
//

#import "ViewController.h"

#import "KKCollectionViewStayCenterLayout.h"

@interface CustomCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *indexLabel;
@end

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
//@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, strong) KKCollectionViewStayCenterLayout *layout;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    KKCollectionViewStayCenterLayout *layout = [[KKCollectionViewStayCenterLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width - 40, 260);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    layout.pageEnable = YES;
    self.layout = layout;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300) collectionViewLayout:layout];
    self.collectionView.backgroundColor = UIColor.orangeColor;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:CustomCollectionViewCell.class forCellWithReuseIdentifier:@"cell"];

    [self.view addSubview:self.collectionView];

    UIButton *directionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [directionButton setTitle:@"切换方向为 -> 垂直" forState:UIControlStateNormal];
    [directionButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [directionButton addTarget:self action:@selector(directionButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *pageEnableButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pageEnableButton setTitle:@"分页 -> 关闭" forState:UIControlStateNormal];
    [pageEnableButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [pageEnableButton addTarget:self action:@selector(pageEnableButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:directionButton];
    [self.view addSubview:pageEnableButton];

    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    directionButton.translatesAutoresizingMaskIntoConstraints = NO;
    pageEnableButton.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.heightAnchor constraintEqualToConstant:300],
        [self.collectionView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [directionButton.topAnchor constraintEqualToAnchor:self.collectionView.bottomAnchor constant:30],
        [directionButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [pageEnableButton.topAnchor constraintEqualToAnchor:directionButton.bottomAnchor constant:15],
        [pageEnableButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.layout.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame) - 40, CGRectGetHeight(self.collectionView.frame) - 40);
    [self.layout invalidateLayout];
    [self.collectionView reloadData];
}

- (void)directionButtonAction:(UIButton *)directionButton {
    KKCollectionViewStayCenterLayout *layout = [self.layout copy];
    if (layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [directionButton setTitle:@"切换方向为 -> 垂直" forState:UIControlStateNormal];
    } else {
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        [directionButton setTitle:@"切换方向为 -> 水平" forState:UIControlStateNormal];
    }
    [self.layout invalidateLayout];
    __weak typeof(self) weakSelf = self;
    [self.collectionView setCollectionViewLayout:layout animated:YES completion:^(BOOL finished) {
        CGPoint targetPoint = [weakSelf.collectionView convertPoint:weakSelf.collectionView.center fromView:weakSelf.view];
        UICollectionViewScrollPosition position = UICollectionViewScrollPositionNone;
        if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            position = UICollectionViewScrollPositionCenteredHorizontally;
            targetPoint.y = 0;
        } else {
            position = UICollectionViewScrollPositionCenteredVertically;
            targetPoint.x = 0;
        }
        NSIndexPath *path = [weakSelf.collectionView indexPathForItemAtPoint:targetPoint];
        if (path) {
            [weakSelf.collectionView scrollToItemAtIndexPath:path atScrollPosition:position animated:YES];
        } else {
            [weakSelf fullStopSliding];
        }
        weakSelf.layout = layout;
    }];
}

- (void)pageEnableButtonAction:(UIButton *)pageEnableButton {
    self.layout.pageEnable = !self.layout.pageEnable;
    if (self.layout.pageEnable) {
        [pageEnableButton setTitle:@"分页 -> 关闭" forState:UIControlStateNormal];
    } else {
        [pageEnableButton setTitle:@"分页 -> 打开" forState:UIControlStateNormal];
    }
    [self.layout invalidateLayout];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.indexLabel.text = @(indexPath.item).stringValue;

    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.layout.lastContentOffset = scrollView.contentOffset;
    //    self.layout.lastIndexPath = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
    //    NSLog(@"lastIndexPath: %@", self.layout.lastIndexPath);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self fullStopSliding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self fullStopSliding];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self fullStopSliding];
}

- (void)fullStopSliding {
    self.layout.lastContentOffset = self.collectionView.contentOffset;
}
@end

@implementation CustomCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentView.backgroundColor = UIColor.yellowColor;

    self.indexLabel = [[UILabel alloc] init];
    self.indexLabel.textColor = UIColor.blackColor;
    self.indexLabel.font = [UIFont systemFontOfSize:68 weight:UIFontWeightSemibold];
    [self.contentView addSubview:self.indexLabel];
    self.indexLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.indexLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.indexLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
    ]];
}

@end

