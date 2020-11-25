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
    String tokenString = '{"code":200,"message":"success","data":{"appId":"2882303761517669588","appPackage":"com.xiaomi.mimcdemo","appAccount":"1000","miChid":9,"miUserId":"15788717000364152","miUserSecurityKey":"2KbWssbWsm3ytO7erDU5vQ==","token":"bJRLeg7AgtSh0T13YjL/IFDdK0JTjCJG4KdSfB9L7c0N56uq0EiflNyh2H5qmlOwqeOEcudSjEicejSfy+BJz2ui/bkYYYPpT9rKkuChjVDMAXpIv1L7ItYzsCaYjygYQD/FuVQ+0xiiFJqDudzL2vHwjH/X7NJbH7JCqycZkfVxiiDzgETbMuR7yzFUd3maoT6mq2IfyPGmH4VJNl2CglT5IffuWEiRocY1i2iEGsJLqHC/kABkVGro/kto6bi1pdBqxhtbo79/DZ6/KNi2JybTYdAnCpvIuvEAy+H+eiL1rMMD1ovR/3eqnJgeSgUoZ1dH27wQ10ZuW+1B1v/8ZWr6FYOh0VkTROSdrm+jvzhkyo5n2Wbn88fUjwB7A5J5k/IE65lBkKOcsnhAhm3yhq3S71iClbd+CPU/tT5nwoeO4g3Ra9+j87VZq4Qc018By+Hlc/+lJc5Is+mvRM3eGQ==","regionBucket":153,"feDomainName":"app.chat.xiaomi.net","relayDomainName":"relay.mimc.chat.xiaomi.net"}}';
    flutterMimc = await FlutterMIMC.stringTokenInit(tokenString, debug: true);


    addLog("init==实例化完成");
    listener();

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
                      Text("日志"),
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
