//
//  STNAuthTask.m
//  MarsSTNSample
//
//  Created by king on 2022/11/19.
//

#import "STNAuthTask.h"

@implementation STNAuthTask

- (NSData *)requestData {
    return [self.json dataUsingEncoding:NSUTF8StringEncoding];
}
@end

