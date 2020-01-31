import 'dart:async';
import 'dart:io';

import 'config.dart';
import 'globals.dart';
import 'image_magick.dart';
import 'context_runner.dart';

/// Called by integration test to capture images.
Future screenshot(final driver, Config config, String name,
    {Duration timeout = const Duration(seconds: 30),
    bool silent = false,
    bool waitUntilNoTransientCallbacks = true}) async {
  if (config.isScreenShotsAvailable) {
    // todo: auto-naming scheme
    if (waitUntilNoTransientCallbacks) {
      await driver.waitUntilNoTransientCallbacks(timeout: timeout);
    }

    final env = await config.screenshotsEnv;
    final deviceId = env["device_id"];
    final deviceType = env["device_type"];
    final orientation = env["orientation"];
    final locale = env["locale"];
    final isAndroid = deviceType == "android";
    final isIOS = deviceType == "ios";

    final testDir = '${config.stagingDir}/$kTestScreenshotsDir';
    final file = await File('$testDir/$name.$kImageExtension').create(recursive: true);

    if (isAndroid) {
      print("Creating Android screenshots on $deviceId with orientation $orientation for locale $locale using ADB");
      final screenshotResult = await Process.run('adb', ['-s', deviceId, 'exec-out', 'screencap', '-p'], stdoutEncoding: null);
      await file.writeAsBytes(screenshotResult.stdout);
    } else if (isIOS) {
      print("Creating iOS screenshots on $deviceId with orientation $orientation for locale $locale using xcrun simctl");
      await Process.run('xcrun', ['simctl', 'io', deviceId, 'screenshot', file.absolute.path]);
      await runInContext<bool>(() async {
        if (orientation == "LandscapeRight") {
          im.rotate(file.absolute.path, 90);
        } else if (orientation == "PortraitUpsideDown") {
          im.rotate(file.absolute.path, 180);
        } else if (orientation == "LandscapeLeft") {
          im.rotate(file.absolute.path, 270);
        }
      });
    } else {
      print("Creating screenshot using FLUTTER DRIVER");
      final pixels = await driver.screenshot();
      await file.writeAsBytes(pixels);
    }
    
    if (!silent) print('Screenshot $name created');
  } else {
    if (!silent) print('Warning: screenshot $name not created');
  }
}
