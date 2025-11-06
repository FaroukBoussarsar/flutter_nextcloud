import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/nextcloud_item.dart';
import '../models/nextcloud_config.dart';

class NextcloudService {
  final NextcloudConfig config;

  NextcloudService(this.config);

  // Create basic auth header
  Map<String, String> _getHeaders() {
    return {'Authorization': 'Basic ${_getBasicAuth()}'};
  }

  String _getBasicAuth() {
    final credentials = '${config.username}:${config.password}';
    return base64Encode(credentials.codeUnits);
  }

  String get baseUrl => config.baseUrl;

  Future<List<NextcloudItem>> listDirectory(String path) async {
    try {
      final url = Uri.parse('$baseUrl$path');

      final response = http.Request('PROPFIND', url)
        ..headers.addAll(_getHeaders())
        ..headers['Depth'] = '1'
        ..body = '''<?xml version="1.0"?>
<d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns">
  <d:prop>
    <d:getlastmodified />
    <d:getetag />
    <d:getcontenttype />
    <d:resourcetype />
    <d:getcontentlength />
    <oc:size />
    <d:displayname />
  </d:prop>
</d:propfind>''';

      final streamedResponse = await response.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 207) {
        final items = _parseWebDavResponse(responseBody, path);
        return items;
      } else {
        throw Exception(
          'Failed to list directory: ${streamedResponse.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  List<NextcloudItem> _parseWebDavResponse(String xml, String currentPath) {
    final document = XmlDocument.parse(xml);
    final responses = document.findAllElements('d:response');

    final items = <NextcloudItem>[];

    for (final response in responses) {
      try {
        final href = response.findElements('d:href').first.innerText;

        // Normalize paths for comparison (remove trailing slashes)
        final normalizedHref =
            href.endsWith('/') ? href.substring(0, href.length - 1) : href;
        final normalizedCurrentPath = '/public.php/webdav$currentPath';
        final normalizedCurrentPathAlt = normalizedCurrentPath.endsWith('/')
            ? normalizedCurrentPath.substring(
                0,
                normalizedCurrentPath.length - 1,
              )
            : normalizedCurrentPath;

        // Skip the current directory itself
        if (normalizedHref == normalizedCurrentPathAlt) {
          continue;
        }

        final propstat = response.findElements('d:propstat').first;
        final prop = propstat.findElements('d:prop').first;

        final resourceType = prop.findElements('d:resourcetype').first;
        final isDirectory =
            resourceType.findElements('d:collection').isNotEmpty;

        final displayName = prop.findElements('d:displayname').isNotEmpty
            ? prop.findElements('d:displayname').first.innerText
            : href.split('/').where((s) => s.isNotEmpty).last;

        final contentLength = prop.findElements('d:getcontentlength').isNotEmpty
            ? int.tryParse(
                prop.findElements('d:getcontentlength').first.innerText,
              )
            : null;

        final lastModified = prop.findElements('d:getlastmodified').isNotEmpty
            ? DateTime.tryParse(
                prop.findElements('d:getlastmodified').first.innerText,
              )
            : null;

        final item = NextcloudItem(
          name: displayName,
          href: href,
          isDirectory: isDirectory,
          size: contentLength,
          lastModified: lastModified,
        );

        items.add(item);
      } catch (e) {
        // Silently skip items that fail to parse
      }
    }

    return items;
  }

  Future<void> downloadFile(NextcloudItem item, String savePath) async {
    try {
      // The href already contains the full path like /public.php/webdav/file.txt
      // Extract the server URL from baseUrl and combine with href
      final baseUri = Uri.parse(baseUrl);
      final serverUrl =
          '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';
      final url = Uri.parse('$serverUrl${item.href}');

      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadFile(
    String localFilePath,
    String remotePath, {
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final file = File(localFilePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $localFilePath');
      }

      final fileLength = await file.length();
      final url = Uri.parse('$baseUrl$remotePath');

      // Create a multipart request with progress tracking
      final request = http.StreamedRequest('PUT', url);
      request.headers.addAll(_getHeaders());
      request.contentLength = fileLength;

      // Track upload progress
      int bytesSent = 0;
      final fileStream = file.openRead();

      fileStream.listen(
        (chunk) {
          request.sink.add(chunk);
          bytesSent += chunk.length;
          if (onProgress != null) {
            onProgress(bytesSent, fileLength);
          }
        },
        onDone: () {
          request.sink.close();
        },
        onError: (error) {
          request.sink.addError(error);
        },
        cancelOnError: true,
      );

      // Send request with extended timeout for large files
      final response = await request.send().timeout(
        const Duration(minutes: 30),
        onTimeout: () {
          throw Exception('Upload timeout - please check your connection');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 204) {
        // Upload successful
      } else {
        await response.stream.bytesToString(); // Consume response
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createFolder(String folderPath) async {
    try {
      final url = Uri.parse('$baseUrl$folderPath');

      final response = http.Request('MKCOL', url)
        ..headers.addAll(_getHeaders());

      final streamedResponse = await response.send();
      final statusCode = streamedResponse.statusCode;

      if (statusCode == 201) {
        // Folder created successfully
      } else if (statusCode == 405) {
        throw Exception('Folder already exists');
      } else {
        await streamedResponse.stream.bytesToString(); // Consume response
        throw Exception('Failed to create folder: $statusCode');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(String itemPath) async {
    try {
      final url = Uri.parse('$baseUrl$itemPath');

      final response = await http.delete(url, headers: _getHeaders());

      if (response.statusCode == 204) {
      } else {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> renameItem(String oldPath, String newPath) async {
    try {
      final sourceUrl = Uri.parse('$baseUrl$oldPath');
      final destinationUrl = Uri.parse('$baseUrl$newPath');

      final response = http.Request('MOVE', sourceUrl)
        ..headers.addAll(_getHeaders())
        ..headers['Destination'] = destinationUrl.toString();

      final streamedResponse = await response.send();
      final statusCode = streamedResponse.statusCode;

      if (statusCode == 201 || statusCode == 204) {
        // Item renamed successfully
      } else {
        await streamedResponse.stream.bytesToString(); // Consume response
        throw Exception('Failed to rename item: $statusCode');
      }
    } catch (e) {
      rethrow;
    }
  }
}

String base64Encode(List<int> bytes) {
  const String base64Chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  String result = '';
  int i = 0;

  while (i < bytes.length) {
    int byte1 = bytes[i++];
    int byte2 = i < bytes.length ? bytes[i++] : 0;
    int byte3 = i < bytes.length ? bytes[i++] : 0;

    int triple = (byte1 << 16) + (byte2 << 8) + byte3;

    result += base64Chars[(triple >> 18) & 0x3F];
    result += base64Chars[(triple >> 12) & 0x3F];
    result +=
        (i - 1) > bytes.length - 2 ? '=' : base64Chars[(triple >> 6) & 0x3F];
    result += (i) > bytes.length - 1 ? '=' : base64Chars[triple & 0x3F];
  }

  return result;
}
