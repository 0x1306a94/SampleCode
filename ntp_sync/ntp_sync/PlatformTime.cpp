//
//  PlatformTime.cpp
//  ntp_sync
//
//  Created by king on 2024/11/16.
//

#include "PlatformTime.hpp"

#include <mach/mach_time.h>
#include <sys/sysctl.h>
#include <time.h>

namespace time_sync {
//class MacPlatformTime : public PlatformTime {
//  public:
//    MacPlatformTime() {
//        mach_timebase_info(&timebase_info_);
//    }
//
//    uint64_t getBootTimeNs() override {
//        uint64_t time = mach_absolute_time();
//        return time * timebase_info_.numer / timebase_info_.denom;
//    }
//
//  private:
//    mach_timebase_info_data_t timebase_info_;
//};

class MacPlatformTime : public PlatformTime {
  public:
    uint64_t getBootTimeNs() override {
        struct timeval boottime;
        size_t len = sizeof(boottime);
        int mib[2] = {CTL_KERN, KERN_BOOTTIME};

        if (sysctl(mib, 2, &boottime, &len, nullptr, 0) < 0) {
            return 0;
        }

        // 获取当前时间
        struct timeval now;
        gettimeofday(&now, nullptr);

        // 计算从启动到现在的纳秒数
        int64_t sec_diff = now.tv_sec - boottime.tv_sec;
        int64_t usec_diff = now.tv_usec - boottime.tv_usec;

        // 转换为纳秒
        return (sec_diff * 1000000000LL + usec_diff * 1000LL);
    }
};

std::unique_ptr<PlatformTime> createPlatformTime() {
    return std::make_unique<MacPlatformTime>();
}

}  // namespace time_sync
