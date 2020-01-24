import 'dart:async';
import 'dart:io';

import 'config.dart';
import 'globals.dart';

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

    final deviceType = (await config.screenshotsEnv)["device_type"];
    final isAndroid = deviceType == "android";

    final testDir = '${config.stagingDir}/$kTestScreenshotsDir';
    final file = await File('$testDir/$name.$kImageExtension').create(recursive: true);

    if (isAndroid) {
      print("Creating screenshot using ADB");
      await Process.run('adb', ['shell', 'settings', 'put', 'global', 'window_animation_scale', '0.0']);
      await Process.run('adb', ['shell', 'settings', 'put', 'global', 'transition_animation_scale', '0.0']);
      await Process.run('adb', ['shell', 'settings', 'put', 'global', 'animator_duration_scale', '0.0']);
      await Process.run('adb', ['shell', 'settings', 'put', 'global', 'sysui_demo_allowed', '1']);
      await Process.run('adb', ['shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '-e', 'command', 'enter']);
      await Process.run('adb', ['shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '-e', 'command', 'clock', '-e', 'hhmm', '0800']);
      await Process.run('adb', ['shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '-e', 'command', 'battery', '-e', 'level', '100']);
      await Process.run('adb', ['shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '-e', 'command', 'network', '-e', 'wifi', 'show', '-e', 'level', '4']);
      await Process.run('adb', ['shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '-e', 'command', 'network', '-e', 'mobile', 'show', '-e', 'datatype', 'lte', '-e', 'level', '4']);
      await Process.run('adb', ['shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '-e', 'command', 'notifications', '-e', 'visible', 'false']);

      final screenshotResult = await Process.run('adb', ['exec-out', 'screencap', '-p'], stdoutEncoding: null);
      await file.writeAsBytes(screenshotResult.stdout);

      await Process.run('adb', ['shell', 'am', 'broadcast', '-a', 'com.android.systemui.demo', '-e', 'command', 'exit']);
      await Process.run('adb', ['shell', 'settings', 'put', 'global', 'window_animation_scale', '1.0']);
      await Process.run('adb', ['shell', 'settings', 'put', 'global', 'transition_animation_scale', '1.0']);
      await Process.run('adb', ['shell', 'settings', 'put', 'global', 'animator_duration_scale', '1.0']);
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
