//
//  NetworkService.h
//  MarsSTNSample
//
//  Created by king on 2022/11/17.
//

#import <Foundation/Foundation.h>

#import "NetworkStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkService : NSObject <NetworkStatusDelegate>

+ (NetworkService *)sharedInstance;

- (void)setCallBack;
- (void)createMars;

- (void)setClientVersion:(UInt32)clientVersion;
- (void)setShortLinkDebugIP:(NSString *)IP port:(const unsigned short)port;
- (void)setShortLinkPort:(const unsigned short)port;
- (void)setLongLinkAddress:(NSString *)string port:(const unsigned short)port debugIP:(NSString *)IP;
- (void)setLongLinkAddress:(NSString *)string port:(const unsigned short)port;
- (void)makesureLongLinkConnect;
- (void)destroyMars;

- (void)startAuth;

// event reporting
- (void)reportEvent_OnForeground:(BOOL)isForeground;
- (void)reportEvent_OnNetworkChange;

- (NSData *)Request2BufferWithTaskID:(uint32_t)tid userContext:(const void *)context;
- (NSInteger)Buffer2ResponseWithTaskID:(uint32_t)tid ResponseData:(NSData *)data userContext:(const void *)context;
- (int)OnTaskEndWithTaskID:(uint32_t)tid userContext:(const void *)context errType:(uint32_t)errtype errCode:(uint32_t)errcode;
@end

NS_ASSUME_NONNULL_END

