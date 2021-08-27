//
//  KKCollectionViewStayCenterLayout.h
//  ShowStart
//
//  Created by king on 2021/7/22.
//  Copyright © 2021 taihe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKCollectionViewStayCenterLayout : UICollectionViewFlowLayout<NSCopying>
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) BOOL pageEnable;
@end

NS_ASSUME_NONNULL_END

