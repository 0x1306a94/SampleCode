//
//  ViewController.m
//  DelayqueueSample
//
//  Created by king on 2022/10/21.
//

#import "ViewController.h"

#import "KKDelayQueue.h"
#import "KKDelayTask.h"

@interface ViewController ()
@property (nonatomic, strong) KKDelayQueue *delayQueue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.delayQueue = [KKDelayQueue new];

    KKDelayTask *task = [KKDelayTask new];
    [self.delayQueue removeTask:task];
    //    [self.delayQueue addTask:task timeout:5000];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.delayQueue = nil;
//    });
}

- (void)mouseUp:(NSEvent *)event {

    KKDelayTask *task = [KKDelayTask new];
    NSInteger timeout = (arc4random_uniform(5) + 1) * 1000;
    NSLog(@"add task: %ld", timeout);
    [self.delayQueue addTask:task timeout:timeout];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delayQueue removeTask:task]) {
            NSLog(@"remove task: %ld", timeout);
        }
    });
}
@end

