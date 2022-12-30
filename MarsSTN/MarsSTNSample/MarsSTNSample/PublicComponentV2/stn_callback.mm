//
//  StnCallback.cpp
//  MarsSTNSample
//
//  Created by king on 2022/11/17.
//

#import "stn_callBack.h"

#import "NetworkService.h"

#import <iostream>
#import <mars/comm/autobuffer.h>
#import <mars/stn/stn.h>
#import <mars/xlog/xlogger.h>

namespace mars {
namespace stn {

StnCallBack *StnCallBack::instance_ = nullptr;

StnCallBack *StnCallBack::Instance(std::function<void()> startAuth) {
    if (instance_ == nullptr) {
        instance_ = new StnCallBack(startAuth);
    }
    return instance_;
}

void StnCallBack::Release() {
    if (instance_ != nullptr) {
        delete instance_;
        instance_ = nullptr;
    }
}

void StnCallBack::setConnectionStatusCallback(std::unique_ptr<ConnectionStatusCallback> callback) {
    this->m_connectionStatusCB = std::move(callback);
}

bool StnCallBack::MakesureAuthed(const std::string &_host, const std::string &_user_id) {
    printf("%s\n", __PRETTY_FUNCTION__);
    //    static bool authed = NO;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        authed = true;
    //    });
    //    return authed;
    return this->m_authed;
}

void StnCallBack::TrafficData(ssize_t _send, ssize_t _recv) {
    xdebug2(TSF "send:%_, recv:%_", _send, _recv);
}

std::vector<std::string> StnCallBack::OnNewDns(const std::string &host, bool _longlink_host) {
    std::vector<std::string> vector;
    //    vector.push_back("10.20.119.66");
    //    vector.push_back(host);

    return vector;
}

void StnCallBack::OnPush(const std::string &_channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer &_body, const AutoBuffer &_extend) {
    printf("%s\n", __PRETTY_FUNCTION__);
    if (_body.Length() > 0) {
        printf("OnPush: %s\n", (char *)_body.Ptr());
    }
}

bool StnCallBack::Req2Buf(uint32_t _taskid, void *const _user_context, const std::string &_user_id, AutoBuffer &outbuffer, AutoBuffer &extend, int &error_code, const int channel_select, const std::string &host) {
    printf("%s\n", __PRETTY_FUNCTION__);
    NSData *data = [[NetworkService sharedInstance] Request2BufferWithTaskID:_taskid userContext:_user_context];
    if (data) {
        outbuffer.AllocWrite(data.length);
        outbuffer.Write(data.bytes, data.length);
        return data.length > 0;
    }
    return true;
}

int StnCallBack::Buf2Resp(uint32_t _taskid, void *const _user_context, const std::string &_user_id, const AutoBuffer &_inbuffer, const AutoBuffer &_extend, int &_error_code, const int _channel_select) {
    printf("%s\n", __PRETTY_FUNCTION__);
    int handle_type = mars::stn::kTaskFailHandleNormal;
    if (_channel_select == Task::kChannelShort) {
        std::cout << "http response: \n"
                  << (char *)_inbuffer.Ptr() << std::endl;
    } else {
        NSData *responseData = [NSData dataWithBytes:(const void *)_inbuffer.Ptr() length:_inbuffer.Length()];

        NSInteger code = [[NetworkService sharedInstance] Buffer2ResponseWithTaskID:_taskid ResponseData:responseData userContext:_user_context];
        if (code != 0) {

            handle_type = mars::stn::kTaskFailHandleDefault;
        }
    }

    return handle_type;
}

int StnCallBack::OnTaskEnd(uint32_t _taskid, void *const _user_context, const std::string &_user_id, int _error_type, int _error_code, const CgiProfile &_profile) {
    printf("%s error_code %d\n", __PRETTY_FUNCTION__, _error_code);
    return [[NetworkService sharedInstance] OnTaskEndWithTaskID:_taskid userContext:_user_context errType:_error_type errCode:_error_code];
}

void StnCallBack::ReportConnectStatus(int _status, int _longlink_status) {
    printf("%s:%d %d\n", __PRETTY_FUNCTION__, _status, _longlink_status);
    switch (_longlink_status) {
        case mars::stn::kServerFailed:
        case mars::stn::kServerDown:
        case mars::stn::kGateWayFailed:
            break;
        case mars::stn::kConnecting:
            this->m_authed = false;
            if (this->m_connectionStatusCB) {
                this->m_connectionStatusCB->onConnectionStatusChanged(kConnectionStatusConnecting);
            }
            break;
        case mars::stn::kConnected:
            //            _startAuth();

            break;
        case mars::stn::kNetworkUnkown:
            return;
        default:
            return;
    }
}

void StnCallBack::OnLongLinkStatusChange(int _status) {
}

int StnCallBack::GetLonglinkIdentifyCheckBuffer(const std::string &_channel_id, AutoBuffer &_identify_buffer, AutoBuffer &_buffer_hash, int32_t &_cmdid) {
    printf("%s\n", __PRETTY_FUNCTION__);

    if (this->m_authed) {
        return IdentifyMode::kCheckNever;
    }
    printf("发送认证\n");
    _cmdid = 1;
    std::string json = R"({"token":"9549d2b7d33c8cb2eaa3f39da828e06fa1f627773061","seq":"T1668739461190S00000","uid":"6081_1","time":1668739461190})";
    _identify_buffer.AllocWrite(strlen(json.c_str()));
    _identify_buffer.Write(json.c_str());
    return IdentifyMode::kCheckNow;
    //    return IdentifyMode::kCheckNever;
}

bool StnCallBack::OnLonglinkIdentifyResponse(const std::string &_channel_id, const AutoBuffer &_response_buffer, const AutoBuffer &_identify_buffer_hash) {
    printf("%s\n", __PRETTY_FUNCTION__);
    if (strcmp((char *)_response_buffer.Ptr(), "OK") == 0) {
        printf("认证成功\n");
        this->m_authed = true;
        if (this->m_connectionStatusCB) {
            this->m_connectionStatusCB->onConnectionStatusChanged(kConnectionStatusConnected);
        }
    }
    return this->m_authed;

    //    return true;
}

void StnCallBack::RequestSync() {
    printf("%s\n", __PRETTY_FUNCTION__);
}
};  // namespace stn
};  // namespace mars

