import 'package:universal_io/io.dart';

/// A helper class for Google AdMob
class AdHelper {
  
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-****************/**********';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-****************/**********';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-****************/**********';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-****************/**********';
    }
    throw UnsupportedError("Unsupported platform");
  }
}