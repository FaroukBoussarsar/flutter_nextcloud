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
