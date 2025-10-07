import 'src/flutter_dynamic_launcher_icon_platform_interface.dart';

/// A Flutter plugin for dynamically changing the app launcher icon at runtime.
///
/// Supports Android (API 21+) and iOS (10.3+).
abstract class FlutterDynamicLauncherIcon {
  /// Changes the app launcher icon.
  ///
  /// Pass [iconName] matching your activity-alias (Android) or alternate icon (iOS).
  /// Pass `null` to reset to the default icon.
  ///
  /// **Android:** Icon changes when app goes to background (no restart).
  ///
  /// **iOS:** Icon changes immediately with a system alert.
  /// The [silent] parameter can suppress this alert, but **this is not recommended**
  /// and may violate Apple's App Store Review Guidelines as it bypasses user
  /// awareness of icon changes.
  ///
  /// Example:
  /// ```dart
  /// await FlutterDynamicLauncherIcon.changeIcon('icon_1');
  /// await FlutterDynamicLauncherIcon.changeIcon(null); // Reset to default
  /// ```
  static Future<void> changeIcon(String? iconName, {bool silent = false}) {
    return FlutterDynamicLauncherIconPlatform.instance.changeIcon(
      iconName,
      silent: silent,
    );
  }

  /// Gets the currently active icon name.
  ///
  /// Returns `null` if using the default icon.
  static Future<String?> get alternateIconName {
    return FlutterDynamicLauncherIconPlatform.instance.alternateIconName;
  }

  /// Checks if dynamic icons are supported on this platform.
  ///
  /// Returns `true` on Android API 21+ and iOS 10.3+, `false` otherwise.
  static Future<bool> get isSupported {
    return FlutterDynamicLauncherIconPlatform.instance.isSupported;
  }
}
