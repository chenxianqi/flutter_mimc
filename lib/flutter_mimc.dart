import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMimc {

  static const MethodChannel _channel = const MethodChannel('flutter_mimc');

  // 以下两种实例化方法使用一种即可，要么写死参数，要么服务端签名返回原样数据
  static const String INIT1 = 'init';          // 初始化1
  static const String INIT2 = 'initWithToken'; // 初始化2
  static const String LOGIN = 'login';         // 登录
  static const String LOGOUT = 'logout';       // 退出登录
  static const String IS_ONLINE = 'is_online'; // 登录状态


  // 以下两种实例化方法使用一种即可，要么写死，要么服务的请求原样传输进去

  //  * 初始化
  //  * String appId        应用ID，小米开放平台申请分配的appId
  //  * String appKey       应用appKey，小米开放平台申请分配的appKey
  //  * String appSecret    应用appKey，小米开放平台申请分配的appSecret
  //  * String appAccount   会话账号（或业务平台唯一ID）
  static Future<bool> init(Map<String, dynamic> options) async {
     return await _channel.invokeMethod(INIT1, options);
  }

  // 通过服务端生成原样返回的数据token，实例化
  static void initWithToken(String tokenString) async {
    _channel.invokeMethod(INIT2, tokenString);
  }

  // 登录
  // @return bool
  static Future<void> login() async {
    return await _channel.invokeMethod(LOGIN);
  }

  // 退出登录
  // @return null 无返回值
  static  Future<void> logout() async {
    return await _channel.invokeMethod(LOGOUT);
  }

  // 登录状态
  // @return bool
  static Future<bool> isOnline() async {
    return await _channel.invokeMethod(IS_ONLINE);
  }


}

