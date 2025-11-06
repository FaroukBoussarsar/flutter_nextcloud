import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/nextcloud_item.dart';
import '../models/nextcloud_config.dart';
import '../services/nextcloud_service.dart';
import 'configuration_screen.dart';

class NextcloudBrowserScreen extends StatefulWidget {
  final NextcloudConfig config;
  final String? title;
  final PreferredSizeWidget? customAppBar;

  const NextcloudBrowserScreen({
    super.key,
    required this.config,
    this.title,
    this.customAppBar,
  });

  @override
  State<NextcloudBrowserScreen> createState() => _NextcloudBrowserScreenState();
}

class _NextcloudBrowserScreenState extends State<NextcloudBrowserScreen> {
  late final NextcloudService _service;
  List<NextcloudItem> _items = [];
  bool _isLoading = false;
  String _currentPath = '/';
  final List<String> _pathHistory = ['/'];
  String? _error;
  final Map<String, double> _downloadProgress = {};
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadingFileName = '';

  @override
  void initState() {
    super.initState();
    _service = NextcloudService(widget.config);
    _loadDirectory(_currentPath);
  }

  Future<void> _loadDirectory(String path) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.listDirectory(path);

      setState(() {
        _items = items;
        _currentPath = path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading directory: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(NextcloudItem item) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final downloadsDir = Directory('${directory.path}/NextcloudDownloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath = '${downloadsDir.path}/${item.name}';

      setState(() {
        _downloadProgress[item.href] = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Downloading ${item.name}...')));
      }

      await _service.downloadFile(item, filePath);

      setState(() {
        _downloadProgress[item.href] = 1.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to: $filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _downloadProgress.remove(item.href);
          });
        }
      });
    } catch (e) {
      setState(() {
        _downloadProgress.remove(item.href);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    }
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
          _uploadingFileName = fileName;
        });

        // Upload to current directory
        final remotePath = '$_currentPath$fileName';
        await _service.uploadFile(
          file.path,
          remotePath,
          onProgress: (sent, total) {
            setState(() {
              _uploadProgress = sent / total;
            });
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Upload successful!')));
        }

        // Refresh directory
        await _loadDirectory(_currentPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadingFileName = '';
        });
      }
    }
  }

  void _navigateToItem(NextcloudItem item) {
    if (item.isDirectory) {
      // Extract the relative path from the full href
      // href is like: /public.php/webdav/test1/
      // We need to extract: /test1/
      final relativePath = item.href.replaceFirst('/public.php/webdav', '');

      _pathHistory.add(relativePath);
      _loadDirectory(relativePath);
    } else {
      _showDownloadDialog(item);
    }
  }

  void _showDownloadDialog(NextcloudItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${item.displaySize}'),
            if (item.lastModified != null)
              Text('Modified: ${_formatDate(item.lastModified!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadFile(item);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _canGoBack() {
    return _pathHistory.length > 1;
  }

  void _goBack() {
    if (_canGoBack()) {
      _pathHistory.removeLast();
      final previousPath = _pathHistory.last;
      _loadDirectory(previousPath);
    }
  }

  void _showItemOptions(NextcloudItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(item);
              },
            ),
            if (!item.isDirectory)
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadFile(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            hintText: 'Enter folder name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final folderName = controller.text.trim();
              if (folderName.isNotEmpty) {
                Navigator.pop(context);
                _createFolder(folderName);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createFolder(String folderName) async {
    try {
      final folderPath = '$_currentPath$folderName/';
      await _service.createFolder(folderPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder created successfully')),
        );
      }

      await _loadDirectory(_currentPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create folder: $e')));
      }
    }
  }

  void _showRenameDialog(NextcloudItem item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != item.name) {
                Navigator.pop(context);
                _renameItem(item, newName);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _renameItem(NextcloudItem item, String newName) async {
    try {
      // Extract directory path from current item
      final oldPath = item.href.replaceFirst('/public.php/webdav', '');
      final parentPath = oldPath.substring(0, oldPath.lastIndexOf('/') + 1);
      final newPath = '$parentPath$newName${item.isDirectory ? '/' : ''}';

      await _service.renameItem(oldPath, newPath);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Renamed successfully')));
      }

      await _loadDirectory(_currentPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to rename: $e')));
      }
    }
  }

  void _showDeleteConfirmation(NextcloudItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text(
          'Are you sure you want to delete "${item.name}"?${item.isDirectory ? '\n\nThis will delete the folder and all its contents.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(NextcloudItem item) async {
    try {
      final itemPath = item.href.replaceFirst('/public.php/webdav', '');
      await _service.deleteItem(itemPath);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      }

      await _loadDirectory(_currentPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.customAppBar ??
          AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title ?? 'Nextcloud Browser'),
            leading: _canGoBack()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back), onPressed: _goBack)
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.create_new_folder),
                tooltip: 'Create Folder',
                onPressed: _showCreateFolderDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadDirectory(_currentPath),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Change Account',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ConfigurationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Icon(Icons.folder, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentPath,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.upload, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Uploading: $_uploadingFileName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadDirectory(_currentPath),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _items.isEmpty
                        ? const Center(child: Text('Empty folder'))
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final isDownloading =
                                  _downloadProgress.containsKey(
                                item.href,
                              );
                              final progress =
                                  _downloadProgress[item.href] ?? 0.0;

                              return ListTile(
                                leading: Icon(
                                  item.isDirectory
                                      ? Icons.folder
                                      : Icons.insert_drive_file,
                                  color: item.isDirectory
                                      ? Colors.amber
                                      : Colors.blue,
                                  size: 32,
                                ),
                                title: Text(item.name),
                                subtitle: item.isDirectory
                                    ? const Text('Folder')
                                    : Text(item.displaySize),
                                trailing: isDownloading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          value:
                                              progress == 0 ? null : progress,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : item.isDirectory
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon:
                                                    const Icon(Icons.more_vert),
                                                onPressed: () =>
                                                    _showItemOptions(item),
                                              ),
                                              const Icon(Icons.chevron_right),
                                            ],
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon:
                                                    const Icon(Icons.more_vert),
                                                onPressed: () =>
                                                    _showItemOptions(item),
                                              ),
                                              IconButton(
                                                icon:
                                                    const Icon(Icons.download),
                                                onPressed: () =>
                                                    _downloadFile(item),
                                              ),
                                            ],
                                          ),
                                onTap: () => _navigateToItem(item),
                                onLongPress: () => _showItemOptions(item),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _uploadFile,
        tooltip: 'Upload File',
        child: _isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.upload_file),
      ),
    );
  }
}
