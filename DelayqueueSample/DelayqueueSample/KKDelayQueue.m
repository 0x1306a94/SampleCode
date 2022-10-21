//
//  KKDelayQueue.m
//  DelayqueueSample
//
//  Created by king on 2022/10/21.
//

#import "KKDelayQueue.h"
#import "KKDelayTask.h"

#import <os/lock.h>
#import <pthread.h>
#import <sched.h>
#import <sys/event.h>
#import <sys/time.h>
#import <sys/types.h>

@interface KKDelayQueue ()
@property (nonatomic, strong) NSMutableSet<__kindof KKDelayTask *> *tasks;
@end

@implementation KKDelayQueue {
  @private
    int _kq;
    BOOL _close;
    pthread_t _thread;
    os_unfair_lock _lock;
}

- (instancetype)init {
    if (self == [super init]) {
        _kq = kqueue();
        _lock = OS_UNFAIR_LOCK_INIT;
        self.tasks = [NSMutableSet<__kindof KKDelayTask *> setWithCapacity:100];
        [self _createThread];
    }
    return self;
}

- (void)dealloc {

    os_unfair_lock_lock(&_lock);
    [self.tasks removeAllObjects];
    _close = YES;
    os_unfair_lock_unlock(&_lock);
    pthread_join(_thread, NULL);
    close(_kq);

    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}

- (void)_createThread {
    pthread_attr_t attr;
    struct sched_param sched_param;
    int sched_policy = SCHED_FIFO;

    pthread_attr_init(&attr);
    pthread_attr_setschedpolicy(&attr, sched_policy);
    sched_param.sched_priority = sched_get_priority_max(sched_policy);
    pthread_attr_setschedparam(&attr, &sched_param);

    pthread_create(&_thread, &attr, delay_queue_event_loop_main, (__bridge void *)self);

    pthread_attr_destroy(&attr);
}

- (void)_eventLoop {

#define MAX_EVENET_NUMS 100
    while (!_close) {
        // 每次等待 300ms
        struct timespec ts = {0, 300 * 1000000};
        struct kevent kev[MAX_EVENET_NUMS];
        int n = kevent(_kq, NULL, 0, kev, MAX_EVENET_NUMS, &ts);
        if (n == 0) {
            continue;
        }
        os_unfair_lock_lock(&_lock);
        for (int i = 0; i < n; i++) {
            struct kevent ev = kev[i];

            void *ptr = (void *)ev.ident;
            // remove
            struct kevent rev;
            EV_SET(&rev, ev.ident, EVFILT_TIMER, EV_DELETE, 0, 0, NULL);
            kevent(_kq, &rev, 1, NULL, 0, NULL);

            __kindof KKDelayTask *task = (__bridge KKDelayTask *)ptr;
            [self.tasks removeObject:task];
            [task handler];
        }
        os_unfair_lock_unlock(&_lock);
    }

#undef MAX_EVENET_NUMS
}

static void *delay_queue_event_loop_main(void *info) {
    pthread_setname_np("com.taihe.delayqueue.event-loop");
    NSLog(@"eventloop start");
    __unsafe_unretained KKDelayQueue *eventLoop = (__bridge KKDelayQueue *)info;
    @autoreleasepool {
        [eventLoop _eventLoop];
    }

    return NULL;
}

#pragma mark - public
- (BOOL)addTask:(__kindof KKDelayTask *)task timeout:(NSInteger)timeout {
    if (task == nil) {
        return NO;
    }

    os_unfair_lock_lock(&_lock);
    [self.tasks addObject:task];
    os_unfair_lock_unlock(&_lock);

    uintptr_t ptr = (uintptr_t)(__bridge void *)task;
    struct kevent ev;
    EV_SET(&ev, ptr, EVFILT_TIMER, EV_ADD | EV_ENABLE, 0, timeout, NULL);
    kevent(_kq, &ev, 1, NULL, 0, NULL);

    return YES;
}

- (BOOL)removeTask:(__kindof KKDelayTask *)task {
    if (task == nil) {
        return NO;
    }

    BOOL needRemove = NO;
    os_unfair_lock_lock(&_lock);
    if ([self.tasks containsObject:task]) {
        needRemove = YES;
        [self.tasks removeObject:task];
    }
    os_unfair_lock_unlock(&_lock);

    if (needRemove) {
        uintptr_t ptr = (uintptr_t)(__bridge void *)task;
        struct kevent ev;
        EV_SET(&ev, ptr, EVFILT_TIMER, EV_DELETE, 0, 0, NULL);
        kevent(_kq, &ev, 1, NULL, 0, NULL);
        return YES;
    }
    return NO;
}
@end

