import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mimc/flutter_mimc.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterMIMC flutterMimc;
  MIMCPush mImcPush;
  final String appAccount = "100165"; // 我的账号
  String groupID = "21351198708203520"; // 操作的普通群ID
  String maxGroupID = "21360844399443968"; // 操作的无限通群ID
  bool isOnline = false;
  List<Map<String, String>> logs = [];
  TextEditingController accountCtr = TextEditingController();
  TextEditingController contentCtr = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // 初始化 FlutterMIMC
    initFlutterMIMC();
  }

  // 初始化
  void initFlutterMIMC() async {
    // token String init
    // String tokenString = '{"code":200,"message":"success","data":{}}';
    // flutterMimc = await FlutterMIMC.stringTokenInit(tokenString, debug: true);

    // const data init
    flutterMimc = await FlutterMIMC.init(
        debug: false,
        appId: "xxxxxx",
        appKey: "xxxxxx",
        appSecret: "xxxxxx",
        appAccount: appAccount);
    addLog("init==实例化完成");
    listener();

    /// (需要推送消息的)实例化推送消息接口
    mImcPush = MIMCPush(
        mImcAppId: "xxxxxx", mImcAppKey: "xxxxxx", mImcAppSecret: "xxxxxx");
  }

  // 登录
  void login() async {
    await flutterMimc.login();
  }

  // add log
  addLog(String content) {
    debugPrint(content);
    logs.insert(
        0, {"date": DateTime.now().toIso8601String(), "content": content});
    setState(() {});
  }

  // 退出登录
  void logout() async {
    await flutterMimc.logout();
  }

  ///  发送单聊消息 或 发送在线消息
  /// [type] 0 单聊， 1 普通群聊， 2 无限大群, 3 在线消息
  void sendMessage(int type) async {
    String id = accountCtr.value.text;
    String content = contentCtr.value.text;

    if (id == null || id.isEmpty || content == null || content.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("id 或 content参数错误"),
        backgroundColor: Colors.pink,
      ));
      return;
    }

    // 消息
    MIMCMessage message = MIMCMessage();
    message.bizType = "bizType"; // 消息类型(开发者自定义)
    // message.toAccount = id;        // 接收者账号(发送单聊留null)
    // message.topicId                // 指定发送的群ID(发送群聊时留null)

    // 自定义消息体
    Map<String, dynamic> payloadMap = {
      "from_account": appAccount,
      "to_account": id,
      "biz_type": "text",
      "version": "0",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "read": 0,
      "transfer_account": 0,
      "payload": content
    };

    // base64处理自定义消息
    message.payload = base64Encode(utf8.encode(json.encode(payloadMap)));

    if (type == 0) {
      /// 单聊消息
      message.toAccount = id;
      addLog("发送给$id: $content");
      var pid = await flutterMimc.sendMessage(message);
      print("pid====$pid");
    } else if (type == 1) {
      /// 普通群消息
      message.topicId = int.parse(id);
      addLog("发送普通群消息: $content");
      var gid = await flutterMimc.sendGroupMsg(message);
      print("gid====$gid");
    } else if (type == 2) {
      /// 无限群消息
      message.topicId = int.parse(id);
      addLog("发送无限群消息: $content");
      flutterMimc.sendGroupMsg(message, isUnlimitedGroup: true);
    } else if (type == 3) {
      /// 在线消息
      message.toAccount = id;
      addLog("发送在线消息: $content");
      flutterMimc.sendOnlineMessage(message);
    }
    print(json.encode(message.toJson()));
    contentCtr.clear();
  }

  // 获取token
  void getToken() async {
    String token = await flutterMimc.getToken();
    addLog("获取token成功：$token");
  }

  // 获取当前账号
  void getAccount() async {
    String account = await flutterMimc.getAccount();
    addLog("获取当前账号成功：$account");
  }

  // 获取当前状态
  void getStatus() async {
    bool isOnline = await flutterMimc.isOnline();
    addLog("获取当前状态：${isOnline ? '在线' : '离线'}");
  }

  // 创建一个群
  void createGroup() async {
    MIMCResponse res = await flutterMimc.createGroup(
        topicName: "ios群", accounts: appAccount, extra: "");
    if (res.code == 200) {
      groupID = res.data['topicInfo']['topicId'];
      addLog("创建群成功：${res.toJson()}");
    } else {
      addLog("创建群失败:${res.message}");
    }
    accountCtr.text = groupID;
    setState(() {});
  }

  // 查询群
  void queryGroupInfo() async {
    var res = await flutterMimc.queryGroupInfo(groupID);
    if (res.code == 200) {
      groupID = res.data['topicInfo']['topicId'];
      addLog("查询群成功：${res.toJson()}");
    } else {
      addLog("查询群失败:${res.message}");
    }
  }

  // 查询所属群信息
  void queryGroupsOfAccount() async {
    var res = await flutterMimc.queryGroupsOfAccount();
    if (res.code == 200) {
      addLog("查询所属群成功：${res.toJson()}");
    } else {
      addLog("查询所属群失败:${res.message}");
    }
  }

  // 邀请用户加入群
  void joinGroup() async {
    var res =
        await flutterMimc.joinGroup(topicId: groupID, accounts: "101,102,103");
    if (res.code == 200) {
      addLog("邀请用户加入群执行成功：${res.toJson()}");
    } else {
      addLog("邀请用户加入群执行失败:${res.message}");
    }
  }

  // 非群主用户退群
  void quitGroup() async {
    var res = await flutterMimc.quitGroup(groupID);
    if (res.code == 200) {
      addLog("非群主用户退群执行成功：${res.toJson()}");
    } else {
      addLog("非群主用户退群执行失败:${res.message}");
    }
  }

  // 群主踢成员出群
  void kickGroup() async {
    var res = await flutterMimc.kickGroup(groupID, "101,102,103");
    if (res.code == 200) {
      addLog("群主踢成员出群执行成功：${res.toJson()}");
    } else {
      addLog("群主踢成员出群执行失败:${res.message}");
    }
  }

  // 群主更新群信息
  void updateGroup() async {
    var res =
        await flutterMimc.updateGroup(topicId: groupID, topicName: "newName");
    if (res.code == 200) {
      addLog("群主更新群信息执行成功:${res.toJson()}");
    } else {
      addLog("群主更新群信息执行失败：${res.message}");
    }
  }

  // 群主销毁群
  void dismissGroup() async {
    var res = await flutterMimc.dismissGroup(groupID);
    if (res.code == 200) {
      addLog("群主销毁群执行成功：${res.toJson()}");
    } else {
      addLog("群主销毁群执行失败:${res.message}");
    }
  }

  // 拉取单聊消息记录(包含多个版本的接口)
  void pullP2PHistory() async {
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String fromAccount = appAccount;
    String toAccount = "101";
    String utcFromTime = (thisTimer - 85400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2PHistory(PullHistoryType.queryOnCount,
        toAccount: toAccount,
        fromAccount: fromAccount,
        utcFromTime: utcFromTime,
        utcToTime: utcToTime);
    if (res.code == 200) {
      addLog("单聊消息记录执行成功：${res.toJson()}");
    } else {
      addLog("单聊消息记录执行失败:${res.message}");
    }
  }

  // 拉取群聊消息记录(包含多个版本的接口)
  void pullP2THistory() async {
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String account = appAccount;
    String topicId = groupID;
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2THistory(PullHistoryType.queryOnCount,
        account: account,
        topicId: topicId,
        utcFromTime: utcFromTime,
        utcToTime: utcToTime);
    if (res.code == 200) {
      addLog("群聊消息记录执行成功：${res.toJson()}");
    } else {
      addLog("群聊消息记录执行失败:${res.message}");
    }
  }

  // 拉取无限大群消息记录(包含多个版本的接口)
  void pullP2UHistory() async {
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String account = appAccount;
    String topicId = maxGroupID;
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2UHistory(PullHistoryType.queryOnCount,
        account: account,
        topicId: topicId,
        utcFromTime: utcFromTime,
        utcToTime: utcToTime);
    if (res.code == 200) {
      addLog("无限群聊消息记录执行成功：${res.toJson()}");
    } else {
      addLog("无限群聊消息记录执行失败:${res.message}");
    }
  }

  // 删除无限大群
  void deleteUnlimitedGroup() async {
    var res = await flutterMimc.deleteUnlimitedGroup(topicId: maxGroupID);
    if (res.code == 200) {
      addLog("删除无限大群成功：${res.toJson()}");
    } else {
      addLog("删除无限大群失败:${res.message}");
    }
  }

  // 创建无限大群
  void createUnlimitedGroup() async {
    var res =
        await flutterMimc.createUnlimitedGroup(topicName: "创建无限大群", extra: "");
    if (res.code == 200) {
      maxGroupID = res.data['topicId'];
      addLog("创建无限大群成功：${res.toJson()}");
    } else {
      addLog("创建无限大群失败:${res.message}");
    }
  }

  // 加入无限大群
  void joinUnlimitedGroup() async {
    await flutterMimc.joinUnlimitedGroup("21395272047788032");
    addLog("加入无限大群$maxGroupID");
  }

  // 退出无限大群
  void quitUnlimitedGroup() async {
    await flutterMimc.quitUnlimitedGroup("21395272047788032");
    addLog("退出无限大群$maxGroupID");
  }

  // 解散无限大群
  void dismissUnlimitedGroup() async {
    await flutterMimc.dismissUnlimitedGroup(maxGroupID);
    addLog("解散无限大群$maxGroupID");
  }

  // 查询无限大群成员
  void queryUnlimitedGroupMembers() async {
    var res = await flutterMimc.queryUnlimitedGroupMembers(topicId: maxGroupID);
    if (res.code == 200) {
      addLog("查询无限大群成员成功：${res.toJson()}");
    } else {
      addLog("查询无限大群成员失败:${res.message}");
    }
  }

  // 查询无限大群
  void queryUnlimitedGroups() async {
    var res = await flutterMimc.queryUnlimitedGroups();
    if (res.code == 200) {
      addLog("我所在的大群成功：${res.toJson()}");
    } else {
      addLog("我所在的大群失败:${res.message}");
    }
  }

  // 查询无限大群在线用户数
  void queryUnlimitedGroupOnlineUsers() async {
    var res = await flutterMimc.queryUnlimitedGroupOnlineUsers(maxGroupID);
    if (res.code == 200) {
      addLog("查询无限大群在线用户数成功：${res.toJson()}");
    } else {
      addLog("查询无限大群在线用户数失败:${res.message}");
    }
  }

  // 查询无限大群基本信息
  void queryUnlimitedGroupInfo() async {
    var res = await flutterMimc.queryUnlimitedGroupInfo(maxGroupID);
    if (res.code == 200) {
      addLog("查询无限大群基本信息成功：${res.toJson()}");
    } else {
      addLog("查询无限大群基本信息失败:${res.message}");
    }
  }

  // 更新大群基本信息
  void updateUnlimitedGroup() async {
    var res = await flutterMimc.updateUnlimitedGroup(
        topicId: maxGroupID, topicName: "新大群名称1");
    if (res.code == 200) {
      addLog("更新大群基本信息成功：${res.toJson()}");
    } else {
      addLog("更新大群基本信息失败:${res.message}");
    }
  }

  // 获取最近会话列表
  void getContact() async {
    var res = await flutterMimc.getContact(isV2: true);
    if (res.code == 200) {
      addLog("获取最近会话列表成功：${res.toJson()}");
    } else {
      addLog("获取最近会话列表失败:${res.message}");
    }
  }

  // 拉黑对方
  void setBlackList() async {
    var res = await flutterMimc.setBlackList("200");
    if (res.code == 200) {
      addLog("拉黑对方成功：${res.toJson()}");
    } else {
      addLog("拉黑对方失败:${res.message}");
    }
  }

  // 取消拉黑对方
  void deleteBlackList() async {
    var res = await flutterMimc.deleteBlackList("200");
    if (res.code == 200) {
      addLog("取消拉黑对方成功：${res.toJson()}");
    } else {
      addLog("取消拉黑对方失败:${res.message}");
    }
  }

  // 判断账号是否被拉黑
  void hasBlackList() async {
    var res = await flutterMimc.hasBlackList("200");
    if (res.code == 200) {
      addLog("判断账号是否被拉黑成功：${res.toJson()}");
    } else {
      addLog("判断账号是否被拉黑失败:${res.message}");
    }
  }

  // 普通群拉黑成员
  void setGroupBlackList() async {
    var res = await flutterMimc.setGroupBlackList(
        blackTopicId: "21351198708203520", blackAccount: "102");
    if (res.code == 200) {
      addLog("普通群拉黑成员成功：${res.toJson()}");
    } else {
      addLog("普通群拉黑成员失败:${res.message}");
    }
  }

  // 普通群取消拉黑成员
  void deleteGroupBlackList() async {
    var res = await flutterMimc.deleteGroupBlackList(
        blackTopicId: "21351198708203520", blackAccount: "102");
    if (res.code == 200) {
      addLog("普通群取消拉黑成员成功：${res.toJson()}");
    } else {
      addLog("普通群取消拉黑成员失败:${res.message}");
    }
  }

  // 判断账号是否被普通群拉黑
  void hasGroupBlackList() async {
    var res = await flutterMimc.hasGroupBlackList(
        blackTopicId: "21351198708203520", blackAccount: "102");
    if (res.code == 200) {
      addLog("判断账号是否被普通群拉黑成功：${res.toJson()}");
    } else {
      addLog("判断账号是否被普通群拉黑失败:${res.message}");
    }
  }

  // 推送单聊信息
  void pushP2PMessage() async {
    var res = await mImcPush.pushP2PMessage(
        fromAccount: "100",
        toAccount: "101",
        msg: "data",
        fromResource: "keith");
    if (res.code == 200) {
      addLog("推送单聊信息成功：${res.toJson()}");
    } else {
      addLog("推送单聊信息失败:${res.message}");
    }
  }

  // 批量推送单聊信息
  void pushP2PMoreMessage() async {
    var res = await mImcPush.pushP2PMoreMessage(
        fromAccount: "100",
        toAccounts: ["101", "102"],
        msg: "data",
        fromResource: "keith");
    if (res.code == 200) {
      addLog("批量推送单聊信息成功：${res.toJson()}");
    } else {
      addLog("批量推送单聊信息失败:${res.message}");
    }
  }

  // 推送群聊信息
  void pushP2TMessage() async {
    var res = await mImcPush.pushP2TMessage(
        fromAccount: "100",
        topicId: "21351235479666688",
        msg: "data",
        fromResource: "keith");
    if (res.code == 200) {
      addLog("推送群聊信息成功：${res.toJson()}");
    } else {
      addLog("推送群聊信息失败:${res.message}");
    }
  }

  // 批量推送群聊信息
  void pushP2TMoreMessage() async {
    var res = await mImcPush.pushP2TMoreMessage(
        fromAccount: "100",
        topicIds: ["21351235479666688", "21351318392668160"],
        msg: "data",
        fromResource: "keith");
    if (res.code == 200) {
      addLog("批量推送群聊信息成功：${res.toJson()}");
    } else {
      addLog("批量推送群聊信息失败:${res.message}");
    }
  }

  // 单条推送无限群聊消息
  void pushP2UMessage() async {
    var res = await mImcPush.pushP2UMessage(
        fromAccount: "100",
        topicId: "21361055926583296",
        message: "data",
        fromResource: "keith");
    if (res.code == 200) {
      addLog("单条推送无限群聊消息成功：${res.toJson()}");
    } else {
      addLog("单条推送无限群聊消息失败:${res.message}");
    }
  }

  // 单条推送无限群聊消息
  void pushP2UMoreMessage() async {
    var res = await mImcPush.pushP2UMoreMessage(
        fromAccount: "100",
        topicId: "21361055926583296",
        messages: ["data", "data1"],
        fromResource: "keith");
    if (res.code == 200) {
      addLog("批量推送无限群聊消息成功：${res.toJson()}");
    } else {
      addLog("批量推送无限群聊消息失败:${res.message}");
    }
  }

  // 多群推送单条消息
  void pushMultiTopicMessage() async {
    var res = await mImcPush.pushMultiTopicMessage(
        fromAccount: "100",
        topicIds: ["21361055926583296"],
        message: "data",
        fromResource: "keith");
    if (res.code == 200) {
      addLog("多群推送单条消息成功：${res.toJson()}");
    } else {
      addLog("多群推送单条消息失败:${res.message}");
    }
  }

  // 监听回调消息
  void listener() async {
    print(await flutterMimc.isOnline());
    // 监听登录状态
    flutterMimc.addEventListenerStatusChanged().listen((status) {
      isOnline = status;
      if (status) {
        addLog("$appAccount====状态变更====上线");
      } else {
        addLog("$appAccount====状态变更====下线");
      }
      setState(() {});
    }).onError((err) {
      addLog(err);
    });

    // 接收单聊
    flutterMimc.addEventListenerHandleMessage().listen((MIMCMessage message) {
      String content = utf8.decode(base64.decode(message.payload));
      addLog("收到${message.fromAccount}消息: $content");
      setState(() {});
    }).onError((err) {
      addLog(err);
    });

    // 接收群聊
    flutterMimc
        .addEventListenerHandleGroupMessage()
        .listen((MIMCMessage message) {
      String content = utf8.decode(base64.decode(message.payload));
      addLog("收到群${message.topicId}消息: $content");
      setState(() {});
    }).onError((err) {
      addLog(err);
    });

    // 发送消息回调
    flutterMimc.addEventListenerServerAck().listen((MimcServeraAck ack) {
      addLog("发送消息回调==${ack.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // 发送在线消息回调
    flutterMimc.addEventListenerOnlineMessageAck().listen((MimcServeraAck ack) {
      addLog("发送在线消息回调==${ack.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // 发送单聊超时
    flutterMimc
        .addEventListenerSendMessageTimeout()
        .listen((MIMCMessage message) {
      addLog("发送单聊超时==${message.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // 发送群聊超时
    flutterMimc
        .addEventListenerSendGroupMessageTimeout()
        .listen((MIMCMessage message) {
      addLog("发送群聊超时==${message.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // 发送无限群聊超时
    flutterMimc
        .addEventListenerSendUnlimitedGroupMessageTimeout()
        .listen((MIMCMessage message) {
      addLog("发送无限群聊超时==${message.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // 创建大群回调
    flutterMimc
        .addEventListenerHandleCreateUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("创建大群回调==$res");
      maxGroupID = (res['topicId'] as int).toString();
    }).onError((err) {
      addLog(err);
    });

    // 加入大群回调
    flutterMimc
        .addEventListenerHandleJoinUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("加入大群回调==$res");
    }).onError((err) {
      addLog(err);
    });

    // 退出大群回调
    flutterMimc
        .addEventListenerHandleQuitUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("退出大群回调==$res");
    }).onError((err) {
      addLog(err);
    });

    // 解散大群回调
    flutterMimc
        .addEventListenerHandleDismissUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("解散大群回调==$res");
    }).onError((err) {
      addLog(err);
    });

    // 收到在线消息
    flutterMimc.addEventListenerOnlineMessage().listen((msg) {
      addLog("收到在线消息==${msg.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // 收到发送在线消息回调
    flutterMimc.addEventListenerOnlineMessageAck().listen((ack) {
      addLog("收到发送在线消息回调==${ack.toJson()}");
    }).onError((err) {
      addLog(err);
    });
  }

  Widget button(String title, VoidCallback onPressed) {
    return SizedBox(
      child: GestureDetector(
          child: Container(
            padding: EdgeInsets.all(3.0),
            margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(3.0))),
            child: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
          ),
          onTap: onPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('FlutterMimc example app'),
          actions: <Widget>[
            RaisedButton(
              color: Colors.blue,
              onPressed: isOnline ? logout : login,
              child: Text(
                isOnline ? "退出登录" : "登录",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                children: <Widget>[
                  Text(
                      "\r\n当前账号：$appAccount,  当前状态：${isOnline ? '在线' : '离线'}\r\n"),
                  SizedBox(
                    height: 35.0,
                    child: TextField(
                        controller: accountCtr,
                        decoration: InputDecoration(hintText: "输入对方群ID、或对方账号")),
                  ),
                  SizedBox(
                    height: 35.0,
                    child: TextField(
                        controller: contentCtr,
                        decoration: InputDecoration(hintText: "输入发送的内容")),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () => sendMessage(0),
                        child: Text(
                          "发送单聊",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      VerticalDivider(
                        width: 10.0,
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () => sendMessage(3),
                        child: Text(
                          "发送在线消息",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      VerticalDivider(
                        width: 10.0,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () => sendMessage(1),
                        child: Text(
                          "发送群聊",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      VerticalDivider(
                        width: 10.0,
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () => sendMessage(2),
                        child: Text(
                          "发送无限群聊",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("获取token", getToken),
                      button("当前账号", getAccount),
                      button("账号状态", getStatus),
                      button("单聊记录", pullP2PHistory),
                      button("会话列表", getContact),
                    ],
                  ),
                  Text(
                    '\r\n----普通群----',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      button("创建群", createGroup),
                      button("查询群信息", queryGroupInfo),
                      button("查询所属", queryGroupsOfAccount),
                      button("邀请加入群", joinGroup),
                      button("群主删除群", dismissGroup),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("非群主退群", quitGroup),
                      button("踢成员出群", kickGroup),
                      button("更新群信息", updateGroup),
                      button("拉取群聊记录", pullP2THistory),
                    ],
                  ),
                  Text(
                    '\r\n----无限大群----',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      button("创建大群", createUnlimitedGroup),
                      button("加入大群", joinUnlimitedGroup),
                      button("退出大群", quitUnlimitedGroup),
                      button("解散大群", dismissUnlimitedGroup),
                      button("大群信息", queryUnlimitedGroupInfo),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("大群更新", updateUnlimitedGroup),
                      button("大群成员", queryUnlimitedGroupMembers),
                      button("在线用户数", queryUnlimitedGroupOnlineUsers),
                      button("所在的无限大群", queryUnlimitedGroups),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("超级大群聊消息记录", pullP2UHistory),
                      button("删除无限大群", deleteUnlimitedGroup),
                    ],
                  ),
                  Text(
                    '\r\n----黑名单----',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      button("拉黑对方", setBlackList),
                      button("取消拉黑", deleteBlackList),
                      button("检查是否被拉黑", hasBlackList),
                    ],
                  ),
                  Text(
                    '\r\n----群禁言----',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      button("禁言群成员", setGroupBlackList),
                      button("取消禁言群成员", deleteGroupBlackList),
                      button("检查是否禁言", hasGroupBlackList),
                    ],
                  ),
                  Text(
                    '\r\n----推送消息----',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      button("推送单聊信息", pushP2PMessage),
                      button("批量推送单聊信息", pushP2PMoreMessage),
                      button("推送群聊信息", pushP2TMessage),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("批量推送群聊信息", pushP2TMoreMessage),
                      button("单条推送无限群聊消息", pushP2UMessage),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("批量推送无限群聊消息", pushP2UMoreMessage),
                      button("多群推送单条消息", pushMultiTopicMessage),
                    ],
                  ),
                  Divider(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white70,
              height: 500.0,
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("操作日志（部分接口需要登录后才能操作）"),
                      button("清空日志", () {
                        logs = [];
                        setState(() {});
                      }),
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(logs[index]['content']),
                            subtitle: Text(logs[index]['date']),
                          );
                        }),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
