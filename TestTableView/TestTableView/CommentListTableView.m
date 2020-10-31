//
//  CommentListTableView.m
//  TestTableView
//
//  Created by king on 2020/10/31.
//  Copyright © 2020 0x1306a94. All rights reserved.
//

#import "CommentListTableView.h"

@implementation CommentListTableView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint contentOffset       = self.contentOffset;
        CGPoint velocity            = [pan velocityInView:pan.view];
        //        CGAffineTransform transform = self.superview.transform;
        //        if (transform.ty != 0) {
        //            return NO;
        //        }
        if (contentOffset.y == -self.contentInset.top) {
            NSLog(@"%@", NSStringFromCGPoint(velocity));
            // 关键点: 当前是最顶点, 不允许往下滑动
            if (velocity.y > 0) {
                // 向下
                return NO;
            }
        }
    }
    return YES;
}

@end

