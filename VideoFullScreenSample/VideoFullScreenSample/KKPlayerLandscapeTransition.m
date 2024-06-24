//
//  KKPlayerLandscapeTransition.m
//  ShowStart
//
//  Created by king on 2024/6/20.
//  Copyright © 2024 taihe. All rights reserved.
//

#import "KKPlayerLandscapeTransition.h"

#import "KKPlayerLandscapeController+Private.h"
#import "KKPlayerLandscapeController.h"

#import <Masonry/Masonry.h>

CGAffineTransform TransformFromSourceRect(CGRect source, CGRect target, CGFloat rotation) {
    CGFloat scaleX = target.size.width / source.size.width;
    CGFloat scaleY = target.size.height / source.size.height;
    CGPoint sourceCenter = CGPointMake(CGRectGetMidX(source), CGRectGetMidY(source));
    CGPoint destinationCenter = CGPointMake(CGRectGetMidX(target), CGRectGetMidY(target));

    CGFloat translateToCenterX = destinationCenter.x - sourceCenter.x;
    CGFloat translateToCenterY = 0;  //destinationCenter.y - sourceCenter.y;
    CGFloat translateBackX = target.origin.x - source.origin.x * scaleX;
    CGFloat translateBackY = target.origin.y - source.origin.y * scaleY;

    CGAffineTransform translateToCenterTransform = CGAffineTransformMakeTranslation(translateToCenterX, translateToCenterY);

    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleX, scaleY);
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(rotation);

    CGAffineTransform translateBackTransform = CGAffineTransformMakeTranslation(translateBackX, translateBackY);

    CGAffineTransform finalTransform = CGAffineTransformConcat(translateToCenterTransform, scaleTransform);
    finalTransform = CGAffineTransformConcat(finalTransform, rotateTransform);
    finalTransform = CGAffineTransformConcat(finalTransform, translateBackTransform);

    return finalTransform;
}

@interface KKPlayerLandscapeTransitionModalTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation KKPlayerLandscapeTransitionModalTransition
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}
#endif

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    __unused __kindof UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    KKPlayerLandscapeController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSCParameterAssert([toViewController isKindOfClass:KKPlayerLandscapeController.class]);

    NSTimeInterval duration = [self transitionDuration:transitionContext];

    UIView *containerView = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];

    CGRect bounds = containerView.bounds;
    CGRect sourceRect = toViewController.presentSourceFrame;

    NSLog(@"present containerView bounds: %@ source %@", NSStringFromCGRect(bounds), NSStringFromCGRect(sourceRect));
    toView.frame = bounds;

    [containerView addSubview:fromView];
    [containerView addSubview:toView];

    __kindof UIView *presentSourceAnimationView = toViewController.presentSourceAnimationView;
    __kindof UIView *destinationContainerView = [toViewController destinationContainerView];

#if USE_AUTOLAYOUT
    [presentSourceAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(bounds.size);
        make.center.mas_equalTo(presentSourceAnimationView.superview);
    }];

    CGAffineTransform finalTransform = CGAffineTransformMakeRotation(M_PI_2);
#else
    CGAffineTransform finalTransform = TransformFromSourceRect(sourceRect, bounds, M_PI_2);
#endif

    destinationContainerView.hidden = YES;
    [UIView animateWithDuration:duration animations:^{
        [presentSourceAnimationView.superview layoutIfNeeded];
        presentSourceAnimationView.transform = finalTransform;
    } completion:^(BOOL finished) {
        presentSourceAnimationView.transform = CGAffineTransformIdentity;
        [presentSourceAnimationView removeFromSuperview];
        destinationContainerView.hidden = NO;
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        //设置transitionContext通知系统动画执行完毕
        [transitionContext completeTransition:!wasCancelled];
    }];
}
@end

@interface KKPlayerLandscapeTransitionDismissTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation KKPlayerLandscapeTransitionDismissTransition
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}
#endif

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    KKPlayerLandscapeController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    NSCParameterAssert([fromViewController isKindOfClass:KKPlayerLandscapeController.class]);

    UIView *containerView = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];

    CGRect bounds = containerView.bounds;
    CGRect sourceRect = fromViewController.presentSourceFrame;

    NSLog(@"dismiss containerView bounds: %@ source %@", NSStringFromCGRect(bounds), NSStringFromCGRect(sourceRect));
    toView.frame = bounds;

    [containerView addSubview:toView];
    [containerView addSubview:fromView];

    NSTimeInterval duration = [self transitionDuration:transitionContext];

    __kindof UIView *destinationContainerView = [fromViewController destinationContainerView];

#if USE_AUTOLAYOUT
    CGPoint superCenter = destinationContainerView.superview.center;
    CGPoint playCenter = CGPointMake(0, CGRectGetMidY(sourceRect));
    CGPoint centerOffset = CGPointMake(playCenter.y - superCenter.y, 0);

    [destinationContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(sourceRect.size);
        make.center.equalTo(destinationContainerView.superview).centerOffset(centerOffset);
    }];

    CGAffineTransform finalTransform = CGAffineTransformMakeRotation(-M_PI_2);
#else

    CGRect modifyBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
    CGAffineTransform finalTransform = TransformFromSourceRect(sourceRect, modifyBounds, M_PI_2);
    finalTransform = CGAffineTransformInvert(finalTransform);

    CGRect frame = destinationContainerView.frame;
    frame = CGRectApplyAffineTransform(frame, finalTransform);
#endif

    [UIView animateWithDuration:duration animations:^{
        [destinationContainerView.superview layoutIfNeeded];
        destinationContainerView.transform = finalTransform;
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        destinationContainerView.transform = CGAffineTransformIdentity;
        [fromView removeFromSuperview];
        //设置transitionContext通知系统动画执行完毕
        [transitionContext completeTransition:!wasCancelled];
    }];
}
@end

@implementation KKPlayerLandscapeTransition
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}
#endif

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    KKPlayerLandscapeController *landscapeController = (KKPlayerLandscapeController *)presented;
    NSCParameterAssert([landscapeController isKindOfClass:KKPlayerLandscapeController.class]);
    NSCParameterAssert(landscapeController.delegate != nil && [landscapeController.delegate respondsToSelector:@selector(onsiteExperiencePostFeedImmersionPlayerLandscapeControllerAnimationView:sourceFrame:)]);

    CGRect sourceFrame = CGRectZero;
    UIView *animationView = [landscapeController.delegate onsiteExperiencePostFeedImmersionPlayerLandscapeControllerAnimationView:landscapeController sourceFrame:&sourceFrame];
    landscapeController.presentSourceAnimationView = animationView;
    landscapeController.presentSourceFrame = sourceFrame;
    return [KKPlayerLandscapeTransitionModalTransition new];
}

- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [KKPlayerLandscapeTransitionDismissTransition new];
}

@end
