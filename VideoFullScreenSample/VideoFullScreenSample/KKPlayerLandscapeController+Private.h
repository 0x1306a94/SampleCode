//
//  KKPlayerLandscapeController+Private.h
//  ShowStart
//
//  Created by king on 2024/6/20.
//  Copyright © 2024 taihe. All rights reserved.
//

#import "KKPlayerLandscapeController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KKPlayerLandscapeController ()
@property (nonatomic, weak) __kindof UIView *presentSourceAnimationView;
@property (nonatomic, assign) CGRect presentSourceFrame;
@property (nonatomic, assign) UIInterfaceOrientation sourceOrientation;
- (__kindof UIView *)destinationContainerView;

@end

NS_ASSUME_NONNULL_END
