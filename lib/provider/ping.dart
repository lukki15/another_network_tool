import 'dart:async';
import 'package:dart_ping/dart_ping.dart';

class PingRange {
  final String subnet;

  // We change the stream type to PingData (or a custom wrapper) to hold the result
  final Stream<PingData> _stream;
  Stream<PingData> get stream => _stream;

  static Stream<PingData> _createStream(final String subnet) {
    final int firstHostId = 1;
    final int lastHostId = 254;
    // 1. Generate the list of addresses
    final addresses = List.generate(lastHostId - firstHostId + 1, (index) {
      final int hostId = firstHostId + index;
      return '$subnet.$hostId';
    });

    // 2. Create a stream from the list
    return Stream.fromIterable(addresses)
        // 3. Asynchronously map each address string to a PingData future
        .asyncMap<PingData>((String ipString) async {
          try {
            // Create the Ping instance
            // Note: dart_ping usually requires a timeout or count configuration
            final ping = Ping(ipString, count: 1);

            // Wait for the stream to complete (since we only want count: 1)
            // We take the first event or wait for the stream to close
            final result = await ping.stream.firstWhere(
              (event) => event.response != null,
              orElse: () => throw Exception('Timeout'),
            );

            return result;
          } catch (e) {
            // Handle timeouts or unreachable hosts gracefully
            // You might want to create a custom 'PingResult' class to include the IP and status
            print('Failed to ping $ipString: $e');
            // Re-throw or return null depending on if you want to keep failed hosts in the stream
            rethrow;
          }
        })
        // 4. Filter out any errors if you used 'catchError' inside,
        // or simply let the stream error out if you want strict behavior.
        // Here we assume we only want successful pings:
        .where((pingData) => pingData.response != null);
  }

  PingRange({required this.subnet}) : _stream = _createStream(subnet);
}
