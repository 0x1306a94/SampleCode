//
//  NetMsgXpHeader.h
//  MarsSTNServer
//
//  Created by king on 2022/11/20.
//

#ifndef NetMsgXpHeader_h
#define NetMsgXpHeader_h

#import <Foundation/Foundation.h>

#define NOOP_CMDID 6

#pragma pack(push, 1)
typedef struct {
    uint32_t cmdid;
    uint32_t seq;
    uint32_t body_length;
} NetMsgXpHeader;
#pragma pack(pop)

#endif /* NetMsgXpHeader_h */

