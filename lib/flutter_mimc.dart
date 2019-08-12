import 'dart:async';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'model/mimc_chat_message.dart';
import 'model/mimc_servera_ack.dart';
export 'model/mimc_chat_message.dart';
export 'model/mimc_servera_ack.dart';

class MIMCEvents{
  static const String onlineStatusListener = "onlineStatusListener";              // 状态变更
  static const String onHandleMessage = "onHandleMessage";                        // 接收单聊
  static const String onHandleGroupMessage = "onHandleGroupMessage";              // 接收群聊
  static const String onHandleSendMessageTimeout = "onHandleSendMessageTimeout";  // 发送单聊消息超时
  static const String onHandleSendGroupMessageTimeout = "onHandleSendGroupMessageTimeout"; // 发送群聊消息超时
  static const String onHandleSendUnlimitedGroupMessageTimeout = "onHandleSendUnlimitedGroupMessageTimeout"; // 发送无限群聊消息超时
  static const String onHandleServerAck = "onHandleServerAck";                    // 接收服务端已收到发送消息确认
  static const String onHandleCreateUnlimitedGroup = "onHandleCreateUnlimitedGroup";  // 创建大群回调
  static const String onHandleJoinUnlimitedGroup = "onHandleJoinUnlimitedGroup";      // 加入大群回调
  static const String onHandleQuitUnlimitedGroup = "onHandleQuitUnlimitedGroup";      // 退出群回调
  static const String onHandleDismissUnlimitedGroup = "onHandleDismissUnlimitedGroup";// 解散大群回调
}


class FlutterMimc {

  final  MethodChannel _channel = const MethodChannel('flutter_mimc');
  final EventChannel _eventChannel = EventChannel('flutter_mimc.event');

  static const String   _ON_INIT        =     'init';          // 参数形式初始化
  static const String   _ON_LOGIN       =     'login';         // 登录
  static const String   _ON_LOGOUT      =     'logout';        // 退出登录
  static const String   _ON_GET_ACCOUNT =     'getAccount';    // 获取当前账号
  static const String   _ON_GET_TOKEN   =     'getToken';      // 获取token
  static const String   _ON_IS_ONLINE   =     'isOnline';     // 获取登录状态（可能不准）请以事件回调为准
  static const String   _ON_CREATE_GROUP   =  'createGroup';  // 创建群
  static const String   _ON_QUERY_GROUP_INFO    =  'queryGroupInfo';              // 查询指定群信息
  static const String   _ON_QUERY_GROUP_OF_ACCOUNT    =  'queryGroupsOfAccount';  // 查询所属群信息
  static const String   _ON_JOIN_GROUP     =  'joinGroup';      // 邀请用户加入群
  static const String   _ON_QUIT_GROUP     =  'quitGroup';      // 非群主用户退群
  static const String   _ON_KICK_GROUP     =  'kickGroup';      // 群主踢成员出群
  static const String   _ON_UPDATE_GROUP   =  'updateGroup';    // 群主更新群信息
  static const String   _ON_DISMISS_GROUP  =  'dismissGroup';   // 群主销毁群
  static const String   _ON_PULL_P2P_HISTORY  =  'pullP2PHistory';   // 拉取单聊消息记录
  static const String   _ON_PULL_P2T_HISTORY  =  'pullP2THistory';   // 拉取群聊消息记录
  static const String   _ON_SEND_MESSAGE      =  'sendMessage';      // 发送单聊消息
  static const String   _ON_SEND_GROUP_MESSAGE   =  'sendGroupMsg';  // 发送群聊消息
  static const String   _ON_CREATE_UNLIMITED_GROUP  = 'createUnlimitedGroup';   // 创建无限大群
  static const String   _ON_JOIN_UNLIMITED_GROUP    = 'joinUnlimitedGroup';     // 加入无限大群
  static const String   _ON_QUIT_UNLIMITED_GROUP    = 'quitUnlimitedGroup';     // 退出无限大群
  static const String   _ON_DISMISS_UNLIMITED_GROUP = 'dismissUnlimitedGroup';  // 解散无限大群
  static const String   _ON_QUERY_UNLIMITED_GROUP_MEMBERS = 'queryUnlimitedGroupMembers';           // 查询无限大群成员
  static const String   _ON_QUERY_UNLIMITED_GROUPS        = 'queryUnlimitedGroups';                 // 查询无限大群
  static const String   _ON_QUERY_UNLIMITED_GROUP_ONLINE_USERS = 'queryUnlimitedGroupOnlineUsers';  // 查询无限大群在线用户数
  static const String   _ON_QUERY_UNLIMITED_GROUP_INFO = 'queryUnlimitedGroupInfo';                 // 查询无限大群在线用户数
  static const String   _ON_UPDATE_UNLIMITED_GROUP      = 'updateUnlimitedGroup';                   // 更新无限大群信息

  // 状态变更
  final StreamController<bool> _onlineStatusListenerStreamController = StreamController<bool>.broadcast();
  // 接收单聊
  final StreamController<MimcChatMessage> _onHandleMessageStreamController = StreamController<MimcChatMessage>.broadcast();
  // 接收群聊
  final StreamController<MimcChatMessage> _onHandleGroupMessageStreamController = StreamController<MimcChatMessage>.broadcast();
  // 接收服务端已收到发送消息确认
  final StreamController<MimcServeraAck> _onHandleServerAckStreamController = StreamController<MimcServeraAck>.broadcast();
  // 发送单聊消息超时
  final StreamController<MimcChatMessage> _onHandleSendMessageTimeoutStreamController = StreamController<MimcChatMessage>.broadcast();
  // 发送群聊消息超时
  final StreamController<MimcChatMessage> _onHandleSendGroupMessageTimeoutStreamController = StreamController<MimcChatMessage>.broadcast();
  // 发送无限群聊消息超时
  final StreamController<MimcChatMessage> _onHandleSendUnlimitedGroupMessageTimeoutStreamController = StreamController<MimcChatMessage>.broadcast();
  // 创建大群回调
  final StreamController<Map<dynamic, dynamic>> _onHandleCreateUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();
  // 加入大群回调
  final StreamController<Map<dynamic, dynamic>> _onHandleJoinUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();
  // 退出大群回调
  final StreamController<Map<dynamic, dynamic>> _onHandleQuitUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();
  // 解散大群回调
  final StreamController<Map<dynamic, dynamic>> _onHandleDismissUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();

  //  * 初始化
  //  * String appId        应用ID，小米开放平台申请分配的appId
  //  * String appKey       应用appKey，小米开放平台申请分配的appKey
  //  * String appSecret    应用appKey，小米开放平台申请分配的appSecret
  //  * String appAccount   会话账号（或业务平台唯一ID）
  FlutterMimc.init({
    bool debug = false,
    String appId,
    String appKey,
    String appSecret,
    String appAccount
  }){
    assert(appId != null && appId.isNotEmpty);
    assert(appKey != null && appKey.isNotEmpty);
    assert(appSecret != null && appSecret.isNotEmpty);
    assert(appAccount != null && appAccount.isNotEmpty);
    _channel.invokeMethod(_ON_INIT, {"debug": debug, "appId": appId, "appKey":appKey,"appSecret":appSecret,"appAccount":appAccount});
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

  // 获取token
  // @return String
  // 请登录后获取不然返回null
  Future<String> getToken() async {
    return await _channel.invokeMethod(_ON_GET_TOKEN);
  }

  // 获取当前账号
  // @return String
  Future<String> getAccount() async {
    return await _channel.invokeMethod(_ON_GET_ACCOUNT);
  }

  // 发送单聊消息
  Future<String> sendMessage(MimcChatMessage message) async{
    assert(message != null);
    return await _channel.invokeMethod(_ON_SEND_MESSAGE, message.toJson());
  }

  // 发送群聊
  // @ message 消息体
  // @ isUnlimitedGroup 是否是无限大群
  Future<String> sendGroupMsg(MimcChatMessage message, {bool isUnlimitedGroup = false}) async{
    assert(message != null);
    return await _channel.invokeMethod(_ON_SEND_GROUP_MESSAGE, {
      "message": message.toJson(),
      "isUnlimitedGroup": isUnlimitedGroup
    });
  }

  //  * 创建群
  //  * @param groupName 群名
  //  * @param users 群成员，多个成员之间用英文逗号(,)分隔
  //  * @return  Map
  Future<Map<dynamic, dynamic>> createGroup(String groupName, String users) async{
    assert(groupName != null && groupName.isNotEmpty);
    return await _channel.invokeMethod(_ON_CREATE_GROUP, {
      "groupName": groupName,
      "users": users
    });
  }

  //  * 查询指定群信息
  //  * @param groupId 群ID
  //  * @return  Map
  Future<Map<dynamic, dynamic>> queryGroupInfo(String groupId) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_GROUP_INFO, {
      "groupId": groupId
    });
  }

  //  * 查询所属群信息
  //  * @param groupId 群ID
  //  * @return  Map
  Future<Map<dynamic, dynamic>> queryGroupsOfAccount() async{
    return await _channel.invokeMethod(_ON_QUERY_GROUP_OF_ACCOUNT);
  }

  //  * 邀请用户加入群
  //  * @param groupId 群ID
  //  * @param users 群成员，多个成员之间用英文逗号(,)分隔
  //  * @return  Map
  Future<Map<dynamic, dynamic>> joinGroup(String groupId, String users) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_JOIN_GROUP, {
    "groupId": groupId,
    "users": users
    });
  }

  //  * 非群主用户退群
  //  * @param groupId 群ID
  //  * @return Map
  Future<Map<dynamic, dynamic>> quitGroup(String groupId) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUIT_GROUP, {
      "groupId": groupId
    });
  }

  //  * 群主踢成员出群
  //  * @param  groupId 群ID
  // *  @users 群成员，多个成员之间用英文逗号(,)分隔
  // * @return Map
  Future<Map<dynamic, dynamic>> kickGroup(String groupId, String users) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_KICK_GROUP, {
      "groupId": groupId,
      "users": users
    });
  }

  //  * 群主更新群信息
  //  * @param groupId 群ID
  //  * @param newOwnerAccount 若为群成员则指派新的群主
  //  * @param newGroupName 群名
  //  * @param newGroupBulletin 群公告
  // * @return Map
  Future<Map<dynamic, dynamic>> updateGroup(String groupId,{
    String newOwnerAccount = "",
    String newGroupName = "",
    String newGroupBulletin = ""
  }) async{
    assert(groupId != null);
    return await _channel.invokeMethod(_ON_UPDATE_GROUP, {
      "groupId": groupId,
      "newOwnerAccount": newOwnerAccount,
      "newGroupName": newGroupName,
      "newGroupBulletin": newGroupBulletin
    });
  }

  //  * 群主销毁群
  //  * @param  groupId 群ID
  //  * @return Map
  Future<Map<dynamic, dynamic>> dismissGroup(String groupId) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_DISMISS_GROUP, {
      "groupId": groupId
    });
  }



  //   * 拉取单聊消息记录
  //   * @param toAccount   接收方帐号
  //   * @param fromAccount 发送方帐号
  //   * @param utcFromTime 开始时间
  //   * @param utcToTime   结束时间
  //   * 注意：utcFromTime和utcToTime的时间间隔不能超过24小时，查询状态为[utcFromTime,utcToTime)，单位毫秒，UTC时间
  Future<Map<dynamic, dynamic>> pullP2PHistory({
    String toAccount,
    String fromAccount,
    String utcFromTime,
    String utcToTime
  }) async{
    assert(toAccount != null && toAccount.isNotEmpty);
    assert(fromAccount != null && fromAccount.isNotEmpty);
    assert(utcFromTime != null && utcFromTime.isNotEmpty);
    assert(utcToTime != null && utcToTime.isNotEmpty);
    return await _channel.invokeMethod(_ON_PULL_P2P_HISTORY, {
      "toAccount": toAccount,
      "fromAccount": fromAccount,
      "utcFromTime": utcFromTime,
      "utcToTime": utcToTime
    });
  }

  //  * 拉取群聊消息记录
  //  * @param account 拉取者帐号
  //  * @param topicId 群ID
  //  * @param utcFromTime 开始时间
  //  * @param utcToTime 结束时间
  //  * 注意：utcFromTime和utcToTime的时间间隔不能超过24小时，查询状态为[utcFromTime,utcToTime)，单位毫秒，UTC时间
  Future<Map<dynamic, dynamic>> pullP2THistory({
    String account,
    String topicId,
    String utcFromTime,
    String utcToTime
  }) async{
    assert(account != null && account.isNotEmpty);
    assert(topicId != null && topicId.isNotEmpty);
    assert(utcFromTime != null && utcFromTime.isNotEmpty);
    assert(utcToTime != null && utcToTime.isNotEmpty);
    return await _channel.invokeMethod(_ON_PULL_P2T_HISTORY, {
      "account": account,
      "topicId": topicId,
      "utcFromTime": utcFromTime,
      "utcToTime": utcToTime,
    });
  }

  //  * 创建无限大群
  //  * @param topicName 群名
  Future<void> createUnlimitedGroup(String topicName) async{
    return await _channel.invokeMethod(_ON_CREATE_UNLIMITED_GROUP, {
      "topicName": topicName
    });
  }

  //  * 加入无限大群
  //  * @param topicId 群id
  //  * @return String 客户端生成的消息ID
  Future<String> joinUnlimitedGroup(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_JOIN_UNLIMITED_GROUP, {
      "topicId": topicId
    });
  }

  //  * 退出无限大群
  //  * @param topicId 群id
  //  * @return String 客户端生成的消息ID
  Future<String> quitUnlimitedGroup(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUIT_UNLIMITED_GROUP, {
      "topicId": topicId
    });
  }

  //  * 解散无限大群
  //  * @param topicId 群id
  Future<void> dismissUnlimitedGroup(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_DISMISS_UNLIMITED_GROUP, {
      "topicId": topicId
    });
  }


  //  * 查询无限大群成员
  //  * @param topicId 群id
  Future<Map<dynamic, dynamic>> queryUnlimitedGroupMembers(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUP_MEMBERS, {
      "topicId": topicId
    });
  }

  //  * 查询无限大群
  Future<Map<dynamic, dynamic>> queryUnlimitedGroups() async{
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUPS);
  }

  //  * 查询无限大群在线用户数
  //  * @param topicId 群id
  Future<Map<dynamic, dynamic>> queryUnlimitedGroupOnlineUsers(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUP_ONLINE_USERS, {
      "topicId": topicId
    });
  }

  //  * 查询无限大群基本信息
  //  * @param topicId 群id
  Future<Map<dynamic, dynamic>> queryUnlimitedGroupInfo(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUP_INFO, {
      "topicId": topicId
    });
  }

  ///  * 更新大群
  ///  * @param topicId
  ///  * @param newGroupName
  ///  * @param newOwnerAccount
  ///  * 更新群，topicId必填，其他参数必填一个
  ///  * 必须群主才能转让群，更新群信息，转让群主需要被转让用户在群中
  Future<Map<dynamic, dynamic>> updateUnlimitedGroup(String topicId, {
    String newGroupName = "",
    String newOwnerAccount = ""
  }) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_UPDATE_UNLIMITED_GROUP, {
      "topicId": topicId,
      "newGroupName": newGroupName,
      "newOwnerAccount": newOwnerAccount,
    });
  }


  // eventListener
  void _eventListener(event) {
    String eventType = event['eventType'];
    dynamic eventValue = event['eventValue'];
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
     case MIMCEvents.onHandleSendUnlimitedGroupMessageTimeout:
       _onHandleSendUnlimitedGroupMessageTimeoutStreamController.add(MimcChatMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleServerAck:
       _onHandleServerAckStreamController.add(MimcServeraAck.fromJson(eventValue as Map<dynamic, dynamic>));
       break;
     case MIMCEvents.onHandleCreateUnlimitedGroup:
       _onHandleCreateUnlimitedGroupStreamController.add(eventValue as Map<dynamic, dynamic>);
       break;
     case MIMCEvents.onHandleJoinUnlimitedGroup:
       _onHandleJoinUnlimitedGroupStreamController.add(eventValue as Map<dynamic, dynamic>);
       break;
     case MIMCEvents.onHandleQuitUnlimitedGroup:
       _onHandleQuitUnlimitedGroupStreamController.add(eventValue as Map<dynamic, dynamic>);
       break;
     case MIMCEvents.onHandleDismissUnlimitedGroup:
       _onHandleDismissUnlimitedGroupStreamController.add(eventValue as Map<dynamic, dynamic>);
       break;
     default:
       print("notfund event");
   }
  }

  // 状态改变回调
  void removeEventListenerStatusChanged() =>
      _onlineStatusListenerStreamController.close();
  Stream<bool> addEventListenerStatusChanged(){
    return _onlineStatusListenerStreamController.stream;
  }

  // 接收单聊消息
  void removeEventListenerHandleMessage() =>
      _onHandleMessageStreamController.close();
  Stream<MimcChatMessage> addEventListenerHandleMessage(){
    return _onHandleMessageStreamController.stream;
  }

  // 接收群聊
  void removeEventListenerHandleGroupMessage() =>
      _onHandleGroupMessageStreamController.close();
  Stream<MimcChatMessage> addEventListenerHandleGroupMessage(){
    return _onHandleGroupMessageStreamController.stream;
  }

  // 接收服务端已收到发送消息确认
  void removeEventListenerServerAck() =>
      _onHandleServerAckStreamController.close();
  Stream<MimcServeraAck> addEventListenerServerAck(){
    return _onHandleServerAckStreamController.stream;
  }

  // 发送单聊消息超时
  void removeEventListenerSendMessageTimeout() =>
      _onHandleSendMessageTimeoutStreamController.close();
  Stream<MimcChatMessage> addEventListenerSendMessageTimeout(){
    return _onHandleSendMessageTimeoutStreamController.stream;
  }

  // 发送群聊消息超时
  void removeEventListenerSendGroupMessageTimeout() =>
      _onHandleSendGroupMessageTimeoutStreamController.close();
  Stream<MimcChatMessage> addEventListenerSendGroupMessageTimeout(){
    return _onHandleSendGroupMessageTimeoutStreamController.stream;
  }

  // 发送无限群聊消息超时
  void removeEventListenerSendUnlimitedGroupMessageTimeout() =>
      _onHandleSendUnlimitedGroupMessageTimeoutStreamController.close();
  Stream<MimcChatMessage> addEventListenerSendUnlimitedGroupMessageTimeout(){
    return _onHandleSendUnlimitedGroupMessageTimeoutStreamController.stream;
  }

  // 创建大群回调
  void removeEventListenerHandleCreateUnlimitedGroup() =>
      _onHandleCreateUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleCreateUnlimitedGroup(){
    return _onHandleCreateUnlimitedGroupStreamController.stream;
  }

  // 加入大群回调
  void removeEventListenerHandleJoinUnlimitedGroup() =>
      _onHandleJoinUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleJoinUnlimitedGroup(){
    return _onHandleJoinUnlimitedGroupStreamController.stream;
  }

  // 退出大群回调
  void removeEventListenerHandleQuitUnlimitedGroup() =>
      _onHandleQuitUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleQuitUnlimitedGroup(){
    return _onHandleQuitUnlimitedGroupStreamController.stream;
  }

  // 解散大群回调
  void removeEventListenerHandleDismissUnlimitedGroup() =>
      _onHandleDismissUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleDismissUnlimitedGroup(){
    return _onHandleDismissUnlimitedGroupStreamController.stream;
  }



  // event error
  void _errorListener(Object obj) {
    final PlatformException e = obj;
    debugPrint("eventError===$obj");
    throw e;
  }



}

