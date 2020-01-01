import 'package:dio/dio.dart';
import 'package:flutter_mimc/model/mimc_response.dart';
import '../services/enums.dart';

/// MIMCPush
class MIMCPush {
  Dio _http;
  final String mImcAppId;
  final String mImcAppKey;
  final String mImcAppSecret;
  static const String _domain = "https://mimc.chat.xiaomi.net";

  MIMCPush({this.mImcAppId, this.mImcAppKey, this.mImcAppSecret}) {
    assert(mImcAppId != null);
    assert(mImcAppKey != null);
    assert(mImcAppSecret != null);
    BaseOptions options = new BaseOptions(
        baseUrl: _domain,
        connectTimeout: 10000,
        receiveTimeout: 5000,
        headers: {
          "Accept": "application/json;charset=UTF-8",
          "Content-Type": "application/json;charset=UTF-8",
        });
    _http = Dio(options);
  }

  /// push p2p
  Future<MIMCResponse> pushP2PMessage(
      {String fromAccount,
      String toAccount,
      String fromResource,
      String msg,
      String msgType,
      bool isStore = false,
      String bizType}) async {
    assert(fromResource != null);
    assert(msg != null);
    assert(toAccount != null);
    assert(fromAccount != null);
    String api = _domain + "/api/push/p2p/";
    Response response = await _http.post(api, data: {
      "appId": mImcAppId,
      "appKey": mImcAppKey,
      "appSecret": mImcAppSecret,
      "fromAccount": fromAccount,
      "toAccount": toAccount,
      "fromResource": fromResource,
      "msg": msg,
      "msgType": msgType,
      "isStore": isStore,
      "bizType": bizType
    });
    return MIMCResponse.fromJson(response.data);
  }

  /// push p2p more
  Future<MIMCResponse> pushP2PMoreMessage(
      {String fromAccount,
      List<String> toAccounts,
      String fromResource,
      String msg,
      String msgType,
      bool isStore = false,
      String bizType}) async {
    assert(fromResource != null);
    assert(msg != null);
    assert(toAccounts != null);
    assert(fromAccount != null);
    String api = _domain + "/api/push/p2p/more/";
    Response response = await _http.post(api, data: {
      "appId": mImcAppId,
      "appKey": mImcAppKey,
      "appSecret": mImcAppSecret,
      "fromAccount": fromAccount,
      "toAccounts": toAccounts,
      "fromResource": fromResource,
      "msg": msg,
      "msgType": msgType,
      "isStore": isStore,
      "bizType": bizType
    });
    return MIMCResponse.fromJson(response.data);
  }

  /// push p2t
  Future<MIMCResponse> pushP2TMessage(
      {String fromAccount,
      String topicId,
      String fromResource,
      String msg,
      String msgType,
      bool isStore = false,
      String bizType}) async {
    assert(fromResource != null);
    assert(msg != null);
    assert(topicId != null);
    assert(fromAccount != null);
    String api = _domain + "/api/push/p2t/";
    Response response = await _http.post(api, data: {
      "appId": mImcAppId,
      "appKey": mImcAppKey,
      "appSecret": mImcAppSecret,
      "fromAccount": fromAccount,
      "topicId": topicId,
      "fromResource": fromResource,
      "msg": msg,
      "msgType": msgType,
      "isStore": isStore,
      "bizType": bizType
    });
    return MIMCResponse.fromJson(response.data);
  }

  /// push p2t more
  Future<MIMCResponse> pushP2TMoreMessage(
      {String fromAccount,
      List<dynamic> topicIds,
      String fromResource,
      String msg,
      String msgType,
      bool isStore = false,
      String bizType}) async {
    assert(fromResource != null);
    assert(msg != null);
    assert(topicIds != null);
    assert(fromAccount != null);
    String api = _domain + "/api/push/p2t/more/";
    Response response = await _http.post(api, data: {
      "appId": mImcAppId,
      "appKey": mImcAppKey,
      "appSecret": mImcAppSecret,
      "fromAccount": fromAccount,
      "topicIds": topicIds,
      "fromResource": fromResource,
      "msg": msg,
      "msgType": msgType,
      "isStore": isStore,
      "bizType": bizType
    });
    return MIMCResponse.fromJson(response.data);
  }

  /// push p2u
  Future<MIMCResponse> pushP2UMessage(
      {String fromAccount,
      String topicId,
      String fromResource,
      String message,
      String msgType,
      bool isStore = false,
      String bizType}) async {
    assert(fromResource != null);
    assert(message != null);
    assert(topicId != null);
    assert(fromAccount != null);
    String api = _domain + "/api/push/ucs/singleMsgPush/";
    Response response = await _http.post(api, data: {
      "appId": mImcAppId,
      "appKey": mImcAppKey,
      "appSecret": mImcAppSecret,
      "fromAccount": fromAccount,
      "topicId": topicId,
      "fromResource": fromResource,
      "message": message,
      "msgType": msgType,
      "isStore": isStore,
      "bizType": bizType
    });
    return MIMCResponse.fromJson(response.data);
  }

  /// push p2u more
  Future<MIMCResponse> pushP2UMoreMessage(
      {String fromAccount,
      String topicId,
      String fromResource,
      List<dynamic> messages,
      String msgType,
      bool isStore = false,
      String bizType}) async {
    assert(fromResource != null);
    assert(messages != null);
    assert(topicId != null);
    assert(fromAccount != null);
    String api = _domain + "/api/push/ucs/multiMsgPush/";
    Response response = await _http.post(api, data: {
      "appId": mImcAppId,
      "appKey": mImcAppKey,
      "appSecret": mImcAppSecret,
      "fromAccount": fromAccount,
      "topicId": topicId,
      "fromResource": fromResource,
      "messages": messages,
      "msgType": msgType,
      "isStore": isStore,
      "bizType": bizType
    });
    return MIMCResponse.fromJson(response.data);
  }

  /// push multi Topic
  Future<MIMCResponse> pushMultiTopicMessage(
      {String fromAccount,
      List<dynamic> topicIds,
      String fromResource,
      String message,
      String msgType,
      bool isStore = false,
      String bizType}) async {
    assert(fromResource != null);
    assert(message != null);
    assert(topicIds != null);
    assert(fromAccount != null);
    String api = _domain + "/api/push/ucs/multiTopicPush/";
    Response response = await _http.post(api, data: {
      "appId": mImcAppId,
      "appKey": mImcAppKey,
      "appSecret": mImcAppSecret,
      "fromAccount": fromAccount,
      "topicIds": topicIds,
      "fromResource": fromResource,
      "message": message,
      "msgType": msgType,
      "isStore": isStore,
      "bizType": bizType
    });
    return MIMCResponse.fromJson(response.data);
  }
}
