# Network Info App

[![Android](https://github.com/lukki15/network_info_app/actions/workflows/android.yml/badge.svg)](https://github.com/lukki15/network_info_app/actions/workflows/android.yml)
[![Linux](https://github.com/lukki15/network_info_app/actions/workflows/linux.yml/badge.svg)](https://github.com/lukki15/network_info_app/actions/workflows/linux.yml)

[![Dependabot Updates](https://github.com/lukki15/network_info_app/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/lukki15/network_info_app/actions/workflows/dependabot/dependabot-updates)

Network Info App is an open source application that provides detailed information about devices connected to your local Wi-Fi network.

## Key Features

- [x] List all devices connected to your Wi-Fi network
- [x] Display detailed information about your current Wi-Fi connection
- [x] Scan open ports for selected devices

## Getting Started

1. Clone this repository
1. Run `flutter pub get` to install dependencies
1. Run `flutter run` to launch the app

### Development Setup

#### VS Code Dev Container

This project uses a VS Code dev container for development. To set up the dev environment:

1. Install the VS Code Remote - Containers extension
1. Rebuild the container using the "Reopen in Container" command
1. Follow the commands to download and setup the Flutter SDK.

## Technologies Used

- [Flutter](https://flutter.dev) framework
- [forui](https://forui.dev/) flutter UI library
- [permission_handler](https://pub.dev/packages/permission_handler) to request permissions and check their status.
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)to discover network connectivity types that can be used.
- [network_info_plus](https://pub.dev/packages/network_info_plus) to discover network info and configure themselves accordingly.
- [network_tools](https://pub.dev/packages/network_tools) to scan all devices in a subnet.
  - Requires `arp` command on Linux (`sudo apt-get install net-tools`)
- [path_provider](https://pub.dev/packages/path_provider) for finding commonly used locations on the filesystem.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request.

### Conventional Commits

This project uses [conventional commits](https://www.conventionalcommits.org). When submitting a pull request or making changes, please follow the Conventional Commits specification. This ensures consistency in commit messages and makes it easier to generate changelogs.

## License
Everything in this repo is license under the [GPLv3](./LICENSE) license.
