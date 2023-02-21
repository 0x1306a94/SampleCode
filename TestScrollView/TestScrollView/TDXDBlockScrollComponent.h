//
//  TDXDBlockScrollComponent.h
//  TestScrollView
//
//  Created by king on 2023/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TDXDBlockScrollComponent <NSObject>

- (CGFloat)conetntHeight;
- (CGPoint)maxContentOffset;
- (void)updateEnableScroll:(BOOL)enable;
- (void)updateScrollOffset:(CGFloat)offset;
@end

NS_ASSUME_NONNULL_END
