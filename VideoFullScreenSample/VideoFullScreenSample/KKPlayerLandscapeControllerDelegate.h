//
//  KKPlayerLandscapeControllerDelegate.h
//  VideoFullScreenSample
//
//  Created by king on 2024/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KKPlayerLandscapeController;
@protocol KKPlayerLandscapeControllerDelegate <NSObject>

- (__kindof UIView *)onsiteExperiencePostFeedImmersionPlayerLandscapeControllerAnimationView:(KKPlayerLandscapeController *)controller sourceFrame:(CGRect *)sourceFrame;
@end

NS_ASSUME_NONNULL_END
