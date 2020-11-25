import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'model/mimc_message.dart';
import 'model/mimc_servera_ack.dart';

export 'model/mimc_message.dart';
export 'model/mimc_servera_ack.dart';
export 'services/enums.dart';

/// Message event type
class MIMCEvents {
  static const String onlineStatusListener =
      "onlineStatusListener"; // Status change callback
  static const String onHandleMessage =
      "onHandleMessage"; // Receive single chat callback
  static const String onHandleGroupMessage =
      "onHandleGroupMessage"; // Receive group chat callback
  static const String onHandleSendMessageTimeout =
      "onHandleSendMessageTimeout"; // Send single chat message timed out callback
  static const String onHandleSendGroupMessageTimeout =
      "onHandleSendGroupMessageTimeout"; // Send single chat message timed out callback
  static const String onHandleSendUnlimitedGroupMessageTimeout =
      "onHandleSendUnlimitedGroupMessageTimeout"; // Send unlimited group chat message timeout callback
  static const String onHandleServerAck =
      "onHandleServerAck"; // The receiving server has received a confirmation message callback
  static const String onHandleCreateUnlimitedGroup =
      "onHandleCreateUnlimitedGroup"; // Create unlimited group callback
  static const String onHandleJoinUnlimitedGroup =
      "onHandleJoinUnlimitedGroup"; // join unlimited group callback
  static const String onHandleQuitUnlimitedGroup =
      "onHandleQuitUnlimitedGroup"; // quit unlimited group callback
  static const String onHandleDismissUnlimitedGroup =
      "onHandleDismissUnlimitedGroup"; // dismiss unlimited group callback
  static const String onHandleOnlineMessageAck =
      "onHandleOnlineMessageAck"; // send Feedback callback for online messages
  static const String onHandleOnlineMessage =
      "onHandleOnlineMessage"; // Receive Feedback callback for online messages
}

class FlutterMIMC {
  static FlutterMIMC _instance;
  static FlutterMIMC get _getInstance {
    if (_instance != null) return _instance;
    _instance = FlutterMIMC();
    return _instance;
  }

  final MethodChannel _channel = MethodChannel('flutter_mimc');
  final EventChannel _eventChannel = EventChannel('flutter_mimc.event');

  static const String _ON_INIT = 'init';

  /// initialization
  static const String _ON_LOGIN = 'login';

  /// login
  static const String _ON_LOGOUT = 'logout';

  /// logout
  static const String _ON_GET_ACCOUNT = 'getAccount';

  /// get account
  static const String _ON_GET_TOKEN = 'getToken';

  /// get token
  static const String _ON_GET_APP_ID = 'getAppID';

  /// get appId
  static const String _ON_IS_ONLINE = 'isOnline';

  /// get status
  static const String _ON_SEND_MESSAGE = 'sendMessage';

  /// Send single chat message
  static const String _ON_SEND_ONLINE_MESSAGE = 'sendOnLineMessage';

  /// Send online chat message
  static const String _ON_SEND_GROUP_MESSAGE = 'sendGroupMsg';

  /// Send group chat message
  static const String _ON_JOIN_UNLIMITED_GROUP = 'joinUnlimitedGroup';

  /// join unlimited group group
  static const String _ON_QUIT_UNLIMITED_GROUP = 'quitUnlimitedGroup';

  /// quit unlimited group group
  static const String _ON_DISMISS_UNLIMITED_GROUP = 'dismissUnlimitedGroup';

  /// dismiss unlimited group group

  /// status changed
  final StreamController<bool> _onlineStatusListenerStreamController =
      StreamController<bool>.broadcast();

  /// Receive single chat
  final StreamController<MIMCMessage> _onHandleMessageStreamController =
      StreamController<MIMCMessage>.broadcast();

  /// Receive group chat
  final StreamController<MIMCMessage> _onHandleGroupMessageStreamController =
      StreamController<MIMCMessage>.broadcast();

  /// The receiving server has received a confirmation message
  final StreamController<MimcServeraAck> _onHandleServerAckStreamController =
      StreamController<MimcServeraAck>.broadcast();

  /// Send a single chat message timed out
  final StreamController<MIMCMessage>
      _onHandleSendMessageTimeoutStreamController =
      StreamController<MIMCMessage>.broadcast();

  /// Send group chat message timed out
  final StreamController<MIMCMessage>
      _onHandleSendGroupMessageTimeoutStreamController =
      StreamController<MIMCMessage>.broadcast();

  /// Send unlimited group chat message timeout
  final StreamController<MIMCMessage>
      _onHandleSendUnlimitedGroupMessageTimeoutStreamController =
      StreamController<MIMCMessage>.broadcast();

  /// Create unlimited group callback
  final StreamController<Map<dynamic, dynamic>>
      _onHandleCreateUnlimitedGroupStreamController =
      StreamController<Map<dynamic, dynamic>>.broadcast();

  /// Join unlimited group of callbacks
  final StreamController<Map<dynamic, dynamic>>
      _onHandleJoinUnlimitedGroupStreamController =
      StreamController<Map<dynamic, dynamic>>.broadcast();

  /// Exit unlimited group callback
  final StreamController<Map<dynamic, dynamic>>
      _onHandleQuitUnlimitedGroupStreamController =
      StreamController<Map<dynamic, dynamic>>.broadcast();

  /// Disbanding unlimited group callbacks
  final StreamController<Map<dynamic, dynamic>>
      _onHandleDismissUnlimitedGroupStreamController =
      StreamController<Map<dynamic, dynamic>>.broadcast();

  // send Feedback callback for online messages callbacks
  final StreamController<MimcServeraAck>
      _onHandleOnlineMessageAckStreamController =
      StreamController<MimcServeraAck>.broadcast();

  // Receive Feedback callback for online messages callbacks
  final StreamController<MIMCMessage> _onHandleOnlineMessageStreamController =
      StreamController<MIMCMessage>.broadcast();

  /// initMImcInvokeMethod
  Future<dynamic> _initMImcInvokeMethod(String tokenString,
      {bool debug = false}) async {
    try {
      await _channel
          .invokeMethod(_ON_INIT, {"token": tokenString, "debug": debug});
      _initEvent();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// FlutterMIMC
  FlutterMIMC();

  ///  * init
  ///  * String tokenString  Obtained by server signature
  static Future<FlutterMIMC> stringTokenInit(String tokenString,
      {bool debug = false}) async {
    assert(tokenString != null && tokenString.isNotEmpty);
    await _getInstance._initMImcInvokeMethod(tokenString, debug: debug);
    return _instance;
  }

  /// login
  /// @return bool
  Future<dynamic> login() async {
    return await _channel.invokeMethod(_ON_LOGIN);
  }

  /// logout
  /// @return null no return
  Future<dynamic> logout() async {
    return await _channel.invokeMethod(_ON_LOGOUT);
  }

  /// get login status
  /// @return bool
  Future<bool> isOnline() async {
    return await _channel.invokeMethod(_ON_IS_ONLINE);
  }

  /// init event
  void _initEvent() async {
    _eventChannel
        .receiveBroadcastStream()
        .listen(_eventListener, onError: _errorListener);
  }

  /// get token
  /// @return String
  Future<String> getToken() async {
    return await _channel.invokeMethod(_ON_GET_TOKEN);
  }

  /// get appID
  /// @return String
  Future<String> getAppId() async {
    return await _channel.invokeMethod(_ON_GET_APP_ID);
  }

  /// Get current account
  /// @return String
  Future<String> getAccount() async {
    return await _channel.invokeMethod(_ON_GET_ACCOUNT);
  }

  /// Send a single chat message
  Future<String> sendMessage(MIMCMessage message) async {
    assert(message != null);
    return await _channel.invokeMethod(_ON_SEND_MESSAGE, message.toJson());
  }

  /// Send a online chat message
  Future<String> sendOnlineMessage(MIMCMessage message) async {
    assert(message != null);
    return await _channel.invokeMethod(
        _ON_SEND_ONLINE_MESSAGE, message.toJson());
  }

  /// Send group chat
  /// @ message message body
  /// @ isUnlimitedGroup is Unlimited Group
  Future<String> sendGroupMsg(MIMCMessage message,
      {bool isUnlimitedGroup = false}) async {
    assert(message != null);
    return await _channel.invokeMethod(_ON_SEND_GROUP_MESSAGE,
        {"message": message.toJson(), "isUnlimitedGroup": isUnlimitedGroup});
  }

  /// join unlimited group
  /// [topicId] group id
  Future<String> joinUnlimitedGroup(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel
        .invokeMethod(_ON_JOIN_UNLIMITED_GROUP, {"topicId": topicId});
  }

  /// quit unlimited group
  /// [topicId] group id
  Future<String> quitUnlimitedGroup(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel
        .invokeMethod(_ON_QUIT_UNLIMITED_GROUP, {"topicId": topicId});
  }

  /// dismiss unlimited group
  /// [topicId] group id
  Future<dynamic> dismissUnlimitedGroup(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel
        .invokeMethod(_ON_DISMISS_UNLIMITED_GROUP, {"topicId": topicId});
  }

  /// eventListener
  void _eventListener(event) {
    String eventType = event['eventType'];
    dynamic eventValue = event['eventValue'];
    switch (eventType) {
      case MIMCEvents.onlineStatusListener:
        _onlineStatusListenerStreamController.add(eventValue as bool);
        break;
      case MIMCEvents.onHandleMessage:
        _onHandleMessageStreamController.add(MIMCMessage.fromJson(eventValue));
        break;
      case MIMCEvents.onHandleSendMessageTimeout:
        _onHandleSendMessageTimeoutStreamController
            .add(MIMCMessage.fromJson(eventValue));
        break;
      case MIMCEvents.onHandleGroupMessage:
        _onHandleGroupMessageStreamController
            .add(MIMCMessage.fromJson(eventValue));
        break;
      case MIMCEvents.onHandleSendGroupMessageTimeout:
        _onHandleSendGroupMessageTimeoutStreamController
            .add(MIMCMessage.fromJson(eventValue));
        break;
      case MIMCEvents.onHandleSendUnlimitedGroupMessageTimeout:
        _onHandleSendUnlimitedGroupMessageTimeoutStreamController
            .add(MIMCMessage.fromJson(eventValue));
        break;
      case MIMCEvents.onHandleServerAck:
        _onHandleServerAckStreamController
            .add(MimcServeraAck.fromJson(eventValue as Map<dynamic, dynamic>));
        break;
      case MIMCEvents.onHandleCreateUnlimitedGroup:
        _onHandleCreateUnlimitedGroupStreamController
            .add(eventValue as Map<dynamic, dynamic>);
        break;
      case MIMCEvents.onHandleJoinUnlimitedGroup:
        _onHandleJoinUnlimitedGroupStreamController
            .add(eventValue as Map<dynamic, dynamic>);
        break;
      case MIMCEvents.onHandleQuitUnlimitedGroup:
        _onHandleQuitUnlimitedGroupStreamController
            .add(eventValue as Map<dynamic, dynamic>);
        break;
      case MIMCEvents.onHandleDismissUnlimitedGroup:
        _onHandleDismissUnlimitedGroupStreamController
            .add(eventValue as Map<dynamic, dynamic>);
        break;
      case MIMCEvents.onHandleOnlineMessage:
        _onHandleOnlineMessageStreamController
            .add(MIMCMessage.fromJson(eventValue));
        break;
      case MIMCEvents.onHandleOnlineMessageAck:
        _onHandleOnlineMessageAckStreamController
            .add(MimcServeraAck.fromJson(eventValue as Map<dynamic, dynamic>));
        break;
      default:
        print("notfund event");
    }
  }

  /// send online message Ack callback
  void removeEventListenerOnlineMessageAck() =>
      _onHandleOnlineMessageAckStreamController.close();

  Stream<MimcServeraAck> addEventListenerOnlineMessageAck() {
    return _onHandleOnlineMessageAckStreamController.stream;
  }

  /// online message callback
  void removeEventListenerOnlineMessage() =>
      _onHandleOnlineMessageStreamController.close();

  Stream<MIMCMessage> addEventListenerOnlineMessage() {
    return _onHandleOnlineMessageStreamController.stream;
  }

  /// status change callback
  void removeEventListenerStatusChanged() =>
      _onlineStatusListenerStreamController.close();

  Stream<bool> addEventListenerStatusChanged() {
    return _onlineStatusListenerStreamController.stream;
  }

  /// Receive single chat messages callback
  void removeEventListenerHandleMessage() =>
      _onHandleMessageStreamController.close();

  Stream<MIMCMessage> addEventListenerHandleMessage() {
    return _onHandleMessageStreamController.stream;
  }

  /// Receiving group chat callback
  void removeEventListenerHandleGroupMessage() =>
      _onHandleGroupMessageStreamController.close();

  Stream<MIMCMessage> addEventListenerHandleGroupMessage() {
    return _onHandleGroupMessageStreamController.stream;
  }

  /// The receiving server has received a confirmation message
  void removeEventListenerServerAck() =>
      _onHandleServerAckStreamController.close();

  Stream<MimcServeraAck> addEventListenerServerAck() {
    return _onHandleServerAckStreamController.stream;
  }

  /// Send a single chat message timed out
  void removeEventListenerSendMessageTimeout() =>
      _onHandleSendMessageTimeoutStreamController.close();

  Stream<MIMCMessage> addEventListenerSendMessageTimeout() {
    return _onHandleSendMessageTimeoutStreamController.stream;
  }

  /// Send group chat message timed out
  void removeEventListenerSendGroupMessageTimeout() =>
      _onHandleSendGroupMessageTimeoutStreamController.close();

  Stream<MIMCMessage> addEventListenerSendGroupMessageTimeout() {
    return _onHandleSendGroupMessageTimeoutStreamController.stream;
  }

  /// Send unlimited group chat message timeout
  void removeEventListenerSendUnlimitedGroupMessageTimeout() =>
      _onHandleSendUnlimitedGroupMessageTimeoutStreamController.close();

  Stream<MIMCMessage> addEventListenerSendUnlimitedGroupMessageTimeout() {
    return _onHandleSendUnlimitedGroupMessageTimeoutStreamController.stream;
  }

  /// Create unlimited group callback
  void removeEventListenerHandleCreateUnlimitedGroup() =>
      _onHandleCreateUnlimitedGroupStreamController.close();

  Stream<Map<dynamic, dynamic>> addEventListenerHandleCreateUnlimitedGroup() {
    return _onHandleCreateUnlimitedGroupStreamController.stream;
  }

  /// join unlimited group callback
  void removeEventListenerHandleJoinUnlimitedGroup() =>
      _onHandleJoinUnlimitedGroupStreamController.close();

  Stream<Map<dynamic, dynamic>> addEventListenerHandleJoinUnlimitedGroup() {
    return _onHandleJoinUnlimitedGroupStreamController.stream;
  }

  /// quit unlimited group callback
  void removeEventListenerHandleQuitUnlimitedGroup() =>
      _onHandleQuitUnlimitedGroupStreamController.close();

  Stream<Map<dynamic, dynamic>> addEventListenerHandleQuitUnlimitedGroup() {
    return _onHandleQuitUnlimitedGroupStreamController.stream;
  }

  /// dismiss unlimited group callback
  void removeEventListenerHandleDismissUnlimitedGroup() =>
      _onHandleDismissUnlimitedGroupStreamController.close();

  Stream<Map<dynamic, dynamic>> addEventListenerHandleDismissUnlimitedGroup() {
    return _onHandleDismissUnlimitedGroupStreamController.stream;
  }

  /// event error
  void _errorListener(Object obj) {
    final PlatformException e = obj;
    debugPrint("eventError===$obj");
    throw e;
  }
}
