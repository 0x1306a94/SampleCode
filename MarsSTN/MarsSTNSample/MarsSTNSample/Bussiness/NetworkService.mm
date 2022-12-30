//
//  NetworkService.m
//  MarsSTNSample
//
//  Created by king on 2022/11/17.
//

#import "NetworkService.h"

#import "STNAuthTask.h"
#import "app_callback.h"
#import "proto.h"
#import "stn_callback.h"

#import <mars/app/app_logic.h>
#import <mars/baseevent/base_logic.h>
#import <mars/stn/stn_logic.h>
#import <mars/stn/stnproto_logic.h>

#import <SystemConfiguration/SCNetworkReachability.h>

#import <iostream>

class CSCB : public mars::stn::ConnectionStatusCallback {
  public:
    void onConnectionStatusChanged(mars::stn::ConnectionStatus connectionStatus) override {
        std::cout << "ConnectionStatus: " << connectionStatus << std::endl;
        switch (connectionStatus) {
            case mars::stn::kConnectionStatusConnected: {

                mars::stn::Task ctask;
                ctask.cgi = "/headers";
                ctask.channel_select = mars::stn::Task::kChannelShort;
                ctask.shortlink_host_list.push_back("httpbin.org");
                mars::stn::StartTask(ctask);
                break;
            }
            default:
                break;
        }
    }
};

@interface NetworkService ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, __kindof STNTask *> *taskMap;
@end
@implementation NetworkService

static NetworkService *sharedSingleton = nil;
+ (NetworkService *)sharedInstance {
    @synchronized(self) {
        if (sharedSingleton == nil) {
            sharedSingleton = [[NetworkService alloc] init];
        }
    }
    return sharedSingleton;
}

- (instancetype)init {
    if (self == [super init]) {
        self.taskMap = [NSMutableDictionary<NSString *, __kindof STNTask *> dictionaryWithCapacity:10];
    }
    return self;
}

- (void)setCallBack {
    auto auth_func = std::function<void()>([]() {
        [[NetworkService sharedInstance] startAuth];
    });

    auto stnCB = mars::stn::StnCallBack::Instance(auth_func);
    stnCB->setConnectionStatusCallback(std::make_unique<CSCB>());

    mars::stn::SetCallback(stnCB);
    mars::app::SetCallback(mars::app::AppCallBack::Instance());
}

- (void)createMars {
    mars::baseevent::OnCreate();
}

- (void)setClientVersion:(UInt32)clientVersion {
    mars::stn::SetClientVersion(clientVersion);
}

- (void)setShortLinkDebugIP:(NSString *)IP port:(const unsigned short)port {
    std::string ipAddress([IP UTF8String]);
    mars::stn::SetShortlinkSvrAddr(port, ipAddress);
}

- (void)setShortLinkPort:(const unsigned short)port {
    mars::stn::SetShortlinkSvrAddr(port, "");
}

- (void)setLongLinkAddress:(NSString *)string port:(const unsigned short)port debugIP:(NSString *)IP {
    std::string ipAddress([string UTF8String]);
    std::string debugIP([IP UTF8String]);
    std::vector<uint16_t> ports;
    ports.push_back(port);
    mars::stn::SetLonglinkSvrAddr(ipAddress, ports, debugIP);
}

- (void)setLongLinkAddress:(NSString *)string port:(const unsigned short)port {
    std::string ipAddress([string UTF8String]);
    std::vector<uint16_t> ports;
    ports.push_back(port);
    mars::stn::SetLonglinkSvrAddr(ipAddress, ports, "");
}

- (void)makesureLongLinkConnect {
    mars::stn::MakesureLonglinkConnected();
}

- (void)destroyMars {
    mars::baseevent::OnDestroy();
}

- (void)startAuth {

    std::string json = R"({"token":"9549d2b7d33c8cb2eaa3f39da828e06fa1f627773061","seq":"T1668739461190S00000","uid":"6081_1","time":1668739461190})";

    STNAuthTask *auth = [STNAuthTask new];
    auth.json = [NSString stringWithUTF8String:json.c_str()];
    mars::stn::Task ctask;
    ctask.cmdid = 1;
    ctask.channel_select = mars::stn::Task::kChannelLong;
    ctask.need_authed = true;
    ctask.user_context = (__bridge void *)(auth);

    NSLog(@"%s %@\n", __PRETTY_FUNCTION__, auth);
    NSString *taskIdKey = [NSString stringWithFormat:@"%d", ctask.taskid];
    self.taskMap[taskIdKey] = auth;

    mars::stn::StartTask(ctask);
}

// event reporting
- (void)reportEvent_OnForeground:(BOOL)isForeground {
    mars::baseevent::OnForeground(isForeground);
}

- (void)reportEvent_OnNetworkChange {
    mars::baseevent::OnNetworkChange();
}

// MARK: - NetworkStatusDelegate
- (void)ReachabilityChange:(UInt32)uiFlags {
    if ((uiFlags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        mars::baseevent::OnNetworkChange();
    }
}

- (NSData *)Request2BufferWithTaskID:(uint32_t)tid userContext:(const void *)context {
    __kindof STNTask *task = (__bridge STNTask *)context;
    NSData *data = [task requestData];
    return data;
}

- (NSInteger)Buffer2ResponseWithTaskID:(uint32_t)tid ResponseData:(NSData *)data userContext:(const void *)context {
    __unused __kindof STNTask *task = (__bridge STNTask *)context;
    NSLog(@"resp: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return 0;
}

- (int)OnTaskEndWithTaskID:(uint32_t)tid userContext:(const void *)context errType:(uint32_t)errtype errCode:(uint32_t)errcode {
    __unused __kindof STNTask *task = (__bridge STNTask *)context;
    NSString *taskIdKey = [NSString stringWithFormat:@"%d", tid];
    self.taskMap[taskIdKey] = nil;
    return 0;
}
@end

