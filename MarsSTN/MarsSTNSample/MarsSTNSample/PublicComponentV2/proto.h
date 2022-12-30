//
//  proto.h
//  MarsSTNSample
//
//  Created by king on 2022/12/30.
//

#ifndef proto_h
#define proto_h

namespace mars {
namespace stn {
enum ConnectionStatus {
    kConnectionStatusSecretKeyMismatch = -6,
    kConnectionStatusTokenIncorrect = -5,
    kConnectionStatusServerDown = -4,
    kConnectionStatusRejected = -3,
    kConnectionStatusLogout = -2,
    kConnectionStatusUnconnected = -1,
    kConnectionStatusConnecting = 0,
    kConnectionStatusConnected = 1,
    kConnectionStatusReceiving = 2
};

class ConnectionStatusCallback {
  public:
    virtual void onConnectionStatusChanged(ConnectionStatus connectionStatus) = 0;
};

}  // namespace stn
}  // namespace mars
#endif /* proto_h */

