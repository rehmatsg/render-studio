// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'rehmat.dart';

late App app;

class App {

  App._({
    required this.flavor,
  });

  final Flavor flavor;

  late AuthState auth;

  late PackageInfo info;

  late RemoteConfig remoteConfig;

  bool get useFirebaseEmulator => flavor == Flavor.dev;

  static Future<App> build(Flavor flavor) async {
    App app = App._(flavor: flavor);
    app.auth = AuthState.instance;
    try {
      await app.initialize();
    } catch (e) { }
    return app;
  }

  Future<void> initialize() async {
    DateTime start = DateTime.now();

    // MobileAds.instance.initialize();

    // Add Rehmat's iPhone for testing
    // RequestConfiguration configuration = RequestConfiguration(testDeviceIds: ['****************************']);
    // MobileAds.instance.updateRequestConfiguration(configuration);

    await Hive.initFlutter();

    // Execute async operations in parallel
    var futures = [
      PackageInfo.fromPlatform(),
      RemoteConfig.initialize(flavor: flavor),
      Environment.instance,
      DeviceInfo.instance,
      Preferences.instance,
      Analytics.instance,
      ProjectManager.instance,
      PaletteManager.instance,
      ProjectSaves.instance,
      PathProvider.instance,
      Crashlytics.init()
    ];

    List results = await Future.wait(futures);

    // Assigning results to respective variables
    info = results[0];
    remoteConfig = results[1];
    environment = results[2];
    device = results[3];
    preferences = results[4];
    analytics = results[5];
    manager = results[6];
    paletteManager = results[7];
    projectSaves = results[8];
    pathProvider = results[9];

    print('Initialization took ${DateTime.now().difference(start).inMilliseconds} milliseconds');
  }

  /// Executes a list of async functions parallely and returns a list of their results
  static Future<List<T>> executeAsyncFunctions<T>(List<Future<T> Function()> asyncFunctions) async {
    var futures = asyncFunctions.map((asyncFunc) => asyncFunc()).toList();

    return await Future.wait(futures);
  }

}

enum Flavor {
  dev,
  beta,
  production
}