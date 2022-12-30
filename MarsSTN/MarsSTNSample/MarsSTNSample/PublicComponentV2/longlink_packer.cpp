//
//  longlink_packer.cpp
//  MarsSTNSample
//
//  Created by king on 2022/11/17.
//

#include "longlink_packer.hpp"

#include <mars/comm/autobuffer.h>
#include <mars/stn/proto/longlink_packer.h>
#include <mars/stn/stn.h>

#include <CoreFoundation/CFByteOrder.h>

namespace mars {
namespace stn {

LongLinkEncoder gDefaultLongLinkEncoder;
static uint32_t sg_client_version = 0;
longlink_tracker *(*longlink_tracker::Create)() = []() {
    return new longlink_tracker();
};

void SetClientVersion(uint32_t _client_version) {
    sg_client_version = _client_version;
}

#pragma pack(push, 1)
struct __STNetMsgXpHeader {
    uint32_t cmdid;
    uint32_t seq;
    uint32_t body_length;
};
#pragma pack(pop)

static int __unpack_test(const void *_packed, size_t _packed_len, uint32_t &_cmdid, uint32_t &_seq, size_t &_package_len, size_t &_body_len) {
    __STNetMsgXpHeader st = {0};
    if (_packed_len < sizeof(__STNetMsgXpHeader)) {
        _package_len = 0;
        _body_len = 0;
        return LONGLINK_UNPACK_CONTINUE;
    }

    memcpy(&st, _packed, sizeof(__STNetMsgXpHeader));

    size_t head_len = sizeof(__STNetMsgXpHeader);

    _cmdid = ntohl(st.cmdid);
    _seq = ntohl(st.seq);
    _body_len = ntohl(st.body_length);
    _package_len = head_len + _body_len;

    printf("cmdid %u seq %u body_len %zu \n", _cmdid, _seq, _body_len);
    if (_package_len > 1024 * 1024) {
        return LONGLINK_UNPACK_FALSE;
    }
    if (_package_len > _packed_len) {
        return LONGLINK_UNPACK_CONTINUE;
    }

    return LONGLINK_UNPACK_OK;
}

static int packer_encoder_version = 0;
void LongLinkEncoder::SetEncoderVersion(int _version) {
    packer_encoder_version = _version;
}

LongLinkEncoder::LongLinkEncoder() {
    longlink_pack = [](uint32_t _cmdid, uint32_t _seq, const AutoBuffer &_body, const AutoBuffer &_extension, AutoBuffer &_packed, longlink_tracker *_tracker) {
        __STNetMsgXpHeader st{0};
        st.cmdid = htonl(_cmdid);
        st.seq = htonl(_seq);
        st.body_length = htonl(_body.Length());

        _packed.AllocWrite(sizeof(__STNetMsgXpHeader) + _body.Length());
        _packed.Write(&st, sizeof(st));

        if (NULL != _body.Ptr()) _packed.Write(_body.Ptr(), _body.Length());

        _packed.Seek(0, AutoBuffer::ESeekStart);
    };

    longlink_unpack = [](const AutoBuffer &_packed, uint32_t &_cmdid, uint32_t &_seq, size_t &_package_len, AutoBuffer &_body, AutoBuffer &_extension, longlink_tracker *_tracker) {
        size_t body_len = 0;
        int ret = __unpack_test(_packed.Ptr(), _packed.Length(), _cmdid, _seq, _package_len, body_len);

        if (LONGLINK_UNPACK_OK != ret) {
            return ret;
        }

        _body.Write(AutoBuffer::ESeekCur, _packed.Ptr(_package_len - body_len), body_len);

        return ret;
    };

#define NOOP_CMDID 6
#define SIGNALKEEP_CMDID 243
#define PUSH_DATA_TASKID 0

    longlink_noop_cmdid = []() -> uint32_t {
        return NOOP_CMDID;
    };

    longlink_noop_isresp = [](uint32_t _taskid, uint32_t _cmdid, uint32_t _recv_seq, const AutoBuffer &_body, const AutoBuffer &_extend) {
        return Task::kNoopTaskID == _taskid && NOOP_CMDID == _cmdid;
    };

    signal_keep_cmdid = []() -> uint32_t {
        return SIGNALKEEP_CMDID;
    };

    longlink_noop_req_body = [](AutoBuffer &_body, AutoBuffer &_extend) {
        printf("%s\n", "longlink_noop_req_body");
    };

    longlink_noop_resp_body = [](const AutoBuffer &_body, const AutoBuffer &_extend) {
        printf("%s\n", "longlink_noop_resp_body");
    };

    longlink_noop_interval = []() -> uint32_t {
        uint32_t interval = 0;
//        interval = 10 * 1000;
        return interval;
    };

    longlink_complexconnect_need_verify = []() {
        return false;
    };

    longlink_ispush = [](uint32_t _cmdid, uint32_t _taskid, const AutoBuffer &_body, const AutoBuffer &_extend) {
        return PUSH_DATA_TASKID == _taskid;
    };

    longlink_identify_isresp = [](uint32_t _sent_seq, uint32_t _cmdid, uint32_t _recv_seq, const AutoBuffer &_body, const AutoBuffer &_extend) {
        return _sent_seq == _recv_seq && 0 != _sent_seq;
    };
};

};  // namespace stn
};  // namespace mars

