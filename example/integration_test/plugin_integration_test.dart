import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dynamic_launcher_icon/flutter_dynamic_launcher_icon.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_dynamic_launcher_icon');

  final List<MethodCall> log = [];

  setUp(() {
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);

          switch (methodCall.method) {
            case 'changeIcon':
              final args = methodCall.arguments as Map;
              final iconName = args['iconName'] as String?;

              if (iconName == null || iconName != 'Invalid') {
                return null;
              } else {
                throw PlatformException(
                  code: 'INVALID_ICON',
                  message: 'Icon not found',
                );
              }

            case 'getCurrentIcon':
              return 'AppIconDart';

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

  testWidgets('returns true when platform supports dynamic icons', (
    tester,
  ) async {
    final supported = await FlutterDynamicLauncherIcon.isSupported;
    expect(supported, isTrue);

    expect(log, hasLength(1));
    expect(log.first.method, equals('isSupported'));
  });

  testWidgets('returns alternate icon name from platform', (tester) async {
    final iconName = await FlutterDynamicLauncherIcon.alternateIconName;

    expect(iconName, equals('AppIconDart'));
    expect(log, hasLength(1));
    expect(log.first.method, equals('getCurrentIcon'));
  });

  testWidgets('calls changeIcon with correct arguments', (tester) async {
    await FlutterDynamicLauncherIcon.changeIcon('AppIconSwift', silent: true);

    expect(log, hasLength(1));
    final call = log.first;
    expect(call.method, equals('changeIcon'));
    expect(call.arguments, {'iconName': 'AppIconSwift', 'silent': true});
  });

  testWidgets('throws PlatformException for invalid icon name', (tester) async {
    expect(
      () => FlutterDynamicLauncherIcon.changeIcon('Invalid'),
      throwsA(isA<PlatformException>()),
    );
  });

  testWidgets('resets icon when null is passed', (tester) async {
    await FlutterDynamicLauncherIcon.changeIcon(null);

    final call = log.first;
    expect(call.method, equals('changeIcon'));
    expect(call.arguments, {'iconName': null, 'silent': false});
  });
}
