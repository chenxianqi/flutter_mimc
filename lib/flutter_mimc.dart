import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'model/mimc_message.dart';
import 'model/mimc_servera_ack.dart';
export 'model/mimc_message.dart';
export 'model/mimc_servera_ack.dart';

/// Message event type
class MIMCEvents{
  static const String onlineStatusListener = "onlineStatusListener";              // Status change callback
  static const String onHandleMessage = "onHandleMessage";                        // Receive single chat callback
  static const String onHandleGroupMessage = "onHandleGroupMessage";              // Receive group chat callback
  static const String onHandleSendMessageTimeout = "onHandleSendMessageTimeout";  // Send single chat message timed out callback
  static const String onHandleSendGroupMessageTimeout = "onHandleSendGroupMessageTimeout"; // Send single chat message timed out callback
  static const String onHandleSendUnlimitedGroupMessageTimeout = "onHandleSendUnlimitedGroupMessageTimeout"; // Send unlimited group chat message timeout callback
  static const String onHandleServerAck = "onHandleServerAck";                        // The receiving server has received a confirmation message callback
  static const String onHandleCreateUnlimitedGroup = "onHandleCreateUnlimitedGroup";  // Create unlimited group callback
  static const String onHandleJoinUnlimitedGroup = "onHandleJoinUnlimitedGroup";      // join unlimited group callback
  static const String onHandleQuitUnlimitedGroup = "onHandleQuitUnlimitedGroup";      // quit unlimited group callback
  static const String onHandleDismissUnlimitedGroup = "onHandleDismissUnlimitedGroup";// dismiss unlimited group callback
}


class FlutterMimc {

  final MethodChannel _channel =  MethodChannel('flutter_mimc');
  final EventChannel _eventChannel = EventChannel('flutter_mimc.event');

  static const String   _ON_INIT        =       'init';             /// initialization
  static const String   _ON_STRING_TOKEN_INIT = 'stringTokenInit';  /// initialization
  static const String   _ON_LOGIN       =     'login';         /// login
  static const String   _ON_LOGOUT      =     'logout';        /// logout
  static const String   _ON_GET_ACCOUNT =     'getAccount';    /// get account
  static const String   _ON_GET_TOKEN   =     'getToken';      /// get token
  static const String   _ON_IS_ONLINE   =     'isOnline';      /// get status
  static const String   _ON_CREATE_GROUP   =  'createGroup';   /// create group
  static const String   _ON_GET_CONTACT   =   'getContact';    /// get contact
  static const String   _ON_SET_BLACKLIST =   'setBlackList';  /// set blacklist
  static const String   _ON_DELETE_BLACKLIST = 'deleteBlackList';  /// delete blacklist
  static const String   _ON_HAS_BLACKLIST   =  'hasBlackList';     /// has blacklist
  static const String   _ON_SET_GROUP_BLACKLIST   =  'setGroupBlackList';         /// set group blacklist
  static const String   _ON_DELETE_GROUP_BLACKLIST=  'deleteGroupBlackList';      /// delete group blacklist
  static const String   _ON_HAS_GROUP_BLACKLIST   =  'hasGroupBlackList';         /// has group blacklist
  static const String   _ON_QUERY_GROUP_INFO    =  'queryGroupInfo';              /// Query specified group information
  static const String   _ON_QUERY_GROUP_OF_ACCOUNT    =  'queryGroupsOfAccount';  /// Query group information
  static const String   _ON_JOIN_GROUP     =  'joinGroup';      /// Invite users to join the group
  static const String   _ON_QUIT_GROUP     =  'quitGroup';      /// Non-group master user quit group
  static const String   _ON_KICK_GROUP     =  'kickGroup';      /// Kicking members out of the group
  static const String   _ON_UPDATE_GROUP   =  'updateGroup';    /// group Lord Update group information
  static const String   _ON_DISMISS_GROUP  =  'dismissGroup';   /// group Lord dismiss group
  static const String   _ON_PULL_P2P_HISTORY  =  'pullP2PHistory';   /// Pull single chat message record
  static const String   _ON_PULL_P2T_HISTORY  =  'pullP2THistory';   /// Pull group chat message record
  static const String   _ON_SEND_MESSAGE      =  'sendMessage';      /// Send single chat message
  static const String   _ON_SEND_GROUP_MESSAGE   =  'sendGroupMsg';  /// Send group chat message
  static const String   _ON_CREATE_UNLIMITED_GROUP  = 'createUnlimitedGroup';   /// Create unlimited group group
  static const String   _ON_JOIN_UNLIMITED_GROUP    = 'joinUnlimitedGroup';     /// join unlimited group group
  static const String   _ON_QUIT_UNLIMITED_GROUP    = 'quitUnlimitedGroup';     /// quit unlimited group group
  static const String   _ON_DISMISS_UNLIMITED_GROUP = 'dismissUnlimitedGroup';  /// dismiss unlimited group group
  static const String   _ON_QUERY_UNLIMITED_GROUP_MEMBERS = 'queryUnlimitedGroupMembers';           /// Query unlimited group members
  static const String   _ON_QUERY_UNLIMITED_GROUPS        = 'queryUnlimitedGroups';                 /// Query unlimited groups
  static const String   _ON_QUERY_UNLIMITED_GROUP_ONLINE_USERS = 'queryUnlimitedGroupOnlineUsers';  /// Query the number of unlimited groups of online users
  static const String   _ON_QUERY_UNLIMITED_GROUP_INFO = 'queryUnlimitedGroupInfo';                 /// Query unlimited group info
  static const String   _ON_UPDATE_UNLIMITED_GROUP      = 'updateUnlimitedGroup';                   /// update unlimited group info

  /// status changed
  final StreamController<bool> _onlineStatusListenerStreamController = StreamController<bool>.broadcast();
  /// Receive single chat
  final StreamController<MIMCMessage> _onHandleMessageStreamController = StreamController<MIMCMessage>.broadcast();
  /// Receive group chat
  final StreamController<MIMCMessage> _onHandleGroupMessageStreamController = StreamController<MIMCMessage>.broadcast();
  /// The receiving server has received a confirmation message
  final StreamController<MimcServeraAck> _onHandleServerAckStreamController = StreamController<MimcServeraAck>.broadcast();
  /// Send a single chat message timed out
  final StreamController<MIMCMessage> _onHandleSendMessageTimeoutStreamController = StreamController<MIMCMessage>.broadcast();
  /// Send group chat message timed out
  final StreamController<MIMCMessage> _onHandleSendGroupMessageTimeoutStreamController = StreamController<MIMCMessage>.broadcast();
  /// Send unlimited group chat message timeout
  final StreamController<MIMCMessage> _onHandleSendUnlimitedGroupMessageTimeoutStreamController = StreamController<MIMCMessage>.broadcast();
  /// Create unlimited group callback
  final StreamController<Map<dynamic, dynamic>> _onHandleCreateUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();
  /// Join unlimited group of callbacks
  final StreamController<Map<dynamic, dynamic>> _onHandleJoinUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();
  /// Exit unlimited group callback
  final StreamController<Map<dynamic, dynamic>> _onHandleQuitUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();
  /// Disbanding unlimited group callbacks
  final StreamController<Map<dynamic, dynamic>> _onHandleDismissUnlimitedGroupStreamController = StreamController<Map<dynamic, dynamic>>.broadcast();

  ///  * init
  ///  * String appId        application ID，Xiaomi open platform application for distribution    appId
  ///  * String appKey       application appKey，Xiaomi open platform application for distribution appKey
  ///  * String appSecret    application appKey，Xiaomi open platform application for distribution appSecret
  ///  * String appAccount   Session account（business platform unique ID）
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

  ///  * init
  ///  * String tokenString  Obtained by server signature
  FlutterMimc.stringTokenInit(String tokenString, {bool debug = false}){
    assert(tokenString != null && tokenString.isNotEmpty);
    _channel.invokeMethod(_ON_STRING_TOKEN_INIT, {
      "token": tokenString,
      "debug": debug
    });
    _initEvent();
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
  void _initEvent() async{
    _eventChannel.receiveBroadcastStream().listen(_eventListener, onError: _errorListener);
  }

  /// get token
  /// @return String
  Future<String> getToken() async {
    return await _channel.invokeMethod(_ON_GET_TOKEN);
  }

  /// Get current account
  /// @return String
  Future<String> getAccount() async {
    return await _channel.invokeMethod(_ON_GET_ACCOUNT);
  }

  /// Send a single chat message
  Future<String> sendMessage(MIMCMessage message) async{
    assert(message != null);
    return await _channel.invokeMethod(_ON_SEND_MESSAGE, message.toJson());
  }

  /// Send group chat
  /// @ message message body
  /// @ isUnlimitedGroup is Unlimited Group
  Future<String> sendGroupMsg(MIMCMessage message, {bool isUnlimitedGroup = false}) async{
    assert(message != null);
    return await _channel.invokeMethod(_ON_SEND_GROUP_MESSAGE, {
      "message": message.toJson(),
      "isUnlimitedGroup": isUnlimitedGroup
    });
  }

  ///  * create group
  ///  * @param [groupName] group name
  ///  * @param [users] group members，English comma between multiple members(,)Separate
  ///  * @return  Map
  Future<Map<dynamic, dynamic>> createGroup(String groupName, String users) async{
    assert(groupName != null && groupName.isNotEmpty);
    return await _channel.invokeMethod(_ON_CREATE_GROUP, {
      "groupName": groupName,
      "users": users
    });
  }

  ///  * Query specified group information
  ///  * @param [groupId] group ID
  ///  * @return  Map
  Future<Map<dynamic, dynamic>> queryGroupInfo(String groupId) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_GROUP_INFO, {
      "groupId": groupId
    });
  }

  ///  * Query group information
  ///  * @param [groupId] group ID
  ///  * @return  Map
  Future<Map<dynamic, dynamic>> queryGroupsOfAccount() async{
    return await _channel.invokeMethod(_ON_QUERY_GROUP_OF_ACCOUNT);
  }

  ///  * Invite users to join the group
  ///  * @param [groupId] group ID
  ///  * @param [users] Group member，English comma between multiple members(,)Separate
  ///  * @return  Map
  Future<Map<dynamic, dynamic>> joinGroup(String groupId, String users) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_JOIN_GROUP, {
    "groupId": groupId,
    "users": users
    });
  }

  ///  * Non-group master user quit group
  ///  * @param [groupId] group ID
  ///  * @return Map
  Future<Map<dynamic, dynamic>> quitGroup(String groupId) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUIT_GROUP, {
      "groupId": groupId
    });
  }

  ///  * kicks members out of the group
  ///  * @param [groupId] group ID
  /// *  @users [users] Group member，English comma between multiple members(,)Separate
  // * @return Map
  Future<Map<dynamic, dynamic>> kickGroup(String groupId, String users) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_KICK_GROUP, {
      "groupId": groupId,
      "users": users
    });
  }

  ///  * Group owner update group information
  ///  * @param [groupId]  groupID
  ///  * @param [newOwnerAccount] Assign a new owner if it is a group member
  ///  * @param [newGroupName] group name
  ///  * @param [newGroupBulletin] Group announcement
  /// * @return Map
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

  //  * Group destroyer
  //  * @param [groupId] group ID
  //  * @return Map
  Future<Map<dynamic, dynamic>> dismissGroup(String groupId) async{
    assert(groupId != null && groupId.isNotEmpty);
    return await _channel.invokeMethod(_ON_DISMISS_GROUP, {
      "groupId": groupId
    });
  }



  ///   * Pull single chat message record
  ///   * @param toAccount   Receiver account
  ///   * @param fromAccount Sender account
  ///   * @param utcFromTime Starting time
  ///   * @param utcToTime   End Time
  ///  * note：[utcFromTime] And [utcToTimeTime] interval cannot exceed 24 hours，The query status is[utcFromTime,utcToTime)，Unit milliseconds, UTC time
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

  ///  * Pull group chat message record
  ///  * @param [account] Puller account
  ///  * @param [topicId] groupID
  ///  * @param [utcFromTime] Starting time
  ///  * @param [utcToTime] End Time
  ///  * note：[utcFromTime] And [utcToTimeTime] interval cannot exceed 24 hours，The query status is[utcFromTime,utcToTime)，Unit milliseconds, UTC time
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

  ///  * create unlimited group
  ///  * @param [topicName] group name
  Future<dynamic> createUnlimitedGroup(String topicName) async{
    return await _channel.invokeMethod(_ON_CREATE_UNLIMITED_GROUP, {
      "topicName": topicName
    });
  }

  ///  * join unlimited group
  ///  * @param [topicId] group id
  ///  * @return String Client generated message ID
  Future<String> joinUnlimitedGroup(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_JOIN_UNLIMITED_GROUP, {
      "topicId": topicId
    });
  }

  ///  * quit unlimited group
  ///  * @param [topicId] group id
  ///  * @return String Client generated message ID
  Future<String> quitUnlimitedGroup(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUIT_UNLIMITED_GROUP, {
      "topicId": topicId
    });
  }

  ///  * dismiss unlimited group
  ///  * @param [topicId] group id
  Future<dynamic> dismissUnlimitedGroup(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_DISMISS_UNLIMITED_GROUP, {
      "topicId": topicId
    });
  }


  ///  * Query unlimited group members
  ///  * @param [topicId] group id
  Future<Map<dynamic, dynamic>> queryUnlimitedGroupMembers(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUP_MEMBERS, {
      "topicId": topicId
    });
  }

  ///  * Query unlimited groups
  Future<Map<dynamic, dynamic>> queryUnlimitedGroups() async{
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUPS);
  }

  ///  * Query unlimited group of online users
  ///  * @param [topicId] group id
  Future<Map<dynamic, dynamic>> queryUnlimitedGroupOnlineUsers(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUP_ONLINE_USERS, {
      "topicId": topicId
    });
  }

  ///  * Query unlimited group info
  ///  * @param [topicId] group id
  Future<Map<dynamic, dynamic>> queryUnlimitedGroupInfo(String topicId) async{
    assert(topicId != null && topicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_QUERY_UNLIMITED_GROUP_INFO, {
      "topicId": topicId
    });
  }

  ///  * update unlimited group info
  ///  * @param [topicId]
  ///  * @param [newGroupName]
  ///  * @param [newOwnerAccount]
  ///  * update unlimited group info，[topicId]Required, other parameters must be filled in one
  ///  * Owner can transfer，New Owner must be in the group
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

  ///  * get contact
  ///  * @param [isV2] api is v2 version
  Future<Map<dynamic, dynamic>> getContact({bool isV2 = true}) async{
    return await _channel.invokeMethod(_ON_GET_CONTACT, {
      "isV2": isV2
    });
  }

  ///  * set BlackList
  ///  * @param [blackAccount]
  Future<Map<dynamic, dynamic>> setBlackList(String blackAccount) async{
    assert(blackAccount != null && blackAccount.isNotEmpty);
    return await _channel.invokeMethod(_ON_SET_BLACKLIST, {
      "blackAccount": blackAccount
    });
  }

  ///  * delete BlackList
  ///  * @param [blackAccount]
  Future<Map<dynamic, dynamic>> deleteBlackList(String blackAccount) async{
    assert(blackAccount != null && blackAccount.isNotEmpty);
    return await _channel.invokeMethod(_ON_DELETE_BLACKLIST, {
      "blackAccount": blackAccount
    });
  }

  ///  * has BlackList
  ///  * @param [blackAccount]
  Future<Map<dynamic, dynamic>> hasBlackList(String blackAccount) async{
    assert(blackAccount != null && blackAccount.isNotEmpty);
    return await _channel.invokeMethod(_ON_HAS_BLACKLIST, {
      "blackAccount": blackAccount
    });
  }

  ///  * set group BlackList
  ///  * @param [blackAccount]
  ///  * @param [blackTopicId]
  Future<Map<dynamic, dynamic>> setGroupBlackList({String blackAccount, String blackTopicId}) async{
    assert(blackAccount != null && blackAccount.isNotEmpty);
    assert(blackTopicId != null && blackTopicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_SET_GROUP_BLACKLIST, {
      "blackAccount": blackAccount,
      "blackTopicId": blackTopicId,
    });
  }

  ///  * delete group BlackList
  ///  * @param [blackAccount]
  ///  * @param [blackTopicId]
  Future<Map<dynamic, dynamic>> deleteGroupBlackList({String blackAccount, String blackTopicId}) async{
    assert(blackAccount != null && blackAccount.isNotEmpty);
    assert(blackTopicId != null && blackTopicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_DELETE_GROUP_BLACKLIST, {
      "blackAccount": blackAccount,
      "blackTopicId": blackTopicId,
    });
  }

  ///  * has group BlackList
  ///  * @param [blackAccount]
  ///  * @param [blackTopicId]
  Future<Map<dynamic, dynamic>> hasGroupBlackList({String blackAccount, String blackTopicId}) async{
    assert(blackAccount != null && blackAccount.isNotEmpty);
    assert(blackTopicId != null && blackTopicId.isNotEmpty);
    return await _channel.invokeMethod(_ON_HAS_GROUP_BLACKLIST, {
      "blackAccount": blackAccount,
      "blackTopicId": blackTopicId,
    });
  }


  /// eventListener
  void _eventListener(event) {
    String eventType = event['eventType'];
    dynamic eventValue = event['eventValue'];
   switch(eventType){
     case MIMCEvents.onlineStatusListener:
       _onlineStatusListenerStreamController.add(eventValue as bool);
       break;
     case MIMCEvents.onHandleMessage:
       _onHandleMessageStreamController.add(MIMCMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleSendMessageTimeout:
       _onHandleSendMessageTimeoutStreamController.add(MIMCMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleGroupMessage:
       _onHandleGroupMessageStreamController.add(MIMCMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleSendGroupMessageTimeout:
       _onHandleSendGroupMessageTimeoutStreamController.add(MIMCMessage.fromJson(eventValue));
       break;
     case MIMCEvents.onHandleSendUnlimitedGroupMessageTimeout:
       _onHandleSendUnlimitedGroupMessageTimeoutStreamController.add(MIMCMessage.fromJson(eventValue));
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

  /// status change callback
  void removeEventListenerStatusChanged() =>
      _onlineStatusListenerStreamController.close();
  Stream<bool> addEventListenerStatusChanged(){
    return _onlineStatusListenerStreamController.stream;
  }

  /// Receive single chat messages callback
  void removeEventListenerHandleMessage() =>
      _onHandleMessageStreamController.close();
  Stream<MIMCMessage> addEventListenerHandleMessage(){
    return _onHandleMessageStreamController.stream;
  }

  /// Receiving group chat callback
  void removeEventListenerHandleGroupMessage() =>
      _onHandleGroupMessageStreamController.close();
  Stream<MIMCMessage> addEventListenerHandleGroupMessage(){
    return _onHandleGroupMessageStreamController.stream;
  }

  /// The receiving server has received a confirmation message
  void removeEventListenerServerAck() =>
      _onHandleServerAckStreamController.close();
  Stream<MimcServeraAck> addEventListenerServerAck(){
    return _onHandleServerAckStreamController.stream;
  }

  /// Send a single chat message timed out
  void removeEventListenerSendMessageTimeout() =>
      _onHandleSendMessageTimeoutStreamController.close();
  Stream<MIMCMessage> addEventListenerSendMessageTimeout(){
    return _onHandleSendMessageTimeoutStreamController.stream;
  }

  /// Send group chat message timed out
  void removeEventListenerSendGroupMessageTimeout() =>
      _onHandleSendGroupMessageTimeoutStreamController.close();
  Stream<MIMCMessage> addEventListenerSendGroupMessageTimeout(){
    return _onHandleSendGroupMessageTimeoutStreamController.stream;
  }

  /// Send unlimited group chat message timeout
  void removeEventListenerSendUnlimitedGroupMessageTimeout() =>
      _onHandleSendUnlimitedGroupMessageTimeoutStreamController.close();
  Stream<MIMCMessage> addEventListenerSendUnlimitedGroupMessageTimeout(){
    return _onHandleSendUnlimitedGroupMessageTimeoutStreamController.stream;
  }

  /// Create unlimited group callback
  void removeEventListenerHandleCreateUnlimitedGroup() =>
      _onHandleCreateUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleCreateUnlimitedGroup(){
    return _onHandleCreateUnlimitedGroupStreamController.stream;
  }

  /// join unlimited group callback
  void removeEventListenerHandleJoinUnlimitedGroup() =>
      _onHandleJoinUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleJoinUnlimitedGroup(){
    return _onHandleJoinUnlimitedGroupStreamController.stream;
  }

  /// quit unlimited group callback
  void removeEventListenerHandleQuitUnlimitedGroup() =>
      _onHandleQuitUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleQuitUnlimitedGroup(){
    return _onHandleQuitUnlimitedGroupStreamController.stream;
  }

  /// dismiss unlimited group callback
  void removeEventListenerHandleDismissUnlimitedGroup() =>
      _onHandleDismissUnlimitedGroupStreamController.close();
  Stream<Map<dynamic, dynamic>> addEventListenerHandleDismissUnlimitedGroup(){
    return _onHandleDismissUnlimitedGroupStreamController.stream;
  }



  /// event error
  void _errorListener(Object obj) {
    final PlatformException e = obj;
    debugPrint("eventError===$obj");
    throw e;
  }



}

