import 'package:flutter/material.dart';
import 'package:flutter_dynamic_launcher_icon/flutter_dynamic_launcher_icon.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const DynamicIconDemoApp(),
    ),
  );
}

class DynamicIconDemoApp extends StatefulWidget {
  const DynamicIconDemoApp({super.key});

  @override
  State<DynamicIconDemoApp> createState() => _DynamicIconDemoAppState();
}

class _DynamicIconDemoAppState extends State<DynamicIconDemoApp> {
  String? _currentIcon;
  bool _isSupported = false;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    final supported = await FlutterDynamicLauncherIcon.isSupported;
    final current = await FlutterDynamicLauncherIcon.alternateIconName;

    setState(() {
      _isSupported = supported;
      _currentIcon = current;
    });
  }

  Future<void> _changeIcon(String? iconName, {bool silent = false}) async {
    try {
      await FlutterDynamicLauncherIcon.changeIcon(iconName, silent: silent);
      final updatedIcon = await FlutterDynamicLauncherIcon.alternateIconName;
      setState(() => _currentIcon = updatedIcon);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {}
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Launcher Icon Demo')),
      body: !_isSupported
          ? const Center(
              child: Text(
                'Dynamic icons are not supported on this device.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Current icon: ${_currentIcon ?? "Default"}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.code),
                    label: const Text('Switch to Dart Icon'),
                    onPressed: () => _changeIcon(AppAlternateIcon.dart.name),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.phone_iphone),
                    label: const Text('Switch to Swift Icon (Silent)'),
                    onPressed: () => _changeIcon(
                      AppAlternateIcon.swift.name,
                      // Warning: Using silent may violate App Store guidelines.
                      // When true, iOS will not show the alert when changing icons.
                      silent: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset to Default'),
                    onPressed: () => _changeIcon(null),
                  ),
                  const Spacer(),
                  const Divider(),
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('''
• iOS shows a system alert when changing icons.
• Use the “silent” parameter cautiously.
• Android changes take effect when the app is sent to background.'''),
                ],
              ),
            ),
    );
  }
}

enum AppAlternateIcon {
  dart,
  swift;

  String get name {
    return switch (this) {
      AppAlternateIcon.dart => 'AppIconDart',
      AppAlternateIcon.swift => 'AppIconSwift',
    };
  }
}
