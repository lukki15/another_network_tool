class Subnet {
  final String
  networkAddress; // dotted decimal network address (e.g. 192.168.0.0)
  final int prefixLength; // CIDR prefix length (e.g. 24)

  Subnet(this.networkAddress, this.prefixLength);

  @override
  String toString() => '$networkAddress/$prefixLength';

  static int _ipToInt(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) {
      throw FormatException('Invalid IPv4 address');
    }
    int res = 0;
    for (var p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) {
        throw FormatException('Invalid IPv4 address');
      }
      res = (res << 8) | n;
    }
    return res;
  }

  static String _intToIp(int value) {
    return '${(value >> 24) & 0xFF}.${(value >> 16) & 0xFF}.${(value >> 8) & 0xFF}.${value & 0xFF}';
  }

  static int _maskToInt(String mask) {
    final parts = mask.split('.');
    if (parts.length != 4) {
      throw FormatException('Invalid subnet mask');
    }
    int res = 0;
    for (var p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) {
        throw FormatException('Invalid subnet mask');
      }
      res = (res << 8) | n;
    }
    return res;
  }

  static int _countOnes(int v) {
    int c = 0;
    while (v != 0) {
      c += v & 1;
      v = v >> 1;
    }
    return c;
  }

  /// Create Subnet from an IPv4 address and an IPv4 subnet mask (both dotted).
  /// Throws [FormatException] for invalid inputs or non-contiguous masks.
  static Subnet fromIpAndMask(String ip, String mask) {
    final ipInt = _ipToInt(ip);
    final maskInt = _maskToInt(mask);

    // Check mask is contiguous ones followed by zeros
    final prefix = _countOnes(maskInt);
    if (prefix < 0 || prefix > 32) {
      throw FormatException('Invalid subnet mask');
    }
    final rebuiltMask = prefix == 0 ? 0 : (~0 << (32 - prefix)) & 0xFFFFFFFF;
    if (rebuiltMask != maskInt) {
      throw FormatException('Non-contiguous subnet mask');
    }

    final networkInt = ipInt & maskInt;
    final networkAddr = _intToIp(networkInt);
    return Subnet(networkAddr, prefix);
  }

  /// First usable host IP as int (may be > lastHostInt if none)
  int firstHostInt() {
    final net = _ipToInt(networkAddress);
    if (prefixLength >= 31) {
      return net; // /31 and /32 have no usable hosts in classic sense
    }
    return net + 1;
  }

  /// Last usable host IP as int
  int lastHostInt() {
    final net = _ipToInt(networkAddress);
    final mask = prefixLength == 0
        ? 0
        : (~0 << (32 - prefixLength)) & 0xFFFFFFFF;
    final broadcast = net | (~mask & 0xFFFFFFFF);
    if (prefixLength >= 31) {
      return broadcast; // /31 or /32
    }
    return broadcast - 1;
  }
}
