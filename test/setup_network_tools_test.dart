import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:another_network_tool/setup_network_tools.dart';

void main() {
  test('setup network tools completes successfully', () async {
    // Pre-check: Ensure files don't exist before test
    final directory = Directory("./test");
    final csvFile = File('${directory.path}/mac-vendors-export.csv');
    final dbFile = File('${directory.path}/network_tools.db');

    expect(
      csvFile.existsSync(),
      false,
      reason: 'CSV file should not exist before test',
    );
    expect(
      dbFile.existsSync(),
      false,
      reason: 'Database file should not exist before test',
    );

    // Execute the test
    await setupNetworkTools(directory);

    // Post-check: Verify files were created
    expect(
      csvFile.existsSync(),
      true,
      reason: 'CSV file should exist after setup',
    );
    expect(
      dbFile.existsSync(),
      true,
      reason: 'Database file should exist after setup',
    );

    // Cleanup
    await csvFile.delete();
    await dbFile.delete();

    // Verify cleanup
    expect(
      csvFile.existsSync(),
      false,
      reason: 'CSV file should be deleted after cleanup',
    );
    expect(
      dbFile.existsSync(),
      false,
      reason: 'Database file should be deleted after cleanup',
    );
  });
}
