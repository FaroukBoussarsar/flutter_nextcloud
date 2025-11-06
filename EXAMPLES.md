# FlutterNextcloud Widget Examples

This document provides various examples of how to use the `FlutterNextcloud` widget with different configurations.

## Basic Usage

The simplest way to use the package:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nextcloud/flutter_nextcloud.dart';

void main() {
  runApp(const FlutterNextcloud());
}
```

## Custom Theme Colors

Customize the primary and secondary colors:

```dart
void main() {
  runApp(
    const FlutterNextcloud(
      primaryColor: Colors.green,
      secondaryColor: Colors.teal,
      title: 'My Cloud Files',
    ),
  );
}
```

## Custom AppBars

Inject custom AppBar widgets for both configuration and browser screens:

```dart
void main() {
  runApp(
    FlutterNextcloud(
      primaryColor: Colors.deepPurple,
      configurationAppBar: AppBar(
        title: const Text('Connect to My Cloud'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      browserAppBar: AppBar(
        title: const Text('My Files'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        leading: const Icon(Icons.cloud),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
        ],
      ),
    ),
  );
}
```

## Pre-filled Configuration

Pre-fill the configuration screen with server details (user can still modify):

```dart
void main() {
  runApp(
    const FlutterNextcloud(
      primaryColor: Colors.purple,
      title: 'Company Nextcloud',
      serverUrl: 'https://cloud.example.com',
      shareToken: 'your-share-token',
      password: 'optional-password', // Optional
    ),
  );
}
```

## Auto-Connect (Public Share)

Skip the configuration screen and connect directly to a public share:

```dart
void main() {
  runApp(
    const FlutterNextcloud(
      primaryColor: Colors.orange,
      title: 'Project Files',
      serverUrl: 'https://cloud.example.com',
      shareToken: 'abc123xyz',
      password: 'share-password', // If the share is password-protected
      autoConnect: true,
      isPublicShare: true,
    ),
  );
}
```

## Auto-Connect (Authenticated User)

Connect directly with user credentials:

```dart
void main() {
  runApp(
    const FlutterNextcloud(
      primaryColor: Colors.deepPurple,
      title: 'My Personal Cloud',
      serverUrl: 'https://cloud.example.com',
      shareToken: 'john.doe', // Username in authenticated mode
      password: 'user-password',
      autoConnect: true,
      isPublicShare: false, // Use authenticated mode
    ),
  );
}
```

## Advanced: Embedding in Your App

If you want to embed the Nextcloud browser in your existing app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nextcloud/flutter_nextcloud.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FlutterNextcloud(
                  primaryColor: Colors.blue,
                  title: 'Cloud Storage',
                ),
              ),
            );
          },
          child: const Text('Open Cloud Storage'),
        ),
      ),
    );
  }
}
```

## Widget Parameters

| Parameter             | Type                   | Default                               | Description                                                |
| --------------------- | ---------------------- | ------------------------------------- | ---------------------------------------------------------- |
| `primaryColor`        | `Color?`               | `Colors.blue`                         | Primary color for the app theme                            |
| `secondaryColor`      | `Color?`               | `primaryColor.withValues(alpha: 0.8)` | Secondary color for the app theme                          |
| `title`               | `String?`              | `'Nextcloud Browser'`                 | App title displayed in default app bars                    |
| `configurationAppBar` | `PreferredSizeWidget?` | `null`                                | Custom AppBar for configuration screen (overrides title)   |
| `browserAppBar`       | `PreferredSizeWidget?` | `null`                                | Custom AppBar for browser screen (overrides title)         |
| `serverUrl`           | `String?`              | `null`                                | Pre-filled Nextcloud server URL                            |
| `shareToken`          | `String?`              | `null`                                | Pre-filled share token or username                         |
| `password`            | `String?`              | `null`                                | Pre-filled password                                        |
| `autoConnect`         | `bool`                 | `false`                               | Skip config screen and connect directly                    |
| `isPublicShare`       | `bool`                 | `true`                                | Use public share mode (true) or authenticated mode (false) |

## Notes

- When `autoConnect` is `true`, both `serverUrl` and `shareToken` must be provided
- The `shareToken` parameter serves dual purpose:
  - For public shares: it's the share token from the URL
  - For authenticated users: it's the username
- The `password` parameter is optional for public shares but required for authenticated users
- Custom AppBars (`configurationAppBar` and `browserAppBar`) will completely replace the default AppBars
- If custom AppBars are provided, the `title` parameter is ignored for that screen
- Theme colors automatically propagate throughout the entire UI
