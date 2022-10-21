//
//  KKDelayTask.m
//  DelayqueueSample
//
//  Created by king on 2022/10/21.
//

#import "KKDelayTask.h"

@implementation KKDelayTask
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}
#endif

- (void)handler {
    NSLog(@"timeout");
}
@end

