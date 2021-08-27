//
//  KKCollectionViewStayCenterLayout.m
//  ShowStart
//
//  Created by king on 2021/7/22.
//  Copyright © 2021 taihe. All rights reserved.
//

#import "KKCollectionViewStayCenterLayout.h"

@interface KKCollectionViewStayCenterLayout ()
@property (nonatomic, assign) NSInteger totalCount;
@end
@implementation KKCollectionViewStayCenterLayout
- (instancetype)init {
    if (self == [super init]) {
        self.totalCount = 0;
        self.pageEnable = NO;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    if (!self.collectionView.dataSource) {
        self.totalCount = 0;
        return;
    }
    self.lastContentOffset = CGPointZero;
    self.totalCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    if (self.totalCount == 0) {
        return proposedContentOffset;
    }
    //proposedContentOffset是没有设置对齐时本应该停下的位置（collectionView落在屏幕左上角的点坐标）
    CGFloat offsetAdjustment = MAXFLOAT;  //初始化调整距离为无限大

    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {

        CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);                                      //collectionView落在屏幕中点的x坐标
        CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);  //collectionView落在屏幕的大小
        NSArray *array = [super layoutAttributesForElementsInRect:targetRect];                                                                        //获得落在屏幕的所有cell的属性

        //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
        UICollectionViewLayoutAttributes *centerLayout = nil;
        for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
            CGFloat itemHorizontalCenter = layoutAttributes.center.x;
            if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter;
                centerLayout = layoutAttributes;
            }
        }

        CGPoint adjustPoint = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
#if DEBUG
        NSLog(@"targetContentOffset H: %f %f %f %f", self.lastContentOffset.x, proposedContentOffset.x, velocity.x, adjustPoint.x);
#endif
        if (self.pageEnable && centerLayout != nil) {
            //            do {
            //                UIEdgeInsets contentInset = self.collectionView.contentInset;
            //                if (adjustPoint.x <= -contentInset.left && velocity.x <= 0) {
            //                    break;
            //                }
            //
            //                CGFloat maxOffsetX = (self.collectionView.contentSize.width - self.itemSize.width - self.minimumLineSpacing - contentInset.left - contentInset.right);
            //
            //                if (adjustPoint.x > maxOffsetX && velocity.x <= 0) {
            //                    adjustPoint.x = self.lastContentOffset.x - self.itemSize.width - self.minimumLineSpacing;
            //                    break;
            //                }
            //
            //                if (adjustPoint.x > maxOffsetX) {
            //                    break;
            //                }
            //
            //                if (ABS(adjustPoint.x - self.lastContentOffset.x) > self.itemSize.width) {
            //                    break;
            //                }
            //
            //                if (ceil(proposedContentOffset.x) > ceil(self.lastContentOffset.x)) {
            //                    // 往右
            //                    adjustPoint.x = self.lastContentOffset.x + self.itemSize.width + self.minimumLineSpacing;
            //                } else if (ceil(proposedContentOffset.x) < ceil(self.lastContentOffset.x)) {
            //                    adjustPoint.x = self.lastContentOffset.x - self.itemSize.width - self.minimumLineSpacing;
            //                }
            //            } while (0);

            do {
                if (ABS(adjustPoint.x - self.lastContentOffset.x) > self.itemSize.width) {
                    break;
                }
                NSIndexPath *path = centerLayout.indexPath;
                NSIndexPath *indexPath = nil;
                if (velocity.x > 0.0) {
                    // 往右
                    indexPath = [NSIndexPath indexPathForItem:path.item + 1 inSection:path.section];
                } else if (velocity.x < 0.0) {
                    // 往左
                    indexPath = [NSIndexPath indexPathForItem:path.item - 1 inSection:path.section];
                }
                if (!indexPath) {
                    break;
                }
                UICollectionViewLayoutAttributes *layout = [self layoutAttributesForItemAtIndexPath:indexPath];
                if (!layout) {
                    break;
                }
                CGFloat edge = (CGRectGetWidth(self.collectionView.bounds) - CGRectGetWidth(layout.frame)) * 0.5;
                adjustPoint.x = layout.frame.origin.x - edge;
            } while (0);
        }
        return adjustPoint;
    }

    CGFloat verticalCenter = proposedContentOffset.y + (CGRectGetHeight(self.collectionView.bounds) / 2.0);                                     //collectionView落在屏幕中点的y坐标
    CGRect targetRect = CGRectMake(0, proposedContentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);  //collectionView落在屏幕的大小
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];                                                                      //获得落在屏幕的所有cell的属性

    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    UICollectionViewLayoutAttributes *centerLayout = nil;
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemVerticalCenter = layoutAttributes.center.y;
        if (ABS(itemVerticalCenter - verticalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemVerticalCenter - verticalCenter;
            centerLayout = layoutAttributes;
        }
    }
    //调整
    CGPoint adjustPoint = CGPointMake(proposedContentOffset.x, proposedContentOffset.y + offsetAdjustment);
#if DEBUG
    NSLog(@"targetContentOffset H: %f %f %f %f", self.lastContentOffset.y, proposedContentOffset.y, velocity.y, adjustPoint.y);
#endif
    if (self.pageEnable) {
        //        do {
        //            UIEdgeInsets contentInset = self.collectionView.contentInset;
        //            if (adjustPoint.y <= -contentInset.top && velocity.y <= 0) {
        //                break;
        //            }
        //
        //            CGFloat maxOffsetY = (self.collectionView.contentSize.height - self.itemSize.height - self.minimumLineSpacing - contentInset.top - contentInset.bottom);
        //
        //            if (adjustPoint.y > maxOffsetY && velocity.y <= 0) {
        //                adjustPoint.y = self.lastContentOffset.y - self.itemSize.height - self.minimumLineSpacing;
        //                break;
        //            }
        //
        //            if (adjustPoint.y > maxOffsetY) {
        //                break;
        //            }
        //
        //            if (ABS(adjustPoint.y - self.lastContentOffset.y) > self.itemSize.height) {
        //                break;
        //            }
        //
        //            if (ceil(proposedContentOffset.y) > ceil(self.lastContentOffset.y)) {
        //                // 往下
        //                adjustPoint.y = self.lastContentOffset.y + self.itemSize.height + self.minimumLineSpacing;
        //            } else if (ceil(proposedContentOffset.y) < ceil(self.lastContentOffset.y)) {
        //                adjustPoint.y = self.lastContentOffset.y - self.itemSize.height - self.minimumLineSpacing;
        //            }
        //        } while (0);
        do {
            if (ABS(adjustPoint.y - self.lastContentOffset.y) > self.itemSize.height) {
                break;
            }
            NSIndexPath *path = centerLayout.indexPath;
            NSIndexPath *indexPath = nil;
            if (velocity.y > 0.0) {
                // 往下
                indexPath = [NSIndexPath indexPathForItem:path.item + 1 inSection:path.section];
            } else if (velocity.y < 0.0) {
                // 往左
                indexPath = [NSIndexPath indexPathForItem:path.item - 1 inSection:path.section];
            }
            if (!indexPath) {
                break;
            }
            UICollectionViewLayoutAttributes *layout = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (!layout) {
                break;
            }
            CGFloat edge = (CGRectGetHeight(self.collectionView.bounds) - CGRectGetHeight(layout.frame)) * 0.5;
            adjustPoint.y = layout.frame.origin.y - edge;
        } while (0);
    }
    return adjustPoint;
}

- (id)copyWithZone:(NSZone *)zone {
    KKCollectionViewStayCenterLayout *layout = [[KKCollectionViewStayCenterLayout allocWithZone:zone] init];
    layout.totalCount = self.totalCount;
    layout.lastContentOffset = self.lastContentOffset;
    layout.pageEnable = self.pageEnable;

    layout.minimumLineSpacing = self.minimumLineSpacing;
    layout.minimumInteritemSpacing = self.minimumInteritemSpacing;
    layout.itemSize = self.itemSize;
    layout.estimatedItemSize = self.estimatedItemSize;
    layout.scrollDirection = self.scrollDirection;
    layout.headerReferenceSize = self.headerReferenceSize;
    layout.footerReferenceSize = self.footerReferenceSize;
    layout.sectionInset = self.sectionInset;
    layout.sectionInsetReference = self.sectionInsetReference;
    layout.sectionHeadersPinToVisibleBounds = self.sectionHeadersPinToVisibleBounds;
    layout.sectionFootersPinToVisibleBounds = self.sectionFootersPinToVisibleBounds;
    return layout;
}
@end

