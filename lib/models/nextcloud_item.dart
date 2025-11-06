class NextcloudItem {
  final String name;
  final String href;
  final bool isDirectory;
  final int? size;
  final DateTime? lastModified;

  NextcloudItem({
    required this.name,
    required this.href,
    required this.isDirectory,
    this.size,
    this.lastModified,
  });

  String get displaySize {
    if (size == null) return '';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(2)} KB';
    if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
