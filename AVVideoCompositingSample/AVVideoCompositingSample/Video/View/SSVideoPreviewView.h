//
//  SSVideoPreviewView.h
//  AVVideoCompositingSample
//
//  Created by king on 2020/10/25.
//  Copyright © 2020 taihe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVAnimation.h>

NS_ASSUME_NONNULL_BEGIN

@class AVPlayer;

@interface SSVideoPreviewView : UIView
/// 画面显示模式 默认 AVLayerVideoGravityResizeAspect
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;
- (void)attachPlayer:(AVPlayer *)player;
@end

NS_ASSUME_NONNULL_END

