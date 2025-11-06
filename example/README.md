# Nextcloud Browser Example

This example demonstrates how to use the `flutter_nextcloud` package to browse and manage files on a Nextcloud server.

## Features Demonstrated

- Connecting to Nextcloud server (public share and authenticated)
- Browsing directories
- Downloading files
- Uploading files
- Creating folders
- Deleting items
- Renaming items

## Running the Example

1. Navigate to the example directory:

   ```bash
   cd example
   ```

2. Get dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Launch the app
2. Enter your Nextcloud server details:
   - Server URL (e.g., https://cloud.example.com)
   - Share token (for public shares) or username (for authenticated access)
   - Password (optional for public shares, required for authenticated)
3. Tap "Connect" to start browsing

## Customization

You can modify `lib/main.dart` to customize the app theme or behavior.
