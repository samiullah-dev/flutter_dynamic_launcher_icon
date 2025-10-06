import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_dynamic_launcher_icon_platform_interface.dart';

/// An implementation of [FlutterDynamicLauncherIconPlatform] that uses method channels.
class MethodChannelFlutterDynamicLauncherIcon
    extends FlutterDynamicLauncherIconPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_dynamic_launcher_icon');

  @override
  Future<void> changeIcon(String? iconName, {bool silent = false}) async {
    await methodChannel.invokeMethod('changeIcon', {
      'iconName': iconName,
      'silent': silent,
    });
  }

  @override
  Future<String?> get alternateIconName async {
    final String? iconName = await methodChannel.invokeMethod<String>(
      'getCurrentIcon',
    );
    return iconName;
  }

  @override
  Future<bool> get isSupported async {
    final bool? supported = await methodChannel.invokeMethod<bool>(
      'isSupported',
    );
    return supported ?? false;
  }
}
