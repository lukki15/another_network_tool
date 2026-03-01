# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-03-01
### Added
- Display the first n closed ports in the PortGroup widget.
- Copy content when long pressing on text fields.
- Comprehensive unit tests for widgets, pages, and providers.
- Automatic release publishing for main branch builds.
- Build number based on GitHub Actions run number.

### Changed
- Separated network info logic from page UI for better maintainability.
- Converted ConnectivityManager to ChangeNotifier pattern.
- Use HostScannerService via dependency injection.
- Updated Android Gradle and Java compatibility to v17.

### Fixed
- Properly initialize the Flutter binding in main.
- Cancel port scanning stream when widget gets disposed.
- Restore internet user permission for network operations.

## [0.1.0] - 2024-12-23
### Added
- Display detailed information about your current Wi-Fi connection.
- List all devices connected to your Wi-Fi network.
- Scan open ports for selected devices.
- Only scan or fetch the network information if the Wi-Fi is connected.
- Use the forui framework instead of the default material design.
