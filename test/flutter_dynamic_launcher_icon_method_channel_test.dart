import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dynamic_launcher_icon/flutter_dynamic_launcher_icon_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterDynamicLauncherIcon platform =
      MethodChannelFlutterDynamicLauncherIcon();
  const MethodChannel channel = MethodChannel('flutter_dynamic_launcher_icon');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'changeIcon':
              return null;
            case 'getCurrentIcon':
              return 'icon_1';
            case 'getSupportedIcons':
              return ['MainActivity', 'icon_1', 'icon_2'];
            case 'isSupported':
              return true;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('MethodChannelFlutterDynamicLauncherIcon', () {
    test('changeIcon calls platform with correct parameters', () async {
      bool methodCalled = false;
      String? capturedIconName;
      bool? capturedSilent;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'changeIcon') {
              methodCalled = true;
              capturedIconName = methodCall.arguments['iconName'];
              capturedSilent = methodCall.arguments['silent'];
            }
            return null;
          });

      await platform.changeIcon('icon_1', silent: true);

      expect(methodCalled, true);
      expect(capturedIconName, 'icon_1');
      expect(capturedSilent, true);
    });

    test('changeIcon with null iconName', () async {
      bool methodCalled = false;
      String? capturedIconName;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'changeIcon') {
              methodCalled = true;
              capturedIconName = methodCall.arguments['iconName'];
            }
            return null;
          });

      await platform.changeIcon(null);

      expect(methodCalled, true);
      expect(capturedIconName, null);
    });

    test('alternateIconName returns current icon', () async {
      expect(await platform.alternateIconName, 'icon_1');
    });

    test('alternateIconName returns null when using default', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getCurrentIcon':
                return null; // Kotlin returns null for default
              case 'isSupported':
                return true;
              case 'getSupportedIcons':
                return ['MainActivity', 'icon_1', 'icon_2'];
              default:
                return null;
            }
          });

      final result = await platform.alternateIconName;
      expect(result, null);
    });

    test('isSupported returns true', () async {
      expect(await platform.isSupported, true);
    });

    test('isSupported returns false on unsupported platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'isSupported') {
              return false;
            }
            return null;
          });

      expect(await platform.isSupported, false);
    });
  });
}
