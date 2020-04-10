import 'package:dio/dio.dart';
import 'package:flutter_mimc/model/mimc_response.dart';
import 'enums.dart';

/// MIMCServices
/// Undertake the business of http api
class MIMCServices {
  Dio _http;
  String _mImcAppId;
  String _mImcToken;
  static const String _domain = "https://mimc.chat.xiaomi.net";

  MIMCServices(this._mImcToken, this._mImcAppId) {
    BaseOptions options = new BaseOptions(
        baseUrl: _domain,
        connectTimeout: 10000,
        receiveTimeout: 5000,
        headers: {
          "Accept": "application/json;charset=UTF-8",
          "Content-Type": "application/json;charset=UTF-8",
          "token": _mImcToken
        });
    _http = Dio(options);
  }

  // remove empty key
  Map<String, dynamic> removeMapNullValueKey(Map<String, dynamic> json) {
    json.removeWhere((key, value) => value == null || value == "");
    return json;
  }

  /// pullP2PHistory
  Future<MIMCResponse> pullP2PHistory({
    PullHistoryType pullHistoryType,
    String toAccount,
    String fromAccount,
    String utcFromTime,
    String utcToTime,
    String bizType,
    String extra,
    int count,
    Map<String, dynamic> extraFilterMap,
    bool getAllExtra,
    String startSeq,
    String stopSeq,
  }) async {
    String api = _domain;
    switch (pullHistoryType) {
      case PullHistoryType.queryOnTime:
        api += '/api/msg/p2p/queryOnTime/';
        break;
      case PullHistoryType.queryOnCount:
        api += '/api/msg/p2p/queryOnCount/';
        break;
      case PullHistoryType.queryOnCountV2:
        api += '/api/msg/p2p/queryOnCount/v2/';
        break;
      case PullHistoryType.queryOnSequence:
        api += '/api/msg/p2p/queryOnSequence/';
        break;
    }
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "toAccount": toAccount,
          "fromAccount": fromAccount,
          "utcFromTime": utcFromTime,
          "utcToTime": utcToTime,
          "bizType": bizType,
          "extra": extra,
          "count": count,
          "extraFilterMap": extraFilterMap,
          "getAllExtra": getAllExtra,
          "startSeq": startSeq,
          "stopSeq": stopSeq,
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// pullP2THistory
  Future<MIMCResponse> pullP2THistory({
    PullHistoryType pullHistoryType,
    String account,
    String topicId,
    String utcFromTime,
    String utcToTime,
    String bizType,
    String extra,
    int count,
    Map<String, dynamic> extraFilterMap,
    bool getAllExtra,
    String startSeq,
    String stopSeq,
  }) async {
    String api = _domain;
    switch (pullHistoryType) {
      case PullHistoryType.queryOnTime:
        api += '/api/msg/p2t/queryOnTime/';
        break;
      case PullHistoryType.queryOnCount:
        api += '/api/msg/p2t/queryOnCount/';
        break;
      case PullHistoryType.queryOnCountV2:
        api += '/api/msg/p2t/queryOnCount/v2/';
        break;
      case PullHistoryType.queryOnSequence:
        api += '/api/msg/p2t/queryOnSequence/';
        break;
    }
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "account": account,
          "topicId": topicId,
          "utcFromTime": utcFromTime,
          "utcToTime": utcToTime,
          "bizType": bizType,
          "extra": extra,
          "count": count,
          "extraFilterMap": extraFilterMap,
          "getAllExtra": getAllExtra,
          "startSeq": startSeq,
          "stopSeq": stopSeq,
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// pullP2UHistory
  Future<MIMCResponse> pullP2UHistory({
    PullHistoryType pullHistoryType,
    String account,
    String topicId,
    String utcFromTime,
    String utcToTime,
    String bizType,
    String extra,
    int count,
  }) async {
    String api = _domain;
    switch (pullHistoryType) {
      case PullHistoryType.queryOnTime:
        api += '/api/msg/p2u/queryOnTime/';
        break;
      case PullHistoryType.queryOnCount:
        api += '/api/msg/p2u/queryOnCount/';
        break;
      case PullHistoryType.queryOnCountV2:
      case PullHistoryType.queryOnSequence:
        return MIMCResponse(code: 400, message: "not fund api", data: null);
        break;
    }
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "account": account,
          "topicId": topicId,
          "utcFromTime": utcFromTime,
          "utcToTime": utcToTime,
          "bizType": bizType,
          "extra": extra,
          "count": count
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// update pullP2P extra
  Future<MIMCResponse> updatePullP2PExtra({
    String toAccount,
    String fromAccount,
    String sequence,
    String extra,
    bool isMultiUpdate,
    Map<String, dynamic> sequenceExtraMap,
  }) async {
    String api;
    if (isMultiUpdate) {
      api = _domain + "/api/msg/p2p/extra/multiupdate/";
      if (sequenceExtraMap == null) {
        return MIMCResponse(
            code: 400, message: "sequenceExtraMap is require", data: null);
      }
    } else {
      api = _domain + "/api/msg/p2p/extra/update/";
    }
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "toAccount": toAccount,
          "fromAccount": fromAccount,
          "extra": extra,
          "sequence": sequence,
          "sequenceExtraMap": sequenceExtraMap
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// update pullP2P extraV2
  Future<MIMCResponse> updatePullP2PExtraV2({
    String toAccount,
    String fromAccount,
    String sequence,
    String extraKey,
    String extraValue,
  }) async {
    String api = _domain + "/api/msg/p2p/extra/update/v2/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "toAccount": toAccount,
          "fromAccount": fromAccount,
          "sequence": sequence,
          "extraKey": extraKey,
          "extraValue": extraValue
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// update Multi extra pullP2P
  Future<MIMCResponse> updatePullP2PMultiExtra({
    String toAccount,
    String fromAccount,
    String sequence,
    Map<String, String> extraKeyMap,
  }) async {
    String api = _domain + "/api/msg/p2p/extra/batchupdate/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "toAccount": toAccount,
          "fromAccount": fromAccount,
          "sequence": sequence,
          "extraKeyMap": extraKeyMap
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// update pullP2T extra
  Future<MIMCResponse> updatePullP2TExtra({
    String account,
    String topicId,
    String sequence,
    String extra,
    bool isMultiUpdate = false,
    Map<String, dynamic> sequenceExtraMap,
  }) async {
    String api;
    if (isMultiUpdate) {
      api = _domain + "/api/msg/p2t/extra/multiupdate/";
      if (sequenceExtraMap == null) {
        return MIMCResponse(
            code: 400, message: "sequenceExtraMap is require", data: null);
      }
    } else {
      api = _domain + "/api/msg/p2t/extra/update/";
    }
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "account": account,
          "topicId": topicId,
          "extra": extra,
          "sequence": sequence,
          "sequenceExtraMap": sequenceExtraMap
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// update pullP2T extra v2
  Future<MIMCResponse> updatePullP2TExtraV2({
    String account,
    String topicId,
    String sequence,
    String extra,
    String extraKey,
    String extraValue,
  }) async {
    String api = _domain + "/api/msg/p2t/extra/update/v2/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "account": account,
          "topicId": topicId,
          "extra": extra,
          "sequence": sequence,
          "extraKey": extraKey,
          "extraValue": extraValue
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// update Multi extra pullP2T
  Future<MIMCResponse> updatePullP2TMultiExtra({
    String account,
    String topicId,
    String sequence,
    Map<String, String> extraKeyMap,
  }) async {
    String api = _domain + "/api/msg/p2t/extra/batchupdate/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "account": account,
          "topicId": topicId,
          "sequence": sequence,
          "extraKeyMap": extraKeyMap
        }));
    return MIMCResponse.fromJson(response.data);
  }

  /// getContact
  Future<MIMCResponse> getContact({
    bool isV2,
  }) async {
    String api = _domain + (isV2 ? "/api/contact/v2/" : "/api/contact/");
    Response response = await _http.get(api);
    return MIMCResponse.fromJson(response.data);
  }

  /// update Contact p2p extra
  Future<MIMCResponse> updateContactP2PExtra({
    String account,
    String extra,
  }) async {
    String api = _domain + "/api/contact/p2p/extra/update/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey({"account": account, "extra": extra}));
    return MIMCResponse.fromJson(response.data);
  }

  /// update Contact p2t extra
  Future<MIMCResponse> updateContactP2TExtra({
    String topicId,
    String extra,
  }) async {
    String api = _domain + "/api/contact/p2t/extra/update/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey({"topicId": topicId, "extra": extra}));
    return MIMCResponse.fromJson(response.data);
  }

  /// create group
  Future<MIMCResponse> createGroup(
      {String topicName, String accounts, String extra}) async {
    String api = _domain + "/api/topic/$_mImcAppId/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey(
            {"topicName": topicName, "accounts": accounts, "extra": extra}));
    return MIMCResponse.fromJson(response.data);
  }

  ///  Query specified group information
  Future<MIMCResponse> queryGroupInfo({String topicId}) async {
    String api = _domain + "/api/topic/$_mImcAppId/$topicId";
    Response response = await _http.get(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  Query group information
  Future<MIMCResponse> queryGroupsOfAccount() async {
    String api = _domain + "/api/topic/$_mImcAppId/account/";
    Response response = await _http.get(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  joinGroup
  Future<MIMCResponse> joinGroup({String topicId, String accounts}) async {
    String api = _domain + "/api/topic/$_mImcAppId/$topicId/accounts/";
    Response response = await _http.post(api, data: {"accounts": accounts});
    return MIMCResponse.fromJson(response.data);
  }

  ///  dismissGroup
  Future<MIMCResponse> dismissGroup({String topicId}) async {
    String api = _domain + "/api/topic/$_mImcAppId/$topicId/";
    Response response = await _http.delete(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  quitGroup
  Future<MIMCResponse> quitGroup({String topicId}) async {
    String api = _domain + "/api/topic/$_mImcAppId/$topicId/account/";
    Response response = await _http.delete(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  kickGroup
  Future<MIMCResponse> kickGroup({String topicId, accounts}) async {
    String api =
        _domain + "/api/topic/$_mImcAppId/$topicId/accounts?accounts=$accounts";
    Response response = await _http.delete(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  updateGroup
  Future<MIMCResponse> updateGroup({
    String topicId,
    String ownerAccount,
    String topicName,
    String bulletin,
    String extra,
  }) async {
    String api = _domain + "/api/topic/$_mImcAppId/$topicId/";
    Response response = await _http.put(api,
        data: removeMapNullValueKey({
          "ownerAccount": ownerAccount,
          "topicName": topicName,
          "bulletin": bulletin,
          "extra": extra,
        }));
    return MIMCResponse.fromJson(response.data);
  }

  ///  createUnlimitedGroup
  Future<MIMCResponse> createUnlimitedGroup({
    String topicName,
    String extra,
  }) async {
    String api = _domain + "/api/uctopic/";
    Response response = await _http.post(api,
        data: removeMapNullValueKey({
          "topicName": topicName,
          "extra": extra,
        }));
    return MIMCResponse.fromJson(response.data);
  }

  ///  queryUnlimitedGroupMembers
  Future<MIMCResponse> queryUnlimitedGroupMembers(
      {String topicId, String startUuid}) async {
    String api = _domain + "/api/uctopic/userlist/";
    Response response = await _http.get(api,
        options: Options(headers: {
          "topicId": topicId,
          "startUuid": startUuid,
        }));
    return MIMCResponse.fromJson(response.data);
  }

  ///  queryUnlimitedGroupOnlineUsers
  Future<MIMCResponse> queryUnlimitedGroupOnlineUsers({String topicId}) async {
    String api = _domain + "/api/uctopic/onlineinfo/";
    Response response =
        await _http.get(api, options: Options(headers: {"topicId": topicId}));
    return MIMCResponse.fromJson(response.data);
  }

  ///  queryUnlimitedGroupInfo
  Future<MIMCResponse> queryUnlimitedGroupInfo({String topicId}) async {
    String api = _domain + "/api/uctopic/topic/";
    Response response =
        await _http.get(api, options: Options(headers: {"topicId": topicId}));
    return MIMCResponse.fromJson(response.data);
  }

  ///  updateUnlimitedGroup
  Future<MIMCResponse> updateUnlimitedGroup({
    String topicId,
    String topicName,
    String ownerAccount,
    String extra,
  }) async {
    String api = _domain + "/api/uctopic/update/";
    Response response = await _http.post(api, data: {
      "topicId": topicId,
      "topicName": topicName,
      "ownerAccount": ownerAccount,
      "extra": extra,
    });
    return MIMCResponse.fromJson(response.data);
  }

  ///  queryUnlimitedGroups
  Future<MIMCResponse> queryUnlimitedGroups() async {
    String api = _domain + "/api/uctopic/topics/";
    Response response = await _http.get(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  deleteUnlimitedGroup
  Future<MIMCResponse> deleteUnlimitedGroup({String topicId}) async {
    String api = _domain + "/api/uctopic/";
    Response response = await _http.delete(api,
        options: Options(headers: {"topicId": topicId}));
    return MIMCResponse.fromJson(response.data);
  }

  ///  setBlackList
  Future<MIMCResponse> setBlackList({String blackAccount}) async {
    String api = _domain + "/api/blacklist/";
    Response response =
        await _http.post(api, data: {"blackAccount": blackAccount});
    return MIMCResponse.fromJson(response.data);
  }

  ///  deleteBlackList
  Future<MIMCResponse> deleteBlackList({String blackAccount}) async {
    String api = _domain + "/api/blacklist/?blackAccount=$blackAccount";
    Response response = await _http.delete(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  hasBlackList
  Future<MIMCResponse> hasBlackList({String blackAccount}) async {
    String api = _domain + "/api/blacklist/?blackAccount=$blackAccount";
    Response response = await _http.get(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  setGroupBlackList
  Future<MIMCResponse> setGroupBlackList(
      {String blackAccount, String blackTopicId}) async {
    String api = _domain + "/api/topicblacklist/";
    Response response = await _http.post(api,
        data: {"blackAccount": blackAccount, "blackTopicId": blackTopicId});
    return MIMCResponse.fromJson(response.data);
  }

  ///  deleteGroupBlackList
  Future<MIMCResponse> deleteGroupBlackList(
      {String blackAccount, String blackTopicId}) async {
    String api = _domain +
        "/api/topicblacklist/$blackTopicId/blackAccount?blackAccount=$blackAccount/";
    Response response = await _http.delete(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  hasGroupBlackList
  Future<MIMCResponse> hasGroupBlackList(
      {String blackAccount, String blackTopicId}) async {
    String api = _domain +
        "/api/topicblacklist/$blackTopicId/blackAccount?blackAccount=$blackAccount";
    Response response = await _http.get(api);
    return MIMCResponse.fromJson(response.data);
  }

  ///  registerToken
  static Future<MIMCResponse> registerToken(
      {String appId,
      String appKey,
      String appSecret,
      String appAccount}) async {
    assert(appAccount != null);
    assert(appSecret != null);
    assert(appKey != null);
    assert(appId != null);
    String api = _domain + "/api/account/token/";
    Response response = await Dio().post(api, data: {
      "appId": appId,
      "appKey": appKey,
      "appSecret": appSecret,
      "appAccount": appAccount,
    });
    return MIMCResponse.fromJson(response.data);
  }
}
