import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_dynamic_launcher_icon_method_channel.dart';

abstract class FlutterDynamicLauncherIconPlatform extends PlatformInterface {
  /// Constructs a FlutterDynamicLauncherIconPlatform.
  FlutterDynamicLauncherIconPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDynamicLauncherIconPlatform _instance =
      MethodChannelFlutterDynamicLauncherIcon();

  /// The default instance of [FlutterDynamicLauncherIconPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterDynamicLauncherIcon].
  static FlutterDynamicLauncherIconPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterDynamicLauncherIconPlatform] when
  /// they register themselves.
  static set instance(FlutterDynamicLauncherIconPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> changeIcon(String? iconName, {required bool silent}) {
    throw UnimplementedError('setIcon() has not been implemented.');
  }

  Future<String?> get alternateIconName {
    throw UnimplementedError('getCurrentIcon() has not been implemented.');
  }

  Future<bool> get isSupported {
    throw UnimplementedError('isSupported() has not been implemented.');
  }
}
