//
//  NtpSync.hpp
//  ntp_sync
//
//  Created by king on 2024/11/16.
//

#ifndef NtpSync_hpp
#define NtpSync_hpp

#include "PlatformTime.hpp"

#include <memory>
#include <string>
#include <vector>

namespace time_sync {

struct SyncResult {
    double offset;     // 时间偏移
    double delay;      // 往返延迟
    double boottime;   // 同步时的boottime（纳秒）
    double sync_time;  // 同步时的服务器时间

    bool isValid() const;
};

class NtpSync {
  public:
    explicit NtpSync(std::unique_ptr<PlatformTime> platform_time);
    ~NtpSync();

    // 配置
    void setServer(const std::string &server);
    void setSyncTimes(int times);  // 设置同步次数
    void setTimeout(int seconds);  // 设置超时时间

    // 同步操作
    bool sync();  // 执行同步

    // 获取时间
    double getServerTime() const;                  // 获取服务器时间（秒）
    std::string getFormattedServerTime() const;    // 获取格式化的服务器时间
    std::string getFormattedTime(time_t t) const;  // 获取格式化的时间（秒）

    // 状态查询
    bool isSynced() const;                              // 是否已同步
    double getTimeSinceLastSync() const;                // 获取上次同步后的时间（秒）
    bool needResync(double max_interval = 3600) const;  // 是否需要重新同步

  private:
    SyncResult syncOnce();  // 单次同步

    std::unique_ptr<PlatformTime> platform_time_;
    std::string server_;
    int sync_times_{3};   // 默认同步3次
    int timeout_sec_{1};  // 默认超时1秒

    uint64_t base_boottime_{0};   // 同步时的boottime（纳秒）
    double base_server_time_{0};  // 同步时的服务器时间（秒）
    bool is_synced_{false};
};

}  // namespace time_sync

#endif /* NtpSync_hpp */
