import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MIMCEvents{
  static const String onlineStatusListener = "onlineStatusListener";              // 状态变更
  static const String onHandleSendMessageTimeout = "onHandleSendMessageTimeout";  // 发送单聊消息超时
  static const String onHandleMessage = "onHandleMessage";                        // 接收单聊
  static const String onHandleGroupMessage = "onHandleGroupMessage";              // 接收群聊
  static const String onHandleServerAck = "onHandleServerAck";                    // 接收服务端已收到发送消息确认
}


class FlutterMimc {

  static const MethodChannel _channel = const MethodChannel('flutter_mimc');


  // 以下两种实例化方法使用一种即可，要么写死参数，要么服务端签名返回原样数据
  static const String   _ON_INIT        =     'init';          // 参数形式初始化
  static const String   _ON_TOKEN_INIT  =     'initWithToken'; // token形式初始化
  static const String   _ON_LOGIN       =     'login';         // 登录
  static const String   _ON_LOGOUT      =     'logout';        // 退出登录
  static const String   _ON_IS_ONLINE   =     'is_online';     // 获取登录状态（可能不准）请以事件回调为准

  // addEventListener
  final StreamController<bool> _onlineStatusListenerStreamController = StreamController<bool>.broadcast();

  // 以下两种实例化方法使用一种即可，要么写死，要么服务的请求原样传输进去

  //  * 初始化
  //  * String appId        应用ID，小米开放平台申请分配的appId
  //  * String appKey       应用appKey，小米开放平台申请分配的appKey
  //  * String appSecret    应用appKey，小米开放平台申请分配的appSecret
  //  * String appAccount   会话账号（或业务平台唯一ID）
  FlutterMimc.init(Map<String, dynamic> options){
    _channel.invokeMethod(_ON_INIT, options);
    _initEvent();
  }

  // 通过服务端生成原样返回的数据token，实例化
  FlutterMimc.initWithToken(String tokenString) {
    _channel.invokeMethod(_ON_TOKEN_INIT, tokenString);
    _initEvent();
  }

  // 登录
  // @return bool
  Future<void> login() async {
    return await _channel.invokeMethod(_ON_LOGIN);
  }

  // 退出登录
  // @return null 无返回值
  static  Future<void> logout() async {
    return await _channel.invokeMethod(_ON_LOGOUT);
  }

  // 登录状态
  // @return bool
  Future<bool> isOnline() async {
    return await _channel.invokeMethod(_ON_IS_ONLINE);
  }

  // 初始化事件
  void _initEvent() {
    EventChannel eventChannel = EventChannel('flutter_mimc.event');
    eventChannel.receiveBroadcastStream().listen(_eventListener, onError: _errorListener);
  }

  // eventListener
  void _eventListener(dynamic event) {
    String eventType = event['eventType'];
    dynamic eventValue = event['eventValue'];
    debugPrint("eventType===$eventType");
    debugPrint("eventValue===$eventValue");
   switch(eventType){
     case MIMCEvents.onlineStatusListener:
       _onlineStatusListenerStreamController.add(eventValue as bool);
       break;
     case MIMCEvents.onHandleSendMessageTimeout:
       break;
     case MIMCEvents.onHandleMessage:
       break;
     case MIMCEvents.onHandleGroupMessage:
       break;
     case MIMCEvents.onHandleServerAck:
       break;
     default:
       print("notfund event");
   }
  }

  // 状态改变回调
  Stream<bool> onStatusChangedListener(){
    return _onlineStatusListenerStreamController.stream;
  }


  // event error
  void _errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }



}

