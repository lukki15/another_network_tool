class WifiInfo {
  final String? routerIp;
  final String? macAddress;
  final int? networkId;
  final int? frequency;
  final int? channel;
  final int? linkSpeed;
  final int? signalStrength;
  final bool? isHiddenSSID;

  WifiInfo({
    this.routerIp,
    this.macAddress,
    this.networkId,
    this.frequency,
    this.channel,
    this.linkSpeed,
    this.signalStrength,
    this.isHiddenSSID,
  });

  factory WifiInfo.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return WifiInfo();

    return WifiInfo(
      routerIp: map['routerIp'] as String?,
      macAddress: map['macAddress'] as String?,
      networkId: (map['networkId'] is int) ? map['networkId'] as int : null,
      frequency: (map['frequency'] is int) ? map['frequency'] as int : null,
      channel: (map['channel'] is int) ? map['channel'] as int : null,
      linkSpeed: (map['linkSpeed'] is int) ? map['linkSpeed'] as int : null,
      signalStrength: (map['signalStrength'] is int)
          ? map['signalStrength'] as int
          : null,
      isHiddenSSID: map['isHiddenSSID'] as bool?,
    );
  }
}
