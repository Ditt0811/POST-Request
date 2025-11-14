import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  static Future<String> getDeviceName() async {
    final d = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        final w = await d.webBrowserInfo;
        final vendor = (w.vendor ?? '').trim();
        final ua = (w.userAgent ?? 'Web Browser').trim();
        return [vendor, ua].where((s) => s.isNotEmpty).join(' ');
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final a = await d.androidInfo;
          return '${a.manufacturer} ${a.model}'.trim();
        case TargetPlatform.iOS:
          final i = await d.iosInfo;
          return '${i.name} ${i.model}'.trim();
        default:
          return describeEnum(defaultTargetPlatform);
      }
    } catch (e, st) {
      debugPrint('DeviceHelper error: $e\n$st');
      return 'Unknown Device';
    }
  }
}
