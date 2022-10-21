//
//  KKDelayQueue.h
//  DelayqueueSample
//
//  Created by king on 2022/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KKDelayTask;
@interface KKDelayQueue : NSObject

/// 添加一个任务
/// - Parameters:
///   - task: 任务
///   - timeout: 超时,单位毫秒
- (BOOL)addTask:(__kindof KKDelayTask *)task timeout:(NSInteger)timeout;

/// 移除任务
/// - Parameter task: 任务
- (BOOL)removeTask:(__kindof KKDelayTask *)task;
@end

NS_ASSUME_NONNULL_END

