## 0.6.0

### New Features

- **Exposed Core API**: You can now use `NextcloudService` directly to build your own custom UI.
- **Added `connect()` method**: New method in `NextcloudService` to verify connection and credentials.
- **Upload Progress**: `uploadFile` now supports an `onProgress` callback.
- **Custom UI Example**: Added a comprehensive example demonstrating how to use the API directly.

## 0.5.1

### Improvements

- Minor documentation updates
- Package metadata improvements

## 0.5.0

### Improvements

- Improved package documentation

## 0.4.0

### Quality Improvements

- **Removed all debug print statements** from production code for better pub.dev score
  - Removed 86 print statements across all library files
  - Code now passes static analysis with minimal warnings
- **Updated dependencies** to support latest stable versions:
  - `file_picker`: Updated constraint from `^8.1.2` to `^10.0.0` (now supports latest 10.3.3)
- Improved code quality and linting compliance
- Fixed unused variable warnings

### Breaking Changes

None - this is a quality improvement release.

## 0.3.0

### Documentation & Formatting

- Fixed formatting and indentation in documentation files
- Fixed indentation in example app Info.plist files for consistency
- Fixed formatting in AndroidManifest.xml files
- Improved documentation readability

## 0.2.0

### Breaking Changes

- **Removed automatic permission handling**: The package no longer automatically requests storage permissions. Users must now handle permission requests in their own app before using download/upload features. This provides better control and transparency for app developers.
- Removed `permission_handler` dependency from the package

### Migration Guide

To update from 0.1.0 to 0.2.0:

1. Add `permission_handler: ^11.0.1` to your app's `pubspec.yaml`
2. Add required permissions to `AndroidManifest.xml` and `Info.plist` (see README)
3. Request permissions before downloading/uploading files (see EXAMPLES.md for complete implementation)

### Why This Change?

Moving permission handling to the app level:

- Gives developers full control over permission UX flow
- Allows customization of permission prompts and messaging
- Makes the package more transparent about its requirements
- Follows Flutter plugin best practices

See [README.md](README.md#permissions) and [EXAMPLES.md](EXAMPLES.md#prerequisites-permission-handling) for detailed implementation guides.

## 0.1.0

- Initial release
- Support for browsing Nextcloud directories
- Download files from Nextcloud
- Upload files to Nextcloud
- Create folders
- Delete files and folders
- Rename files and folders
- Support for public shares and authenticated accounts
- Cross-platform support (iOS, Android, Web, Desktop)
- WebDAV protocol implementation
- Pre-built UI screens for configuration and browsing
