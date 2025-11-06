# Nextcloud Browser App

A Flutter application to browse, download, and manage files from any Nextcloud server - both public shares and authenticated user accounts.

## Features

- 📁 Browse folder structure from any Nextcloud server
- 📥 Download files to your device
- 📤 Upload files to Nextcloud
- ➕ Create new folders
- 🗑️ Delete files and folders
- ✏️ Rename files and folders
- 🔍 View file sizes and modification dates
- 🔙 Navigate through folders with back button
- 🔐 Support for both public shares and authenticated accounts
- 📱 Cross-platform support (iOS, Android, Web, Desktop)

## Configuration

The app uses a configuration screen where you can input your Nextcloud server details:

- **Server URL**: Your Nextcloud server URL (e.g., https://cloud.example.com)
- **Share Token or Username**: Depending on connection type
- **Password**: Optional for public shares, required for user accounts

### For Public Shares

1. Get your share link from Nextcloud (e.g., https://cloud.example.com/s/abcdefghijklmno)
2. Extract the token (the part after /s/, e.g., "abcdefghijklmno")
3. Enter your server URL and token in the configuration screen

### For Authenticated Users

1. Enter your Nextcloud server URL
2. Enter your username and password
3. Connect to browse your personal files

You can also edit the code to set default values in `lib/screens/configuration_screen.dart`:

```dart
final _serverUrlController = TextEditingController(
  text: 'https://your-nextcloud-server.com',
);
final _usernameController = TextEditingController(text: 'your-token-or-username');
```

## Setup and Installation

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- For Android: Android Studio and SDK
- For iOS: Xcode (Mac only)

### Installation Steps

1. **Clone or navigate to the project directory**

   ```bash
   cd flutter_nextcloud
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   For Android:

   ```bash
   flutter run -d android
   ```

   For iOS (Mac only):

   ```bash
   flutter run -d ios
   ```

   For Web:

   ```bash
   flutter run -d chrome
   ```

   For Desktop:

   ```bash
   flutter run -d macos    # Mac
   flutter run -d windows  # Windows
   flutter run -d linux    # Linux
   ```

## How to Use

1. **Launch the app** - Enter your Nextcloud server details on the configuration screen
2. **Browse folders** - Tap on any folder to navigate into it
3. **Download files** - Tap on a file to see details, then use the download button
4. **Upload files** - Use the upload button to add files to the current directory
5. **Create folders** - Use the create folder button to organize your files
6. **Manage items** - Long press or use context menu to rename or delete items
7. **Go back** - Use the back button in the app bar to return to the previous folder
8. **Refresh** - Use the refresh button to reload the current directory

## Downloaded Files Location

Files are saved to different locations depending on the platform:

- **Android**: `/storage/emulated/0/Android/data/com.example.flutter_nextcloud/files/NextcloudDownloads/`
- **iOS**: App Documents directory under `NextcloudDownloads/`
- **Desktop**: Downloads folder under `NextcloudDownloads/`

## Permissions

### Android

The app requires the following permissions (already configured in AndroidManifest.xml):

- `INTERNET` - To access Nextcloud server
- `WRITE_EXTERNAL_STORAGE` - To save downloaded files
- `READ_EXTERNAL_STORAGE` - To access storage

### iOS

The app requires the following permissions (already configured in Info.plist):

- Photo Library access - To save downloaded files

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── nextcloud_config.dart         # Configuration model
│   └── nextcloud_item.dart           # Data model for files/folders
├── services/
│   └── nextcloud_service.dart        # Nextcloud API communication
└── screens/
    ├── configuration_screen.dart     # Server configuration UI
    └── nextcloud_browser_screen.dart # Main browser UI
```

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
```

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
