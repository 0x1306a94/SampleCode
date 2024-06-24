//
//  KKPlayerLandscapeController.h
//  ShowStart
//
//  Created by king on 2024/6/20.
//  Copyright © 2024 taihe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KKPlayerLandscapeControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KKPlayerLandscapeController : UIViewController
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) __kindof UIView *sourceView;
@property (nonatomic, assign, readonly) CGRect sourceRect;
@property (nonatomic, strong, nullable) void (^dismissHandler)(void);
@property (nonatomic, weak, readonly, nullable) id<KKPlayerLandscapeControllerDelegate> delegate;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithSourceView:(__kindof UIView *)sourceView delegate:(id<KKPlayerLandscapeControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
