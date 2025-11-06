import 'package:flutter/material.dart';
import 'models/nextcloud_config.dart';
import 'screens/configuration_screen.dart';
import 'screens/nextcloud_browser_screen.dart';

/// Main widget for Flutter Nextcloud package.
///
/// This widget provides a complete Nextcloud browser interface with customizable
/// theme colors and optional pre-configuration.
class FlutterNextcloud extends StatelessWidget {
  /// Primary color for the app theme
  final Color? primaryColor;

  /// Secondary color for the app theme
  final Color? secondaryColor;

  /// Optional custom app title displayed in the app bar
  final String? title;

  /// Optional custom AppBar widget for the configuration screen
  /// If provided, this will override the default AppBar with title
  final PreferredSizeWidget? configurationAppBar;

  /// Optional custom AppBar widget for the browser screen
  /// If provided, this will override the default AppBar with title
  final PreferredSizeWidget? browserAppBar;

  /// Optional pre-configured server URL
  /// If provided, the configuration screen will be pre-filled
  final String? serverUrl;

  /// Optional pre-configured share token (for public shares) or username (for authenticated)
  final String? shareToken;

  /// Optional password
  final String? password;

  /// If true, skips the configuration screen and goes directly to the browser
  /// Requires serverUrl and shareToken to be provided
  final bool autoConnect;

  /// If true, uses public share mode; if false, uses authenticated user mode
  final bool isPublicShare;

  const FlutterNextcloud({
    super.key,
    this.primaryColor,
    this.secondaryColor,
    this.title,
    this.configurationAppBar,
    this.browserAppBar,
    this.serverUrl,
    this.shareToken,
    this.password,
    this.autoConnect = false,
    this.isPublicShare = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor = primaryColor ?? Colors.blue;
    final effectiveTitle = title ?? 'Nextcloud Browser';

    return MaterialApp(
      title: effectiveTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: effectivePrimaryColor,
          secondary:
              secondaryColor ?? effectivePrimaryColor.withValues(alpha: 0.8),
        ),
        useMaterial3: true,
      ),
      home: _buildHomePage(),
    );
  }

  Widget _buildHomePage() {
    // If autoConnect is true and credentials are provided, go directly to browser
    if (autoConnect && serverUrl != null && shareToken != null) {
      final config = isPublicShare
          ? NextcloudConfig.publicShare(
              serverUrl: serverUrl!,
              shareToken: shareToken!,
              password: password ?? '',
            )
          : NextcloudConfig.authenticated(
              serverUrl: serverUrl!,
              username:
                  shareToken!, // shareToken is username in authenticated mode
              password: password ?? '',
            );

      return NextcloudBrowserScreen(
        config: config,
        title: title,
        customAppBar: browserAppBar,
      );
    }

    // Otherwise, show configuration screen with optional pre-filled values
    return ConfigurationScreen(
      title: title,
      customAppBar: configurationAppBar,
      initialServerUrl: serverUrl,
      initialShareToken: shareToken,
      initialPassword: password,
      initialIsPublicShare: isPublicShare,
      primaryColor: primaryColor,
    );
  }
}
