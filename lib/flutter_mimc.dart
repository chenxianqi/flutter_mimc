import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMimc {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mimc');

  static Future<Map<dynamic, dynamic>> get platformVersion async {
     Map<String, dynamic> params = {
       "id": "1231"
     };
    final Map<dynamic, dynamic> version = await _channel.invokeMethod('getPlatformVersion', params);
    print(version);
    return version;
  }
}
