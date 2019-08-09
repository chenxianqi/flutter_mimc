import 'dart:async';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'model/mimc_chat_message.dart';
export 'model/mimc_chat_message.dart';

class MIMCEvents{
  static const String onlineStatusListener = "onlineStatusListener";              // 状态变更
  static const String onHandleSendMessageTimeout = "onHandleSendMessageTimeout";  // 发送单聊消息超时
  static const String onHandleMessage = "onHandleMessage";                        // 接收单聊
  static const String onHandleGroupMessage = "onHandleGroupMessage";              // 接收群聊
  static const String onHandleSendGroupMessageTimeout = "onHandleSendGroupMessageTimeout"; // 发送群聊消息超时
  static const String onHandleServerAck = "onHandleServerAck";                    // 接收服务端已收到发送消息确认
}


class FlutterMimc {

  final  MethodChannel _channel = const MethodChannel('flutter_mimc');
  final EventChannel _eventChannel = EventChannel('flutter_mimc.event');

  static const String   _ON_INIT        =     'init';          // 参数形式初始化
  static const String   _ON_LOGIN       =     'login';         // 登录
  static const String   _ON_LOGOUT      =     'logout';        // 退出登录
  static const String   _ON_GET_ACCOUNT =     'getAccount';    // 获取当前账号
  static const String   _ON_IS_ONLINE   =     'isOnline';     // 获取登录状态（可能不准）请以事件回调为准
  static const String   _ON_SEND_MESSAGE   =  'sendMessage';  // 发送单聊消息
  static const String   _ON_SEND_GROUP_MESSAGE   =  'sendGroupMessage';  // 发送群聊消息

  // 状态变更
  final StreamController<bool> _onlineStatusListenerStreamController = StreamController<bool>.broadcast();
  // 接收单聊
  final StreamController<MimcChatMessage> _onHandleMessageStreamController = StreamController<MimcChatMessage>.broadcast();
  // 接收群聊
  final StreamController<MimcChatMessage> _onHandleGroupMessageStreamController = StreamController<MimcChatMessage>.broadcast();
  // 接收服务端已收到发送消息确认
  final StreamController<String> _onHandleServerAckStreamController = StreamController<String>.broadcast();
  // 发送单聊消息超时
  final StreamController<MimcChatMessage> _onHandleSendMessageTimeoutStreamController = StreamController<MimcChatMessage>.broadcast();
  // 发送群聊消息超时
  final StreamController<MimcChatMessage> _onHandleSendGroupMessageTimeoutStreamController = StreamController<MimcChatMessage>.broadcast();

  //  * 初始化
  //  * String appId        应用ID，小米开放平台申请分配的appId
  //  * String appKey       应用appKey，小米开放平台申请分配的appKey
  //  * String appSecret    应用appKey，小米开放平台申请分配的appSecret
  //  * String appAccount   会话账号（或业务平台唯一ID）
  FlutterMimc.init(Map<String, dynamic> options){
    _channel.invokeMethod(_ON_INIT, options);
    _initEvent();
  }


  // 登录
  // @return bool
  Future<void> login() async {
    return await _channel.invokeMethod(_ON_LOGIN);
  }

  // 退出登录
  // @return null 无返回值
  Future<void> logout() async {
    return await _channel.invokeMethod(_ON_LOGOUT);
  }

  // 登录状态  （慎用）
  // @return bool
  Future<bool> isOnline() async {
    return await _channel.invokeMethod(_ON_IS_ONLINE);
  }

  // 初始化事件
  void _initEvent() async{
    _eventChannel.receiveBroadcastStream().listen(_eventListener, onError: _errorListener);
  }

  // 发送单聊消息
  Future<String> sendMessage(MimcChatMessage message) async{
    return await _channel.invokeMethod(_ON_SEND_MESSAGE, message.toJson());
  }

  // eventListener
  void _eventListener(event) {
    print(event);
    String eventType = event['eventType'];
    dynamic eventValue = event['eventValue'];
    debugPrint("eventType===$eventType");
    debugPrint("eventValue===$eventValue");
    print(jsonEncode(eventValue));
   switch(eventType){
     case MIMCEvents.onlineStatusListener:
       _onlineStatusListenerStreamController.add(eventValue as bool);
       break;
     case MIMCEvents.onHandleMessage:
       _onHandleMessageStreamController.add(MimcChatMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleSendMessageTimeout:
       _onHandleSendMessageTimeoutStreamController.add(MimcChatMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleGroupMessage:
       _onHandleGroupMessageStreamController.add(MimcChatMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleSendGroupMessageTimeout:
       _onHandleSendGroupMessageTimeoutStreamController.add(MimcChatMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleServerAck:
       _onHandleServerAckStreamController.add(eventValue as String);
       break;
     default:
       print("notfund event");
   }
  }

  // 状态改变回调
  Stream<bool> addEventListenerStatusChanged(){
    return _onlineStatusListenerStreamController.stream;
  }

  // 接收单聊消息
  Stream<MimcChatMessage> addEventListenerHandleMessage(){
    return _onHandleMessageStreamController.stream;
  }

  // 接收群聊
  Stream<MimcChatMessage> addEventListenerHandleGroupMessage(){
    return _onHandleGroupMessageStreamController.stream;
  }

  // 接收服务端已收到发送消息确认
  Stream<String> addEventListenerServerAck(){
    return _onHandleServerAckStreamController.stream;
  }

  // 发送单聊消息超时
  Stream<MimcChatMessage> addEventListenerSendMessageTimeout(){
    return _onHandleSendMessageTimeoutStreamController.stream;
  }

  // 发送群聊消息超时
  Stream<MimcChatMessage> addEventListenerSendGroupMessageTimeout(){
    return _onHandleSendGroupMessageTimeoutStreamController.stream;
  }


  // event error
  void _errorListener(Object obj) {
    final PlatformException e = obj;
    debugPrint("eventError===$obj");
    throw e;
  }



}

