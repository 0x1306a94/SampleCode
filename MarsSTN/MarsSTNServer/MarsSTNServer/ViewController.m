//
//  ViewController.m
//  MarsSTNServer
//
//  Created by king on 2022/11/18.
//

#import "KKTransportPacket.h"
#import "NetMsgXpHeader.h"
#import "ViewController.h"

@import CocoaAsyncSocket;

@interface ViewController () <GCDAsyncSocketDelegate>
@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, strong) GCDAsyncSocket *listenSocket;
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.socketQueue = dispatch_queue_create("socketQueue", NULL);

    self.listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];

    NSError *error = nil;
    if (![self.listenSocket acceptOnPort:9090 error:&error]) {
        NSLog(@"%@", error);
    }
}

// MARK: - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    if (self.clientSocket) {
        [self.clientSocket disconnect];
    }
    NSLog(@"新连接: connectedPort %hu", newSocket.connectedPort);
    self.clientSocket = newSocket;

    [newSocket readDataToLength:sizeof(NetMsgXpHeader) withTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    if (self.clientSocket == sock) {
        self.clientSocket = nil;
        NSLog(@"断开连接: connectedPort %hu", sock.connectedPort);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"write data: tag %lu ", tag);
}

static NetMsgXpHeader st = {0};
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"read data: tag %lu %@", tag, data);
    switch (tag) {
        case 1: {
            memcpy(&st, data.bytes, sizeof(NetMsgXpHeader));
            //            st.cmdid = ntohl(st.cmdid);
            //            st.seq = ntohl(st.seq);
            //            st.bodyLenght = ntohl(st.bodyLenght);

            uint32_t cmdid = ntohl(st.cmdid);
            uint32_t seq = ntohl(st.seq);
            uint32_t body_length = ntohl(st.body_length);
            NSLog(@"cmdid %u seq %u body_length %u", cmdid, seq, body_length);
            if (cmdid == NOOP_CMDID) {
                NSLog(@"Receive heartbeat");
                NSData *data = [NSData dataWithBytes:&st length:sizeof(NetMsgXpHeader)];
                [self.clientSocket writeData:data withTimeout:-1 tag:1];
                [self.clientSocket readDataToLength:sizeof(NetMsgXpHeader) withTimeout:-1 tag:1];
                return;
            }

            [self.clientSocket readDataToLength:body_length withTimeout:-1 tag:2];
            break;
        }
        case 2: {
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSString *json = @"OK";
            NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];

            st.body_length = htonl(data.length);
            NSMutableData *buffer = [NSMutableData dataWithBytes:&st length:sizeof(NetMsgXpHeader)];
            [buffer appendData:data];
            [self.clientSocket writeData:buffer withTimeout:-1 tag:11];
            [self.clientSocket readDataToLength:sizeof(NetMsgXpHeader) withTimeout:-1 tag:1];
            break;
        }
        default:
            break;
    }
}
@end

