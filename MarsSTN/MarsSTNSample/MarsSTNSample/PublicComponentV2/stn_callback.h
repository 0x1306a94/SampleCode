//
//  StnCallback.hpp
//  MarsSTNSample
//
//  Created by king on 2022/11/17.
//

#ifndef StnCallback_hpp
#define StnCallback_hpp

#include "proto.h"
#include <mars/stn/stn_logic.h>
#include <memory>

namespace mars {
namespace stn {

class ConnectionStatusCallback;

class StnCallBack : public Callback {
  private:
    std::function<void()> _startAuth;
    bool m_authed{false};
    StnCallBack(std::function<void()> startAuth)
        : _startAuth(std::move(startAuth)) {}
    ~StnCallBack() {}
    StnCallBack(StnCallBack &);
    StnCallBack &operator=(StnCallBack &);

    std::unique_ptr<ConnectionStatusCallback> m_connectionStatusCB;

  public:
    static StnCallBack *Instance(std::function<void()> startAuth);
    static void Release();
    void setConnectionStatusCallback(std::unique_ptr<ConnectionStatusCallback> callback);

    virtual bool MakesureAuthed(const std::string &_host, const std::string &_user_id);

    //流量统计
    virtual void TrafficData(ssize_t _send, ssize_t _recv);

    //底层询问上层该host对应的ip列表
    virtual std::vector<std::string> OnNewDns(const std::string &host, bool _longlink_host);
    //网络层收到push消息回调
    virtual void OnPush(const std::string &_channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer &_body, const AutoBuffer &_extend);
    //底层获取task要发送的数据
    virtual bool Req2Buf(uint32_t _taskid, void *const _user_context, const std::string &_user_id, AutoBuffer &outbuffer, AutoBuffer &extend, int &error_code, const int channel_select, const std::string &host);
    //底层回包返回给上层解析
    virtual int Buf2Resp(uint32_t _taskid, void *const _user_context, const std::string &_user_id, const AutoBuffer &_inbuffer, const AutoBuffer &_extend, int &_error_code, const int _channel_select);
    //任务执行结束
    virtual int OnTaskEnd(uint32_t _taskid, void *const _user_context, const std::string &_user_id, int _error_type, int _error_code, const CgiProfile &_profile);

    //上报网络连接状态
    virtual void ReportConnectStatus(int _status, int _longlink_status);
    virtual void OnLongLinkNetworkError(ErrCmdType _err_type, int _err_code, const std::string &_ip, uint16_t _port) {}
    virtual void OnShortLinkNetworkError(ErrCmdType _err_type, int _err_code, const std::string &_ip, const std::string &_host, uint16_t _port) {}

    virtual void OnLongLinkStatusChange(int _status);
    //长连信令校验 ECHECK_NOW = 0, ECHECK_NEXT = 1, ECHECK_NEVER = 2
    virtual int GetLonglinkIdentifyCheckBuffer(const std::string &_channel_id, AutoBuffer &_identify_buffer, AutoBuffer &_buffer_hash, int32_t &_cmdid);
    //长连信令校验回包
    virtual bool OnLonglinkIdentifyResponse(const std::string &_channel_id, const AutoBuffer &_response_buffer, const AutoBuffer &_identify_buffer_hash);

    virtual void RequestSync();

  private:
    static StnCallBack *instance_;
};
};  // namespace stn
};  // namespace mars

#endif /* StnCallback_hpp */

