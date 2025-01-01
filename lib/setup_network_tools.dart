import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_tools/network_tools.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> _getDirectory() {
  return getApplicationSupportDirectory();
}

Future<void> _copyMacVendorCsvFile() async {
  const String fileName = "mac-vendors-export.csv";

  // Get the application's documents directory
  final directory = await _getDirectory();

  // Construct the path for the destination file
  final filePath = '${directory.path}/$fileName';

  try {
    // Load the file from assets
    final byteData = await rootBundle.load('assets/network_tools/$fileName');

    // Write the bytes to a new file
    await File(filePath).writeAsBytes(byteData.buffer.asUint8List());
  } catch (e) {
    // fallback to downloading the file
  }
}

Future<void> setupNetworkTools() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _copyMacVendorCsvFile();

  final directory = await _getDirectory();
  return configureNetworkTools(directory.path);
}
