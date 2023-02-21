//
//  TDXDBlockScrollContainerView.h
//  TestScrollView
//
//  Created by king on 2023/2/20.
//

#import <UIKit/UIKit.h>

#import "TDXDBlockScrollComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDXDBlockScrollContainerView : UIView

- (void)addComponents:(NSArray<id<TDXDBlockScrollComponent>> *)components;

@end

NS_ASSUME_NONNULL_END
