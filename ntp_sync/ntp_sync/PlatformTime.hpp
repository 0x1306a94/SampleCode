//
//  PlatformTime.hpp
//  ntp_sync
//
//  Created by king on 2024/11/16.
//

#ifndef PlatformTime_hpp
#define PlatformTime_hpp

#include <memory>

namespace time_sync {
class PlatformTime {
  public:
    virtual ~PlatformTime() = default;

    // 获取boottime（纳秒）
    virtual uint64_t getBootTimeNs() = 0;
};

// 创建平台相关的实现
std::unique_ptr<PlatformTime> createPlatformTime();

}  // namespace time_sync

#endif /* PlatformTime_hpp */
