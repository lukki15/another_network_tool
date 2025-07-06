import 'dart:async';

import 'package:another_network_tool/provider/connectivity_notifier.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

@GenerateNiceMocks([MockSpec<Connectivity>()])
import './connectivity_notifier_test.mocks.dart';

void main() {
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
  });

  group('ConnectivityNotifier', () {
    test('initializes with empty connection status', () {
      final connectivityNotifier = ConnectivityNotifier.withConnectivity(
        mockConnectivity,
      );
      expect(connectivityNotifier.connectionStatus, isEmpty);
    });

    test('_initConnectivity handles successful connectivity check', () async {
      // Arrange
      final mockResult = [ConnectivityResult.wifi];
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => mockResult);

      // Act
      final connectivityNotifier = ConnectivityNotifier.withConnectivity(
        mockConnectivity,
      );

      // Assert
      expect(connectivityNotifier.connectionStatus, isEmpty);
      connectivityNotifier.addListener(
        () => expect(connectivityNotifier.connectionStatus, mockResult),
      );

      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('_initConnectivity handles connectivity check error', () async {
      // Arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenThrow(Exception('Mock error'));

      // Act
      final connectivityNotifier = ConnectivityNotifier.withConnectivity(
        mockConnectivity,
      );

      // Assert
      expect(connectivityNotifier.connectionStatus, isEmpty);
      connectivityNotifier.addListener(
        () => expect(connectivityNotifier.connectionStatus, isEmpty),
      );

      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('listens to connectivity changes', () async {
      // Arrange
      final mockResult = [ConnectivityResult.mobile];
      final streamController = StreamController<List<ConnectivityResult>>();
      when(
        mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => streamController.stream);
      final connectivityNotifier = ConnectivityNotifier.withConnectivity(
        mockConnectivity,
      );

      // Act
      streamController.add(mockResult);

      // Assert
      int listenerCallCount = 0;
      connectivityNotifier.addListener(() {
        listenerCallCount++;
        if (listenerCallCount == 1) {
          expect(connectivityNotifier.connectionStatus, isEmpty);
        } else {
          expect(connectivityNotifier.connectionStatus, mockResult);
        }
      });
      verify(mockConnectivity.onConnectivityChanged).called(1);
    });

    test('disposes of stream subscription', () {
      final connectivityNotifier = ConnectivityNotifier.withConnectivity(
        mockConnectivity,
      );

      // Act
      connectivityNotifier.dispose();

      // Assert
      verify(mockConnectivity.onConnectivityChanged).called(1);
    });
  });
}
