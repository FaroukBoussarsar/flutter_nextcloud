class NextcloudConfig {
  final String baseUrl;
  final String username;
  final String password;

  NextcloudConfig({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  // For public shares, username is the share token
  factory NextcloudConfig.publicShare({
    required String serverUrl,
    required String shareToken,
    String password = '',
  }) {
    return NextcloudConfig(
      baseUrl: '$serverUrl/public.php/webdav',
      username: shareToken,
      password: password,
    );
  }

  // For authenticated users
  factory NextcloudConfig.authenticated({
    required String serverUrl,
    required String username,
    required String password,
  }) {
    return NextcloudConfig(
      baseUrl: '$serverUrl/remote.php/dav/files/$username',
      username: username,
      password: password,
    );
  }
}
