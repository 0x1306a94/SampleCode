//
//  DBController.m
//  CoreDataSample
//
//  Created by king on 2021/4/21.
//

#import "DBController.h"

#import <objc/runtime.h>
#import <sys/xattr.h>

@interface DBController ()
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@property (nonatomic, copy) NSString *path;
@end

@implementation DBController
+ (instancetype)shared {
	static DBController *_instance_ = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance_ = [[DBController allocWithZone:NULL] init];
	});
	return _instance_;
}

- (BOOL)setupWithUserId:(NSString *)userId {
	if (self.persistentContainer) {
		return YES;
	}

	NSCParameterAssert(userId);
	NSString *rootDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Database"];

	NSString *userDir = [rootDir stringByAppendingPathComponent:userId];
	NSFileManager *fm = [NSFileManager defaultManager];

	BOOL isDirectory = NO;
	if (![fm fileExistsAtPath:userDir isDirectory:&isDirectory] || !isDirectory) {
		[fm createDirectoryAtPath:userDir withIntermediateDirectories:YES attributes:nil error:nil];
	}

	NSString *fileName = [NSString stringWithFormat:@"%@-database.sqlite", userId];
	NSString *path     = [userDir stringByAppendingPathComponent:fileName];

	NSString *versionKey = [NSString stringWithFormat:@"%@.coredata.version", NSBundle.mainBundle.bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:versionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];

	self.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DataModel"];

	NSPersistentStoreDescription *desc = [[NSPersistentStoreDescription alloc] initWithURL:[NSURL fileURLWithPath:path]];

	desc.shouldMigrateStoreAutomatically      = YES;
	desc.shouldInferMappingModelAutomatically = YES;
	desc.type                                 = NSSQLiteStoreType;

	self.path = path;
#if DEBUG
	NSLog(@"DBPath: %@", path);
#endif

	self.persistentContainer.persistentStoreDescriptions = @[desc];

	[self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *_Nonnull desc, NSError *_Nullable error) {
		if (error) {
			NSLog(@"DB loadPersistentStores Error: %@", error);
		}
	}];

	if (!self.persistentContainer.viewContext) {
		self.persistentContainer = nil;
		return NO;
	}

	NSLog(@"DB loadPersistentStores Successful");
	self.mainContext             = self.persistentContainer.viewContext;
	self.mainContext.name        = @"mainContext";
	self.mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

	self.backgroundContext             = [self.persistentContainer newBackgroundContext];
	self.backgroundContext.name        = @"backgroundContext";
	self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

	NSLog(@"mainContext psc: %@", self.mainContext.persistentStoreCoordinator);
	NSLog(@"backgroundContext psc: %@", self.backgroundContext.persistentStoreCoordinator);

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainContexDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:self.mainContext];

//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:self.backgroundContext];

	// 禁止备份
	const char *attrName = "com.apple.MobileBackup";
	u_int8_t attrValue   = 1;
	setxattr(rootDir.UTF8String, attrName, &attrValue, sizeof(attrValue), 0, 0);

	return YES;
}

- (void)backgroundContextDidSaveNotification:(NSNotification *)notification {
	__weak typeof(self) weak_self = self;
	[self.mainContext performBlock:^{
		__strong typeof(weak_self) self = weak_self;
		[self.mainContext mergeChangesFromContextDidSaveNotification:notification];
	}];
}

- (void)mainContexDidSaveNotification:(NSNotification *)notification {
	__weak typeof(self) weak_self = self;
	[self.backgroundContext performBlock:^{
		__strong typeof(weak_self) self = weak_self;
		[self.backgroundContext mergeChangesFromContextDidSaveNotification:notification];
	}];
}

- (void)closeWithCompletionHandler:(void (^)(void))completionHandler {
	if (self.persistentContainer) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];

		[self.backgroundContext sd_saveOrRollback];
		self.persistentContainer = nil;
		self.backgroundContext   = nil;
		self.mainContext         = nil;
		NSLog(@"DB Close");
		!completionHandler ?: completionHandler();
	} else {
		!completionHandler ?: completionHandler();
	}
}
@end

@implementation NSManagedObjectContext (SD)

- (BOOL)sd_saveOrRollback {
	if (![self hasChanges]) {
		return NO;
	}
	NSError *error = nil;
	[self save:&error];
	if (error) {
		[self rollback];
		NSLog(@"DB Save Error: %@ %@", self.name, error);
	} else {
		NSLog(@"DB Save: %@", self.name);
	}
	return error == nil;
}

- (void)sd_performChanges:(void (^)(NSManagedObjectContext *ctx))block {
	__weak typeof(self) weak_self = self;
	[self performBlock:^{
		__strong typeof(weak_self) self = weak_self;
		if (block) {
			block(self);
			[self sd_saveOrRollback];
		}
	}];
}

- (void)sd_performChangesAndWait:(void (^)(NSManagedObjectContext *ctx))block {
	__weak typeof(self) weak_self = self;
	[self performBlockAndWait:^{
		__strong typeof(weak_self) self = weak_self;
		if (block) {
			block(self);
			[self sd_saveOrRollback];
		}
	}];
}

- (__kindof NSManagedObject *)sd_createObjectAtEntityName:(NSString *)entityName {
	return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
}
@end

@implementation NSManagedObjectContextDeallocObserve
- (void)dealloc {
	!_willDealloc ?: _willDealloc();
	_willDealloc = nil;
}

- (instancetype)initWith:(void (^)(void))block {
	if (self == [super init]) {
		_willDealloc = block;
	}
	return self;
}

@end

