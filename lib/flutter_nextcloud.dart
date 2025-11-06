/// A Flutter package for browsing, downloading, and managing files from Nextcloud servers.
///
/// This package provides a complete solution for interacting with Nextcloud servers
/// using the WebDAV protocol. It supports both public shares and authenticated user accounts.
library;

// Export main widget
export 'flutter_nextcloud_app.dart';

// Export models
export 'models/nextcloud_config.dart';
export 'models/nextcloud_item.dart';

// Export services
export 'services/nextcloud_service.dart';

// Export screens (optional - users can build their own UI)
export 'screens/configuration_screen.dart';
export 'screens/nextcloud_browser_screen.dart';
