# Flutter Nextcloud

A Flutter package for browsing, downloading, and managing files from any Nextcloud server using the WebDAV protocol. Supports both public shares and authenticated user accounts.

## Features

- 📁 Browse folder structure from any Nextcloud server
- 📥 Download files to your device
- 📤 Upload files to Nextcloud
- ➕ Create new folders
- 🗑️ Delete files and folders
- ✏️ Rename files and folders
- 🔍 View file sizes and modification dates
- 🔙 Navigate through folders
- 🔐 Support for both public shares and authenticated accounts
- 📱 Cross-platform support (iOS, Android, Web, Desktop)
- 🎨 Pre-built UI screens (optional)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_nextcloud:
    git:
      url: https://github.com/FaroukBoussarsar/flutter_nextcloud.git
```

Or if published to pub.dev:

```yaml
dependencies:
  flutter_nextcloud: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Quick Start with FlutterNextcloud Widget

The simplest way to use the package is with the `FlutterNextcloud` widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nextcloud/flutter_nextcloud.dart';

void main() {
  runApp(const FlutterNextcloud());
}
```

### Custom Theme and Title

Customize colors and title:

```dart
void main() {
  runApp(
    const FlutterNextcloud(
      primaryColor: Colors.green,
      secondaryColor: Colors.teal,
      title: 'My Cloud Storage',
    ),
  );
}
```

### Pre-filled Configuration

Pre-fill server details (user can still modify):

```dart
void main() {
  runApp(
    const FlutterNextcloud(
      primaryColor: Colors.purple,
      title: 'Company Cloud',
      serverUrl: 'https://cloud.example.com',
      shareToken: 'your-share-token',
      password: 'optional-password',
    ),
  );
}
```

### Auto-Connect

Skip configuration screen and connect directly:

```dart
void main() {
  runApp(
    const FlutterNextcloud(
      serverUrl: 'https://cloud.example.com',
      shareToken: 'your-share-token',
      password: 'your-password',
      autoConnect: true,
      isPublicShare: true, // or false for authenticated user
    ),
  );
}
```

See [EXAMPLES.md](EXAMPLES.md) for more usage examples.

### Using the Service Directly

For custom UI implementations, use the `NextcloudService` directly:

```dart
import 'package:flutter_nextcloud/flutter_nextcloud.dart';

// Create a configuration for public share
final config = NextcloudConfig.publicShare(
  serverUrl: 'https://cloud.example.com',
  shareToken: 'your-share-token',
  password: '', // optional
);

// Or for authenticated user
final config = NextcloudConfig.authenticated(
  serverUrl: 'https://cloud.example.com',
  username: 'your-username',
  password: 'your-password',
);

// Create service instance
final service = NextcloudService(config);

// List directory contents
final items = await service.listDirectory('/');

// Download a file
await service.downloadFile(items[0], '/path/to/save/file.txt');

// Upload a file
await service.uploadFile(
  '/path/to/local/file.txt',
  '/remote/path/file.txt',
  onProgress: (sent, total) {
    print('Progress: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);

// Create a folder
await service.createFolder('/new-folder');

// Delete an item
await service.deleteItem('/path/to/item');

// Rename an item
await service.renameItem('/old-path', '/new-path');
```

## Models

### NextcloudConfig

Configuration for connecting to a Nextcloud server:

```dart
// Public share
NextcloudConfig.publicShare({
  required String serverUrl,
  required String shareToken,
  String password = '',
})

// Authenticated user
NextcloudConfig.authenticated({
  required String serverUrl,
  required String username,
  required String password,
})
```

### NextcloudItem

Represents a file or folder on the Nextcloud server:

```dart
class NextcloudItem {
  final String name;           // Display name
  final String href;           // Full path on server
  final bool isDirectory;      // true if folder, false if file
  final int size;             // File size in bytes
  final DateTime? lastModified; // Last modification date
}
```

## Example App

See the [example](example/) directory for a complete working app demonstrating all features.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Platform Support

| Platform | Supported |
| -------- | --------- |
| Android  | ✅        |
| iOS      | ✅        |
| Web      | ✅        |
| macOS    | ✅        |
| Windows  | ✅        |
| Linux    | ✅        |

## Permissions

### Android

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS

Add to `Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save downloaded files</string>
```

## Requirements

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

## How It Works

The package uses the **WebDAV protocol** to communicate with Nextcloud servers:

1. **Authentication**: Supports both public share tokens and user credentials via Basic Auth
2. **PROPFIND Method**: Lists directory contents with file metadata
3. **File Operations**:
   - GET for downloads
   - PUT for uploads with progress tracking
   - MKCOL for creating folders
   - DELETE for removing items
   - MOVE for renaming/moving items

## API Reference

### NextcloudService

Main service class for interacting with Nextcloud:

```dart
NextcloudService(NextcloudConfig config)

Future<List<NextcloudItem>> listDirectory(String path)
Future<void> downloadFile(NextcloudItem item, String savePath)
Future<void> uploadFile(String localFilePath, String remotePath, {Function(int sent, int total)? onProgress})
Future<void> createFolder(String folderPath)
Future<void> deleteItem(String itemPath)
Future<void> renameItem(String oldPath, String newPath)
```

## Troubleshooting

### Connection Issues

- Ensure you have internet connectivity
- Verify the Nextcloud server is accessible
- Check if the share token or credentials are correct
- Make sure the server URL includes the protocol (https:// or http://)

### Download/Upload Failures

- Check storage permissions are granted
- Ensure sufficient storage space
- Verify file is not corrupted on the server
- Check your network connection stability

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Dependencies

- `http: ^1.1.0` - HTTP client for API requests
- `xml: ^6.5.0` - XML parsing for WebDAV responses
- `path_provider: ^2.1.1` - Access to device file system
- `permission_handler: ^11.0.1` - Runtime permissions management
- `file_picker: ^8.1.2` - File picker for uploads

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions:

- 🐛 [Report bugs](https://github.com/FaroukBoussarsar/flutter_nextcloud/issues)
- 💡 [Request features](https://github.com/FaroukBoussarsar/flutter_nextcloud/issues)
- 📖 [View documentation](https://github.com/FaroukBoussarsar/flutter_nextcloud)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Author

**Farouk Boussarsar**

- GitHub: [@FaroukBoussarsar](https://github.com/FaroukBoussarsar)

```

### iOS

The app requires the following permissions (already configured in Info.plist):

- Photo Library access - To save downloaded files

## Project Structure

```

lib/
├── main.dart # App entry point
├── models/
│ ├── nextcloud_config.dart # Configuration model
│ └── nextcloud_item.dart # Data model for files/folders
├── services/
│ └── nextcloud_service.dart # Nextcloud API communication
└── screens/
├── configuration_screen.dart # Server configuration UI
└── nextcloud_browser_screen.dart # Main browser UI

````

## How It Works

1. **WebDAV Protocol**: The app uses WebDAV (Web Distributed Authoring and Versioning) protocol to communicate with Nextcloud
2. **Flexible Authentication**:
   - Public shares: Uses the share token as username with optional password
   - User accounts: Uses standard username/password authentication
3. **PROPFIND Method**: Uses the PROPFIND HTTP method to list directory contents
4. **File Operations**: Supports GET (download), PUT (upload), MKCOL (create folder), DELETE, and MOVE (rename) operations

## Customization

### Change App Theme

Edit the theme in `lib/main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Change color
  useMaterial3: true,
),
````

## Troubleshooting

### Connection Issues

- Ensure you have internet connectivity
- Verify the Nextcloud share/server is accessible
- Check if the share token or credentials are correct
- Make sure the server URL includes the protocol (https:// or http://)

### Download/Upload Failures

- Check storage permissions are granted
- Ensure sufficient storage space
- Verify file is not corrupted on the server
- Check your network connection stability

### Build Errors

- Run `flutter clean` then `flutter pub get`
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Check that all dependencies are compatible

## Dependencies

- `http: ^1.1.0` - HTTP client for API requests
- `xml: ^6.5.0` - XML parsing for WebDAV responses
- `path_provider: ^2.1.1` - Access to device file system
- `permission_handler: ^11.0.1` - Runtime permissions management
- `file_picker: ^8.1.2` - File picker for uploads

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or contributions, please open an issue in the project repository.
