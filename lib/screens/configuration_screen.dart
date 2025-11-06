import 'package:flutter/material.dart';
import '../models/nextcloud_config.dart';
import 'nextcloud_browser_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController(
    text: 'https://cloud.example.com',
  );
  final _usernameController = TextEditingController(text: '');
  final _passwordController = TextEditingController();
  bool _isPublicShare = true;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _connect() {
    if (_formKey.currentState!.validate()) {
      final config = _isPublicShare
          ? NextcloudConfig.publicShare(
              serverUrl: _serverUrlController.text.trim(),
              shareToken: _usernameController.text.trim(),
              password: _passwordController.text,
            )
          : NextcloudConfig.authenticated(
              serverUrl: _serverUrlController.text.trim(),
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NextcloudBrowserScreen(config: config),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Nextcloud'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.cloud, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Nextcloud Connection',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Connection Type Selector
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Public Share'),
                    icon: Icon(Icons.link),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('User Account'),
                    icon: Icon(Icons.person),
                  ),
                ],
                selected: {_isPublicShare},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isPublicShare = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Server URL
              TextFormField(
                controller: _serverUrlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'https://cloud.example.com',
                  prefixIcon: Icon(Icons.dns),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter server URL';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Username / Share Token
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: _isPublicShare ? 'Share Token' : 'Username',
                  hintText: _isPublicShare
                      ? 'e.g., abcdefghijklmno'
                      : 'Your username',
                  prefixIcon: Icon(
                    _isPublicShare ? Icons.vpn_key : Icons.person,
                  ),
                  border: const OutlineInputBorder(),
                  helperText: _isPublicShare
                      ? 'From share link: /s/[TOKEN]'
                      : 'Your Nextcloud username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _isPublicShare
                        ? 'Please enter share token'
                        : 'Please enter username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: _isPublicShare
                      ? 'Leave empty if no password'
                      : 'Your password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (!_isPublicShare && (value == null || value.isEmpty)) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Connect Button
              ElevatedButton(
                onPressed: _connect,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login),
                    SizedBox(width: 8),
                    Text('Connect', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Help Text
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'How to find share token:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Open your Nextcloud share link\n'
                        '2. Look for: /index.php/s/[TOKEN]\n'
                        '3. Copy the TOKEN part\n\n'
                        'Example:\n'
                        'https://cloud.example.com/s/abc123\n'
                        'Token: abc123',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
