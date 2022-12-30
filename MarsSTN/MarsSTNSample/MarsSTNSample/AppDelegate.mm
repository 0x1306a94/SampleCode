//
//  AppDelegate.m
//  MarsSTNSample
//
//  Created by king on 2022/11/17.
//

#import "AppDelegate.h"

#import "NetworkService.h"
#import "NetworkStatus.h"

#import <mars/xlog/appender.h>
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    mars::xlog::appender_set_console_log(true);
    [[NetworkService sharedInstance] setCallBack];
    [[NetworkService sharedInstance] createMars];
    [[NetworkService sharedInstance] setClientVersion:200];
    //    [[NetworkService sharedInstance] setLongLinkAddress:@"10.20.119.66" port:5837];
    [[NetworkService sharedInstance] setLongLinkAddress:@"test.im" port:9090 debugIP:@"127.0.0.1"];
    [[NetworkService sharedInstance] setShortLinkPort:80];
    [[NetworkService sharedInstance] reportEvent_OnForeground:YES];
    //    [[NetworkService sharedInstance] reportEvent_OnNetworkChange];
    [[NetworkService sharedInstance] makesureLongLinkConnect];

    [[NetworkStatus sharedInstance] Start:[NetworkService sharedInstance]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[NetworkService sharedInstance] destroyMars];
    mars::xlog::appender_close();
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end

