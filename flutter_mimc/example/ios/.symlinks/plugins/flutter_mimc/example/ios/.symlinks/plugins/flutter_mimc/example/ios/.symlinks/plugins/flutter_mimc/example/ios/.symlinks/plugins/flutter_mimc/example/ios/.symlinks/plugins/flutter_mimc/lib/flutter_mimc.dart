import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'model/mimc_message.dart';
import 'model/mimc_response.dart';
import 'model/mimc_servera_ack.dart';
import 'services/enums.dart';
import 'services/mimc_services.dart';

export 'model/mimc_message.dart';
export 'model/mimc_servera_ack.dart';
export 'services/enums.dart';
export 'model/mimc_response.dart';
export 'services/mimc_services.dart';
export 'push/mimc_push.dart';

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
  static const String onPullNotification =
      "onPullNotification"; // onPullNotification
  static const String onHandleOnlineMessageAck =
      "onHandleOnlineMessageAck"; // send Feedback callback for online messages
  static const String onHandleOnlineMessage =
      "onHandleOnlineMessage"; // Receive Feedback callback for online messages
}

class FlutterMIMC {
  MIMCServices services;

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

  /// onPullNotification callbacks
  final StreamController<bool> _onPullNotificationStreamController =
      StreamController<bool>.broadcast();

  // send Feedback callback for online messages callbacks
  final StreamController<MimcServeraAck>
      _onHandleOnlineMessageAckStreamController =
      StreamController<MimcServeraAck>.broadcast();

  // Receive Feedback callback for online messages callbacks
  final StreamController<MIMCMessage> _onHandleOnlineMessageStreamController =
      StreamController<MIMCMessage>.broadcast();

  /// initMImcInvokeMethod
  void _initMImcInvokeMethod(String tokenString, {bool debug = false}) {
    _channel.invokeMethod(
        _ON_INIT, {"token": tokenString, "debug": debug}).then((_) async {
      _initEvent();
      String _token = await getToken();
      String _appId = await getAppId();
      services = MIMCServices(_token, _appId);
    });
  }

  ///  init
  ///  [appId]   String        application ID，Xiaomi open platform application for distribution    appId
  ///  [appKey]  String appKey       application appKey，Xiaomi open platform application for distribution appKey
  ///  [appSecret] String appSecret    application appKey，Xiaomi open platform application for distribution appSecret
  ///  [appAccount] String appAccount   Session account（business platform unique ID）
  FlutterMIMC.init(
      {bool debug = false,
      String appId,
      String appKey,
      String appSecret,
      String appAccount}) {
    assert(appId != null && appId.isNotEmpty);
    assert(appKey != null && appKey.isNotEmpty);
    assert(appSecret != null && appSecret.isNotEmpty);
    assert(appAccount != null && appAccount.isNotEmpty);
    MIMCServices.registerToken(
            appId: appId,
            appKey: appKey,
            appAccount: appAccount,
            appSecret: appSecret)
        .then((res) {
      _initMImcInvokeMethod(jsonEncode(res), debug: debug);
    });
  }

  ///  * init
  ///  * String tokenString  Obtained by server signature
  FlutterMIMC.stringTokenInit(String tokenString, {bool debug = false}) {
    assert(tokenString != null && tokenString.isNotEmpty);
    _initMImcInvokeMethod(tokenString, debug: debug);
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

  /// create group
  /// [groupName] group name
  /// [users] group members，"1,2,3"
  /// [extra] extra
  Future<MIMCResponse> createGroup(
      {String topicName, String accounts, String extra}) async {
    assert(topicName != null && topicName.isNotEmpty);
    return await services.createGroup(
        topicName: topicName, accounts: accounts, extra: extra);
  }

  /// Query specified group information
  /// [groupId] group ID
  Future<MIMCResponse> queryGroupInfo(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.queryGroupInfo(topicId: topicId);
  }

  /// Query group information
  Future<MIMCResponse> queryGroupsOfAccount() async {
    return await services.queryGroupsOfAccount();
  }

  /// Invite users to join the group
  /// [topicId] group ID
  /// [accounts] Group member，English comma between multiple members(,)Separate
  Future<MIMCResponse> joinGroup({String topicId, String accounts}) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.joinGroup(topicId: topicId, accounts: accounts);
  }

  /// Non-group master user quit group
  /// [topicId] group ID
  Future<MIMCResponse> quitGroup(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.quitGroup(topicId: topicId);
  }

  /// kicks members out of the group
  /// [topicId] group ID
  /// [accounts] Group member "1,2,3"
  Future<MIMCResponse> kickGroup(String topicId, String accounts) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.kickGroup(topicId: topicId, accounts: accounts);
  }

  /// Group owner update group information
  /// [topicId]  groupID
  /// [ownerAccount] Assign a new owner if it is a group member
  /// [topicName] group name
  /// [bulletin] Group announcement
  /// [extra] Group extra
  Future<MIMCResponse> updateGroup({
    String topicId,
    String ownerAccount,
    String topicName,
    String bulletin,
    String extra,
  }) async {
    assert(topicId != null);
    return await services.updateGroup(
      topicId: topicId,
      ownerAccount: ownerAccount,
      topicName: topicName,
      bulletin: bulletin,
      extra: extra,
    );
  }

  //  dismissGroup
  //  [groupId] group ID
  Future<MIMCResponse> dismissGroup(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.dismissGroup(topicId: topicId);
  }

  /// pullP2PHistory single chat message record
  /// [toAccount]   Receiver account
  /// [fromAccount] Sender account
  /// [utcFromTime] Starting time
  /// [utcToTime]   End Time
  /// [count]       message rows default 20
  /// [bizType]     type
  /// [extra]       extra
  /// [getAllExtra] getAllExtra
  /// [extraFilterMap]   extraFilterMap
  /// [startSeq]   startSeq
  /// [stopSeq]   stopSeq
  ///   * note：[utcFromTime] And [utcToTimeTime] interval cannot exceed 24 hours，The query status is[utcFromTime,utcToTime)，Unit milliseconds, UTC time
  Future<MIMCResponse> pullP2PHistory(
    PullHistoryType pullHistoryType, {
    String toAccount,
    String fromAccount,
    String utcFromTime,
    String utcToTime,
    int count = 20,
    String bizType = "",
    String extra = "",
    bool getAllExtra = false,
    Map<String, dynamic> extraFilterMap,
    String startSeq,
    String stopSeq,
  }) async {
    assert(pullHistoryType != null);
    assert(toAccount != null && toAccount.isNotEmpty);
    assert(fromAccount != null && fromAccount.isNotEmpty);
    assert(utcFromTime != null && utcFromTime.isNotEmpty);
    assert(utcToTime != null && utcToTime.isNotEmpty);
    return await services.pullP2PHistory(
      pullHistoryType: pullHistoryType,
      toAccount: toAccount,
      fromAccount: fromAccount,
      utcFromTime: utcFromTime,
      utcToTime: utcToTime,
      bizType: bizType,
      extra: extra,
      count: count,
      getAllExtra: getAllExtra,
      extraFilterMap: extraFilterMap,
      startSeq: startSeq,
      stopSeq: stopSeq,
    );
  }

  /// pullP2THistory group chat message record
  /// [account] Puller account
  /// [topicId] groupID
  /// [utcFromTime] Starting time
  /// [utcToTime] End Time
  /// [count]       message rows default 20
  /// [bizType]     type
  /// [extra]       extra
  /// [getAllExtra] getAllExtra
  /// [extraFilterMap]   extraFilterMap
  /// [startSeq]   startSeq
  /// [stopSeq]   stopSeq
  ///  * note：[utcFromTime] And [utcToTimeTime] interval cannot exceed 24 hours，The query status is[utcFromTime,utcToTime)，Unit milliseconds, UTC time
  Future<MIMCResponse> pullP2THistory(
    PullHistoryType pullHistoryType, {
    String account,
    String topicId,
    String utcFromTime,
    String utcToTime,
    int count = 20,
    String bizType = "",
    String extra = "",
    bool getAllExtra = false,
    Map<String, dynamic> extraFilterMap,
    String startSeq,
    String stopSeq,
  }) async {
    assert(account != null && account.isNotEmpty);
    assert(topicId != null && topicId.isNotEmpty);
    assert(utcFromTime != null && utcFromTime.isNotEmpty);
    assert(utcToTime != null && utcToTime.isNotEmpty);
    return await services.pullP2THistory(
      pullHistoryType: pullHistoryType,
      account: account,
      topicId: topicId,
      utcFromTime: utcFromTime,
      utcToTime: utcToTime,
      bizType: bizType,
      extra: extra,
      count: count,
      getAllExtra: getAllExtra,
      extraFilterMap: extraFilterMap,
      startSeq: startSeq,
      stopSeq: stopSeq,
    );
  }

  /// pullP2UHistory group chat message record
  /// [account] Puller account
  /// [topicId] groupID
  /// [utcFromTime] Starting time
  /// [utcToTime] End Time
  /// [count]       message rows default 20
  /// [bizType]     type
  /// [extra]       extra
  ///  * note：[utcFromTime] And [utcToTimeTime] interval cannot exceed 24 hours，The query status is[utcFromTime,utcToTime)，Unit milliseconds, UTC time
  Future<MIMCResponse> pullP2UHistory(PullHistoryType pullHistoryType,
      {String account,
      String topicId,
      String utcFromTime,
      String utcToTime,
      int count = 20,
      String bizType = "",
      String extra = ""}) async {
    assert(account != null && account.isNotEmpty);
    assert(topicId != null && topicId.isNotEmpty);
    assert(utcFromTime != null && utcFromTime.isNotEmpty);
    assert(utcToTime != null && utcToTime.isNotEmpty);
    return await services.pullP2UHistory(
        pullHistoryType: pullHistoryType,
        account: account,
        topicId: topicId,
        utcFromTime: utcFromTime,
        utcToTime: utcToTime,
        bizType: bizType,
        extra: extra,
        count: count);
  }

  /// updatePullP2PExtra update pullP2P extra
  /// [toAccount]   Receiver account
  /// [fromAccount] Sender account
  /// [extra]       extra
  /// [sequence]   sequence
  Future<MIMCResponse> updatePullP2PExtra(
      {bool isMultiUpdate = false,
      Map<String, dynamic> sequenceExtraMap,
      String toAccount,
      String fromAccount,
      String extra,
      String sequence}) async {
    assert(toAccount != null && toAccount.isNotEmpty);
    assert(fromAccount != null && fromAccount.isNotEmpty);
    return await services.updatePullP2PExtra(
      isMultiUpdate: isMultiUpdate,
      sequenceExtraMap: sequenceExtraMap,
      toAccount: toAccount,
      fromAccount: fromAccount,
      extra: extra,
      sequence: sequence,
    );
  }

  /// updatePullP2PExtraV2 update pullP2P extra v2
  /// [toAccount]   Receiver account
  /// [fromAccount] Sender account
  /// [extraKey]    extraKey
  /// [extraValue]  extraValue
  /// [sequence]   sequence
  Future<MIMCResponse> updatePullP2PExtraV2({
    String toAccount,
    String fromAccount,
    String sequence,
    String extraKey,
    String extraValue,
  }) async {
    assert(toAccount != null && toAccount.isNotEmpty);
    assert(fromAccount != null && fromAccount.isNotEmpty);
    return await services.updatePullP2PExtraV2(
        toAccount: toAccount,
        fromAccount: fromAccount,
        sequence: sequence,
        extraKey: extraKey,
        extraValue: extraValue);
  }

  /// update Multi extra pullP2P
  /// [toAccount]   Receiver account
  /// [fromAccount] Sender account
  /// [extraKeyMap]  extraKeyMap
  /// [sequence]   sequence
  Future<MIMCResponse> updatePullP2PMultiExtra({
    String toAccount,
    String fromAccount,
    String sequence,
    Map<String, String> extraKeyMap,
  }) async {
    assert(toAccount != null && toAccount.isNotEmpty);
    assert(fromAccount != null && fromAccount.isNotEmpty);
    return await services.updatePullP2PMultiExtra(
        toAccount: toAccount,
        fromAccount: fromAccount,
        sequence: sequence,
        extraKeyMap: extraKeyMap);
  }

  /// updatePullP2TExtra update pullP2T extra
  /// [account]   account
  /// [topicId]   topicId
  /// [extra]     extra
  /// [sequence]   sequence
  Future<MIMCResponse> updatePullP2TExtra(
      {bool isMultiUpdate = false,
      Map<String, dynamic> sequenceExtraMap,
      String account,
      String topicId,
      String extra,
      String sequence}) async {
    assert(account != null && account.isNotEmpty);
    assert(topicId != null && topicId.isNotEmpty);
    return await services.updatePullP2TExtra(
      isMultiUpdate: isMultiUpdate,
      sequenceExtraMap: sequenceExtraMap,
      account: account,
      topicId: topicId,
      extra: extra,
      sequence: sequence,
    );
  }

  /// updatePullP2TExtraV2 update pullP2T extra v2
  /// [account]   account
  /// [topicId]   topicId
  /// [extraValue]  extraValue
  /// [sequence]   sequence
  /// [extraKey]   extraKey
  Future<MIMCResponse> updatePullP2TExtraV2(
      {bool isMultiUpdate = false,
      Map<String, dynamic> sequenceExtraMap,
      String account,
      String topicId,
      String extraKey,
      String extraValue,
      String sequence}) async {
    assert(account != null && account.isNotEmpty);
    assert(topicId != null && topicId.isNotEmpty);
    return await services.updatePullP2TExtraV2(
      account: account,
      topicId: topicId,
      extraKey: extraKey,
      extraValue: extraValue,
      sequence: sequence,
    );
  }

  /// create unlimited group
  /// [topicName] group name
  /// [extra] group extra
  Future<MIMCResponse> createUnlimitedGroup(
      {String topicName, String extra}) async {
    return await services.createUnlimitedGroup(
        topicName: topicName, extra: extra);
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

  /// Query unlimited group members
  /// [topicId] group id
  Future<MIMCResponse> queryUnlimitedGroupMembers(
      {String topicId, String startUuid = "0"}) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.queryUnlimitedGroupMembers(
        topicId: topicId, startUuid: startUuid);
  }

  ///  Query unlimited groups
  Future<MIMCResponse> queryUnlimitedGroups() async {
    return await services.queryUnlimitedGroups();
  }

  /// Query unlimited group of online users
  /// [topicId] group id
  Future<MIMCResponse> queryUnlimitedGroupOnlineUsers(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.queryUnlimitedGroupOnlineUsers(topicId: topicId);
  }

  /// Query unlimited group info
  /// [topicId] group id
  Future<MIMCResponse> queryUnlimitedGroupInfo(String topicId) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.queryUnlimitedGroupInfo(topicId: topicId);
  }

  /// delete unlimited group
  /// [topicId] group id
  Future<MIMCResponse> deleteUnlimitedGroup({String topicId}) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.deleteUnlimitedGroup(topicId: topicId);
  }

  /// update unlimited group info
  /// [topicId]
  /// [newGroupName]
  /// [newOwnerAccount]
  ///  * update unlimited group info，[topicId]Required, other parameters must be filled in one
  ///  * Owner can transfer，New Owner must be in the group
  Future<MIMCResponse> updateUnlimitedGroup(
      {String topicId,
      String topicName,
      String ownerAccount,
      String extra}) async {
    assert(topicId != null && topicId.isNotEmpty);
    return await services.updateUnlimitedGroup(
      topicId: topicId,
      topicName: topicName,
      ownerAccount: ownerAccount,
      extra: extra,
    );
  }

  ///  get contact
  ///  [isV2] api is v2 version
  Future<MIMCResponse> getContact({bool isV2 = true}) async {
    return await services.getContact(isV2: isV2);
  }

  ///  updateContactP2PExtra
  ///  [account] account
  ///  [extra] extra
  Future<MIMCResponse> updateContactP2PExtra({
    String account,
    String extra,
  }) async {
    assert(account != null);
    return await services.updateContactP2PExtra(account: account, extra: extra);
  }

  /// updateContactP2TExtra
  ///  [topicId] topicId
  ///  [extra] extra
  Future<MIMCResponse> updateContactP2TExtra({
    String topicId,
    String extra,
  }) async {
    return await services.updateContactP2TExtra(topicId: topicId, extra: extra);
  }

  ///  set BlackList
  ///  [blackAccount] user account
  Future<MIMCResponse> setBlackList(String blackAccount) async {
    assert(blackAccount != null && blackAccount.isNotEmpty);
    return await services.setBlackList(blackAccount: blackAccount);
  }

  /// delete BlackList
  /// [blackAccount] user account
  Future<MIMCResponse> deleteBlackList(String blackAccount) async {
    assert(blackAccount != null && blackAccount.isNotEmpty);
    return await services.deleteBlackList(
      blackAccount: blackAccount,
    );
  }

  /// has BlackList
  /// [blackAccount] user account
  Future<MIMCResponse> hasBlackList(String blackAccount) async {
    assert(blackAccount != null && blackAccount.isNotEmpty);
    return await services.hasBlackList(
      blackAccount: blackAccount,
    );
  }

  /// set group BlackList
  /// [blackAccount]
  /// [blackTopicId]
  Future<MIMCResponse> setGroupBlackList(
      {String blackAccount, String blackTopicId}) async {
    assert(blackAccount != null && blackAccount.isNotEmpty);
    assert(blackTopicId != null && blackTopicId.isNotEmpty);
    return await services.setGroupBlackList(
      blackAccount: blackAccount,
      blackTopicId: blackTopicId,
    );
  }

  ///  delete group BlackList
  ///  [blackAccount]
  ///  [blackTopicId]
  Future<MIMCResponse> deleteGroupBlackList(
      {String blackAccount, String blackTopicId}) async {
    assert(blackAccount != null && blackAccount.isNotEmpty);
    assert(blackTopicId != null && blackTopicId.isNotEmpty);
    return await services.deleteGroupBlackList(
      blackAccount: blackAccount,
      blackTopicId: blackTopicId,
    );
  }

  ///  has group BlackList
  ///  [blackAccount]
  ///  [blackTopicId]
  Future<MIMCResponse> hasGroupBlackList(
      {String blackAccount, String blackTopicId}) async {
    assert(blackAccount != null && blackAccount.isNotEmpty);
    assert(blackTopicId != null && blackTopicId.isNotEmpty);
    return await services.hasGroupBlackList(
      blackAccount: blackAccount,
      blackTopicId: blackTopicId,
    );
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
      case MIMCEvents.onPullNotification:
        _onPullNotificationStreamController.add(true);
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

  /// onPullNotification
  void removeEventListenerHandlePullNotification() =>
      _onPullNotificationStreamController.close();

  Stream<bool> addEventListenerHandlePullNotification() {
    return _onPullNotificationStreamController.stream;
  }

  /// event error
  void _errorListener(Object obj) {
    final PlatformException e = obj;
    debugPrint("eventError===$obj");
    throw e;
  }
}
