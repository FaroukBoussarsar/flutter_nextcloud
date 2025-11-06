import 'package:flutter/material.dart';
import 'package:flutter_nextcloud/flutter_nextcloud.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Example 1: Basic usage with default settings
    // return const FlutterNextcloud();

    // Example 2: Custom theme colors
    // return const FlutterNextcloud(
    //   primaryColor: Colors.green,
    //   secondaryColor: Colors.teal,
    //   title: 'My Cloud Files',
    // );

    // Example 3: Custom AppBars
    return FlutterNextcloud(
      primaryColor: Colors.deepPurple,
      configurationAppBar: AppBar(
        title: const Text('Connect to Cloud'),
        backgroundColor: Colors.deepPurple,
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
      ),
    );

    // Example 4: Pre-filled configuration (user still sees config screen)
    // return const FlutterNextcloud(
    //   primaryColor: Colors.purple,
    //   title: 'Company Nextcloud',
    //   serverUrl: 'https://cloud.example.com',
    //   shareToken: 'your-share-token',
    //   // password: 'optional-password',
    // );

    // Example 5: Auto-connect (skip config screen)
    // return const FlutterNextcloud(
    //   primaryColor: Colors.orange,
    //   title: 'Auto Connect Example',
    //   serverUrl: 'https://cloud.example.com',
    //   shareToken: 'your-share-token',
    //   password: 'your-password',
    //   autoConnect: true,
    //   isPublicShare: true,
    // );
  }
}
