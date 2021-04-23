//
//  AppDelegate.m
//  CoreDataSample
//
//  Created by king on 2021/4/21.
//

#import "AppDelegate.h"

#import "DBController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSManagedObjectContext *backgroundContext = [DBController shared].backgroundContext;
	[backgroundContext sd_saveOrRollback];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSManagedObjectContext *backgroundContext = [DBController shared].backgroundContext;
	[backgroundContext sd_saveOrRollback];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSManagedObjectContext *backgroundContext = [DBController shared].backgroundContext;
	[backgroundContext sd_saveOrRollback];
}

@end

