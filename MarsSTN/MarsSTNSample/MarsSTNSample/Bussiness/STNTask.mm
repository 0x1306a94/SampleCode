//
//  STNTask.m
//  MarsSTNSample
//
//  Created by king on 2022/11/19.
//

#import "STNTask.h"

@implementation STNTask
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", self);
}
#endif

- (NSData *)requestData {
    return [NSData data];
}
@end
