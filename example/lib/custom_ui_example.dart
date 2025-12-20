import 'package:flutter/material.dart';
import 'package:flutter_nextcloud/flutter_nextcloud.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(home: CustomUIExample()));
}

class CustomUIExample extends StatefulWidget {
  const CustomUIExample({super.key});

  @override
  State<CustomUIExample> createState() => _CustomUIExampleState();
}

class _CustomUIExampleState extends State<CustomUIExample> {
  NextcloudService? _service;
  List<NextcloudItem> _items = [];
  bool _isLoading = false;
  String _currentPath = '/';
  double? _uploadProgress;

  final _serverController =
      TextEditingController(text: 'https://cloud.example.com');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPublicShare = true;

  Future<void> _connect() async {
    setState(() => _isLoading = true);
    try {
      final config = _isPublicShare
          ? NextcloudConfig.publicShare(
              serverUrl: _serverController.text,
              shareToken: _usernameController.text,
              password: _passwordController.text,
            )
          : NextcloudConfig.authenticated(
              serverUrl: _serverController.text,
              username: _usernameController.text,
              password: _passwordController.text,
            );

      final service = NextcloudService(config);
      await service.connect();

      setState(() {
        _service = service;
      });
      await _refreshItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshItems() async {
    if (_service == null) return;
    setState(() => _isLoading = true);
    try {
      final items = await _service!.listDirectory(_currentPath);
      setState(() {
        _items = items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error listing items: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    if (_service == null) return;

    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      try {
        setState(() => _uploadProgress = 0);

        await _service!.uploadFile(
          filePath,
          '$_currentPath$fileName',
          onProgress: (sent, total) {
            setState(() {
              _uploadProgress = sent / total;
            });
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload complete')),
          );
        }
        _refreshItems();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        setState(() => _uploadProgress = null);
      }
    }
  }

  Future<void> _deleteItem(NextcloudItem item) async {
    if (_service == null) return;
    try {
      await _service!.deleteItem(item.href);
      _refreshItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _downloadItem(NextcloudItem item) async {
    if (_service == null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${item.name}';
      await _service!.downloadFile(item, savePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded to $savePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Custom Nextcloud UI')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _serverController,
                decoration: const InputDecoration(labelText: 'Server URL'),
              ),
              SwitchListTile(
                title: const Text('Public Share Link'),
                value: _isPublicShare,
                onChanged: (value) => setState(() => _isPublicShare = value),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: _isPublicShare ? 'Share Token' : 'Username',
                  hintText: _isPublicShare ? 'e.g. abc123xyz' : 'Your username',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _connect,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Connect'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _uploadFile,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_uploadProgress != null)
            LinearProgressIndicator(value: _uploadProgress),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        leading: Icon(
                          item.isDirectory
                              ? Icons.folder
                              : Icons.insert_drive_file,
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.displaySize),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!item.isDirectory)
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => _downloadItem(item),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (item.isDirectory) {
                            // Navigate to folder (simplified for example)
                            // In a real app, you'd update _currentPath and refresh
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
