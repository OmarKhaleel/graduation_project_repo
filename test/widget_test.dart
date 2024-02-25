import 'package:flutter_test/flutter_test.dart';
import 'package:palmear_application/main.dart';
import 'package:flutter/services.dart';

void main() {
  group('MyApp Widget Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('audio_devices'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAudioDevices') {
            return [
              {
                "name": "Device 1",
                "sampleRate": 44100,
                "channels": "stereo",
                "callbackFunction": "Yes"
              },
              {
                "name": "Device 2",
                "sampleRate": 48000,
                "channels": "mono",
                "callbackFunction": "No"
              },
            ];
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('audio_devices'),
        null,
      );
    });

    testWidgets('Audio devices are displayed correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Device 1'), findsOneWidget);
      expect(find.text('Sample Rate: 44100 Hz'), findsOneWidget);
      expect(find.text('Channels: stereo'), findsOneWidget);
      expect(find.text('Callback Function: Yes'), findsOneWidget);

      expect(find.text('Device 2'), findsOneWidget);
      expect(find.text('Sample Rate: 48000 Hz'), findsOneWidget);
      expect(find.text('Channels: mono'), findsOneWidget);
      expect(find.text('Callback Function: No'), findsOneWidget);
    });
  });
}
