//
//  KKTransportPacket.h
//  Pods
//
//  Created by king on 2022/10/18.
//

#ifndef KKTransportPacket_h
#define KKTransportPacket_h

#import <CoreFoundation/CFByteOrder.h>
#import <Foundation/Foundation.h>

#import "KKTransportPacketType.h"
/*
- - - - - - - - - - - - - - - - - - - - - - - -
|         |         |            |            |
|  magic  |   type  |   lenght   |  payload   |
|         |         |            |            |
- - - - - - - - - - - - - - - - - - - - - - - -
|    1    |     1   |   2(big)   |            |
- - - - - - - - - - - - - - - - - - - - - - - -
 */

typedef uint8_t KKTransportPacketFlag;

#define KKTransportPacketFlagMagicBit (8)
#define KKTransportPacketFlagLengthBit (7)

typedef struct {
    uint8_t magic;
    KKTransportPacketType type;
    uint16_t length;
} KKTransportPacketHeader;

NS_INLINE BOOL KKTransportPacketFlagCheck(KKTransportPacketFlag flag, uint8_t bit_num) {
    return (flag >> (bit_num - 1) & 1) == 1;
}

NS_INLINE void KKTransportPacketFlagSet(KKTransportPacketFlag *_Nonnull flag, uint8_t bit_num, BOOL bit_value) {
    if (flag == NULL) {
        return;
    }

    if (bit_value) {
        *flag = (*flag |= (1 << (bit_num - 1)));
    } else {
        *flag = (*flag &= ~(1 << (bit_num - 1)));
    }
}

NS_INLINE KKTransportPacketHeader KKTransportPacketHeaderMake(KKTransportPacketType type, uint16_t length) {
    return (KKTransportPacketHeader){
        .magic = 99,
        .type = type,
        .length = length,
    };
}

NS_INLINE BOOL KKTransportPacketHeaderFromData(NSData *_Nonnull data, KKTransportPacketHeader *_Nullable header) {
    const char *bytes = (const char *)data.bytes;
    if (data.length < sizeof(KKTransportPacketHeader)) {
        return NO;
    }

    if ((uint8_t)bytes[0] != 99) {
        return NO;
    }

    KKTransportPacketType type;
    memcpy(&type, bytes + offsetof(KKTransportPacketHeader, type), 1);
    uint16_t length;
    memcpy(&length, bytes + offsetof(KKTransportPacketHeader, length), 2);
    length = CFSwapInt16BigToHost(length);

    if (header != NULL) {
        *header = KKTransportPacketHeaderMake(type, length);
    }
    return YES;
}

NS_INLINE NSData *_Nullable KKTransportPacketEncoder(KKTransportPacketHeader *_Nonnull header, NSData *_Nullable payload) {
    if (header == NULL) {
        return nil;
    }

    NSMutableData *buffer = [NSMutableData dataWithCapacity:header->length + 4];

    uint16_t lenght = header->length;

    [buffer appendBytes:&(header->magic) length:1];
    [buffer appendBytes:&(header->type) length:1];

    lenght = CFSwapInt16HostToBig(lenght);
    [buffer appendBytes:&lenght length:2];
    [buffer appendData:payload];

    return buffer;
}

#endif /* KKTransportPacket_h */

