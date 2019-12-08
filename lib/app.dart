import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:package_info/package_info.dart';

const bool isEnableDataMock = false;
bool get isInDebugMode {
  // Assume you're in production mode
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

/// Các dịch vụ và cấu hình tĩnh
class App {
  static bool get isTablet => width > 900;
  static double width = 720;
  static double height = 0;

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static String appVersion;

  static Future<void> getAppVersion() async {
    try {
      if (appVersion != null) return appVersion;

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      return appVersion;
    } catch (e, s) {}
  }
}
