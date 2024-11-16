//
//  main.cpp
//  ntp_sync
//
//  Created by king on 2024/11/16.
//

#include "NtpSync.hpp"

#include <iomanip>
#include <iostream>
#include <thread>

int main() {

    using namespace time_sync;

    // 创建NTP同步对象
    auto ntp = std::make_unique<NtpSync>(std::unique_ptr<PlatformTime>(createPlatformTime()));

    // 配置NTP服务器
    // Windows自带
    ntp->setServer("time.windows.com");
    // 苹果
    //    ntp->setServer("time.apple.com");
    // 阿里云
    //    ntp->setServer("ntp.aliyun.com");
    // 腾讯
    ntp->setServer("ntp.tencent.com");

    ntp->setSyncTimes(3);
    ntp->setTimeout(1);

    // 同步循环
    while (true) {
        if (ntp->needResync()) {
            std::cerr << "正在同步..." << std::endl;
            if (ntp->sync()) {
                std::cerr << "同步成功" << std::endl;
            } else {
                std::cerr << "同步失败" << std::endl;
                std::this_thread::sleep_for(std::chrono::seconds(1));
                continue;
            }
        }

        std::cerr << "当前服务器时间: " << ntp->getFormattedServerTime()
                  << " (上次同步: " << std::fixed << std::setprecision(1)
                  << ntp->getTimeSinceLastSync() << "秒前)"
                  << std::endl;

        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    return 0;
}
