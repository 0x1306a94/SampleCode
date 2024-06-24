//
//  KKPlayerLandscapeTransition.h
//  ShowStart
//
//  Created by king on 2024/6/20.
//  Copyright © 2024 taihe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

CGAffineTransform TransformFromSourceRect(CGRect source, CGRect target, CGFloat rotation);

@interface KKPlayerLandscapeTransition : NSObject <UIViewControllerTransitioningDelegate>

@end

NS_ASSUME_NONNULL_END
