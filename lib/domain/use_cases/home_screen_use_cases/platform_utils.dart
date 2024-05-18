import 'package:platform/platform.dart';

class PlatformUtils {
  static const LocalPlatform _platform = LocalPlatform();

  static bool get isAndroid => _platform.isAndroid;
  static bool get isIOS => _platform.isIOS;
}
