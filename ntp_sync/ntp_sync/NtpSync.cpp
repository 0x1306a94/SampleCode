//
//  NtpSync.cpp
//  ntp_sync
//
//  Created by king on 2024/11/16.
//

#include "NtpSync.hpp"

#include <algorithm>
#include <arpa/inet.h>
#include <ctime>
#include <iomanip>
#include <netdb.h>
#include <netinet/in.h>
#include <sstream>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

#include <iostream>

namespace time_sync {

// NTP时间从1900年开始,需要和Unix时间(1970年开始)转换
constexpr uint64_t NTP_TIMESTAMP_DELTA = 2208988800ull;

// NTP报文结构
struct NtpPacket {
    uint8_t li_vn_mode;        // 2位闰秒标识符, 3位版本号, 3位模式
    uint8_t stratum;           // 时钟层级
    uint8_t poll;              // 轮询间隔
    uint8_t precision;         // 精度
    uint32_t root_delay;       // 系统延迟
    uint32_t root_dispersion;  // 系统色散
    uint32_t ref_id;           // 参考标识符
    uint32_t ref_ts_sec;       // 参考时间戳 秒
    uint32_t ref_ts_frac;      // 参考时间戳 分数部分
    uint32_t orig_ts_sec;      // 原始时间戳 秒
    uint32_t orig_ts_frac;     // 原始时间戳 分数部分
    uint32_t recv_ts_sec;      // 接收时间戳 秒
    uint32_t recv_ts_frac;     // 接收时间戳 分数部分
    uint32_t trans_ts_sec;     // 传输时间戳 秒
    uint32_t trans_ts_frac;    // 传输时间戳 分数部分
};

// 判断是否为有效的同步结果
bool SyncResult::isValid() const {
    constexpr double EPSINON = 0.000001;
    return delay >= EPSINON;
}

NtpSync::NtpSync(std::unique_ptr<PlatformTime> platform_time)
    : platform_time_(std::move(platform_time)) {}

NtpSync::~NtpSync() = default;

void NtpSync::setServer(const std::string &server) {
    server_ = server;
}

void NtpSync::setSyncTimes(int times) {
    sync_times_ = times;
}

void NtpSync::setTimeout(int seconds) {
    timeout_sec_ = seconds;
}

bool NtpSync::sync() {
    std::vector<SyncResult> results;
    results.reserve(sync_times_);

    // 执行多次同步
    for (int i = 0; i < sync_times_; ++i) {
        auto result = syncOnce();
        if (result.isValid()) {  // 只保存有效的结果
            results.push_back(result);
        }
    }

    if (results.empty()) {
        return false;
    }

    // 按往返延迟排序
    std::sort(results.begin(), results.end(), [](const SyncResult &a, const SyncResult &b) {
        return a.delay < b.delay;
    });

    // 使用延迟最小的结果
    const auto &best_result = results.front();
    base_boottime_ = best_result.boottime;
    base_server_time_ = best_result.sync_time;
    is_synced_ = true;

    return true;
}

SyncResult NtpSync::syncOnce() {
    SyncResult result = {0, 0, 0};

    // 解析服务器地址
    struct addrinfo hints = {}, *servinfo;
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;

    if (getaddrinfo(server_.c_str(), "123", &hints, &servinfo) != 0) {
        return result;
    }

    // 创建socket
    int sockfd = socket(servinfo->ai_family, servinfo->ai_socktype, servinfo->ai_protocol);
    if (sockfd < 0) {
        freeaddrinfo(servinfo);
        return result;
    }

    // 设置超时
    struct timeval tv;
    tv.tv_sec = timeout_sec_;
    tv.tv_usec = 0;
    setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    // 准备NTP请求包
    NtpPacket packet = {};
    packet.li_vn_mode = 0x1b;  // LI = 0, VN = 3, Mode = 3 (客户端)

    // 记录发送时间 (t1)
    struct timeval tv_t1;
    gettimeofday(&tv_t1, nullptr);
    double t1 = tv_t1.tv_sec + tv_t1.tv_usec / 1e6;

    // 发送请求
    if (sendto(sockfd, &packet, sizeof(packet), 0, servinfo->ai_addr, servinfo->ai_addrlen) < 0) {
        close(sockfd);
        freeaddrinfo(servinfo);
        return result;
    }

    // 接收响应
    if (recvfrom(sockfd, &packet, sizeof(packet), 0, nullptr, nullptr) < 0) {
        close(sockfd);
        freeaddrinfo(servinfo);
        return result;
    }

    // 记录接收时间 (t4)
    struct timeval tv_t4;
    gettimeofday(&tv_t4, nullptr);
    double t4 = tv_t4.tv_sec + tv_t4.tv_usec / 1e6;

    // 转换网络字节序
    packet.recv_ts_sec = ntohl(packet.recv_ts_sec);
    packet.recv_ts_frac = ntohl(packet.recv_ts_frac);
    packet.trans_ts_sec = ntohl(packet.trans_ts_sec);
    packet.trans_ts_frac = ntohl(packet.trans_ts_frac);

    // 转换NTP时间戳为Unix时间戳
    double t2 = (packet.recv_ts_sec - NTP_TIMESTAMP_DELTA) + (double)packet.recv_ts_frac / 0x100000000;
    double t3 = (packet.trans_ts_sec - NTP_TIMESTAMP_DELTA) + (double)packet.trans_ts_frac / 0x100000000;

    // 计算往返延迟和偏移
    result.delay = (t4 - t1) - (t3 - t2);
    result.offset = ((t2 - t1) + (t3 - t4)) / 2;

    result.boottime = platform_time_->getBootTimeNs();
    // 计算同步时的服务器时间
    result.sync_time = t4 + result.offset;

#ifdef DEBUG
    // 添加调试输出
    std::cerr << "DEBUG: "
              << "本地发送时间(t1)=" << getFormattedTime(t1)
              << ", 服务器接收时间(t2)=" << getFormattedTime(t2)
              << ", 服务器发送时间(t3)=" << getFormattedTime(t3)
              << ", 本地接收时间(t4)=" << getFormattedTime(t4)
              << ", 延迟=" << result.delay
              << ", 偏移=" << result.offset
              << ", 同步时服务器时间=" << getFormattedTime(result.sync_time)
              << std::endl;
#endif

    close(sockfd);
    freeaddrinfo(servinfo);
    return result;
}

double NtpSync::getServerTime() const {
    if (!is_synced_) {
        return 0;
    }
    uint64_t now = platform_time_->getBootTimeNs();
    double elapsed = (now - base_boottime_) / 1e9;
    return base_server_time_ + elapsed;
}

std::string NtpSync::getFormattedServerTime() const {
    time_t server_time = static_cast<time_t>(getServerTime());
    struct tm *timeinfo = localtime(&server_time);
    char buffer[80];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", timeinfo);
    return std::string(buffer);
}

std::string NtpSync::getFormattedTime(time_t t) const {
    time_t time = static_cast<time_t>(t);
    struct tm *timeinfo = localtime(&time);
    char buffer[80];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", timeinfo);
    return std::string(buffer);
}

bool NtpSync::isSynced() const {
    return is_synced_;
}

double NtpSync::getTimeSinceLastSync() const {
    if (!is_synced_) {
        return 0;
    }
    uint64_t now = platform_time_->getBootTimeNs();
    return (now - base_boottime_) / 1e9;
}

bool NtpSync::needResync(double max_interval) const {
    return !is_synced_ || getTimeSinceLastSync() > max_interval;
}

}  // namespace time_sync
