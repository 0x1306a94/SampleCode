//
//  shortlink_packer.cpp
//  MarsSTNSample
//
//  Created by king on 2022/11/18.
//

#include "shortlink_packer.hpp"

#include <iostream>
#include <mars/comm/http.h>

using namespace http;
namespace mars {

namespace stn {

shortlink_tracker *(*shortlink_tracker::Create)() = []() {
    return new shortlink_tracker;
};

void (*shortlink_pack)(const std::string &_url, const std::map<std::string, std::string> &_headers, const AutoBuffer &_body, const AutoBuffer &_extension, AutoBuffer &_out_buff, shortlink_tracker *_tracker) = [](const std::string &_url, const std::map<std::string, std::string> &_headers, const AutoBuffer &_body, const AutoBuffer &_extension, AutoBuffer &_out_buff, shortlink_tracker *_tracker) {
    Builder req_builder(kRequest);
    req_builder.Request().Method(RequestLine::kGet);
    req_builder.Request().Version(kVersion_1_1);

    req_builder.Fields().HeaderFiled(HeaderFields::MakeAcceptAll());
    req_builder.Fields().HeaderFiled(HeaderFields::KStringUserAgent, HeaderFields::KStringMicroMessenger);
    req_builder.Fields().HeaderFiled(HeaderFields::MakeCacheControlNoCache());
    req_builder.Fields().HeaderFiled(HeaderFields::MakeContentTypeOctetStream());
    req_builder.Fields().HeaderFiled(HeaderFields::MakeConnectionClose());

    char len_str[32] = {0};
    snprintf(len_str, sizeof(len_str), "%u", (unsigned int)_body.Length());
    req_builder.Fields().HeaderFiled(HeaderFields::KStringContentLength, len_str);

    for (std::map<std::string, std::string>::const_iterator iter = _headers.begin(); iter != _headers.end(); ++iter) {
        req_builder.Fields().HeaderFiled(iter->first.c_str(), iter->second.c_str());
    }

    req_builder.Request().Url(_url);
    req_builder.HeaderToBuffer(_out_buff);
    _out_buff.Write(_body.Ptr(), _body.Length());
    std::cout << "http request: \n"
              << (char *)_out_buff.Ptr() << std::endl;
};

};  // namespace stn
};  // namespace mars

