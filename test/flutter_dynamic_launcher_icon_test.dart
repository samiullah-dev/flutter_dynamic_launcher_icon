import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dynamic_launcher_icon/flutter_dynamic_launcher_icon.dart';
import 'package:flutter_dynamic_launcher_icon/src/flutter_dynamic_launcher_icon_platform_interface.dart';
import 'package:flutter_dynamic_launcher_icon/src/flutter_dynamic_launcher_icon_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterDynamicLauncherIconPlatform
    with MockPlatformInterfaceMixin
    implements FlutterDynamicLauncherIconPlatform {
  String? _currentIcon;
  bool _isSupported = true;

  @override
  Future<void> changeIcon(String? iconName, {bool silent = false}) async {
    _currentIcon = iconName;
  }

  @override
  Future<String?> get alternateIconName async => _currentIcon;

  @override
  Future<bool> get isSupported async => _isSupported;

  // Helper methods for testing
  void setSupported(bool supported) {
    _isSupported = supported;
  }
}

void main() {
  final FlutterDynamicLauncherIconPlatform initialPlatform =
      FlutterDynamicLauncherIconPlatform.instance;

  test('$MethodChannelFlutterDynamicLauncherIcon is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterDynamicLauncherIcon>(),
    );
  });

  group('FlutterDynamicLauncherIcon', () {
    late MockFlutterDynamicLauncherIconPlatform fakePlatform;

    setUp(() {
      fakePlatform = MockFlutterDynamicLauncherIconPlatform();
      FlutterDynamicLauncherIconPlatform.instance = fakePlatform;
    });

    test('changeIcon changes to alternate icon', () async {
      await FlutterDynamicLauncherIcon.changeIcon('icon_1');
      expect(await FlutterDynamicLauncherIcon.alternateIconName, 'icon_1');
    });

    test('changeIcon with null resets to default', () async {
      await FlutterDynamicLauncherIcon.changeIcon('icon_1');
      expect(await FlutterDynamicLauncherIcon.alternateIconName, 'icon_1');

      await FlutterDynamicLauncherIcon.changeIcon(null);
      expect(await FlutterDynamicLauncherIcon.alternateIconName, null);
    });

    test('changeIcon with silent parameter', () async {
      // This just verifies the method can be called with silent parameter
      await FlutterDynamicLauncherIcon.changeIcon('icon_1', silent: true);
      expect(await FlutterDynamicLauncherIcon.alternateIconName, 'icon_1');
    });

    test('alternateIconName returns null initially', () async {
      expect(await FlutterDynamicLauncherIcon.alternateIconName, null);
    });

    test('alternateIconName returns current icon after change', () async {
      await FlutterDynamicLauncherIcon.changeIcon('icon_2');
      expect(await FlutterDynamicLauncherIcon.alternateIconName, 'icon_2');
    });

    test('isSupported returns true on supported platform', () async {
      fakePlatform.setSupported(true);
      expect(await FlutterDynamicLauncherIcon.isSupported, true);
    });

    test('isSupported returns false on unsupported platform', () async {
      fakePlatform.setSupported(false);
      expect(await FlutterDynamicLauncherIcon.isSupported, false);
    });

    test('multiple icon changes work correctly', () async {
      await FlutterDynamicLauncherIcon.changeIcon('icon_1');
      expect(await FlutterDynamicLauncherIcon.alternateIconName, 'icon_1');

      await FlutterDynamicLauncherIcon.changeIcon('icon_2');
      expect(await FlutterDynamicLauncherIcon.alternateIconName, 'icon_2');

      await FlutterDynamicLauncherIcon.changeIcon(null);
      expect(await FlutterDynamicLauncherIcon.alternateIconName, null);
    });
  });
}
