//
//  KKTransportPacketType.h
//  Pods
//
//  Created by king on 2022/10/21.
//

#ifndef KKTransportPacketType_h
#define KKTransportPacketType_h

#import <Foundation/Foundation.h>

typedef enum : uint8_t {
    KKTransportPacketReserved = 0,
    KKTransportPacketPing = 1,                        ///< 心跳
    KKTransportPacketPingAck = 11,                    ///< 心跳确认
    KKTransportPacketAuth = 2,                        ///< 身份认证
    KKTransportPacketAuthAck = 12,                    ///< 身份认证响应
    KKTransportPacketIMAck = 3,                       ///< IM消息响应
    KKTransportPacketIMSend = 4,                      ///< 发送IM消息
    KKTransportPacketNotice = 5,                      ///< 服务端下发通知
    KKTransportPacketIMFetchOfflineMessage = 6,       ///< 拉取离线消息
    KKTransportPacketIMFetchOfflineMessageResp = 16,  ///< 拉取离线消息响应
} KKTransportPacketType;

#endif /* KKTransportPacketType_h */

