//
//  DBController.h
//  CoreDataSample
//
//  Created by king on 2021/4/21.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBController : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;
+ (instancetype)shared;

- (BOOL)setupWithUserId:(NSString *)userId;

- (void)closeWithCompletionHandler:(void (^_Nullable)(void))completionHandler;

- (NSManagedObjectContext *)generatePrivateContext;
@end

@interface NSManagedObjectContext (SD)

- (BOOL)sd_saveOrRollback;
- (void)sd_performChanges:(void (^)(NSManagedObjectContext *ctx))block;
- (void)sd_performChangesAndWait:(void (^)(NSManagedObjectContext *ctx))block;

- (__kindof NSManagedObject *)sd_createObjectAtEntityName:(NSString *)entityName;
@end

@interface NSManagedObjectContextDeallocObserve : NSObject
@property (nonatomic, strong) void (^willDealloc)(void);

- (instancetype)initWith:(void (^)(void))block;
@end
NS_ASSUME_NONNULL_END

