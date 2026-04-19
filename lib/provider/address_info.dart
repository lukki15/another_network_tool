import 'dart:async';
import 'dart:io';

class AddressInfo {
  final String address;
  final bool isReachable;

  AddressInfo({required this.address, required this.isReachable});

  Future<InternetAddress> getAddress() {
    if (isReachable) {
      return InternetAddress(address, type: InternetAddressType.IPv4).reverse();
    } else {
      return Future.error("Host $address is not reachable");
    }
  }

  Future<String> getHostName() {
    return getAddress()
        .then((InternetAddress address) {
          return address.host;
        })
        .onError((error, stackTrace) {
          return Future.value("Generic Device");
        });
  }
}
