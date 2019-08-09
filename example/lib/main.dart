import 'package:flutter/material.dart';
import 'package:flutter_mimc/flutter_mimc.dart';
import 'dart:convert';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FlutterMimc flutterMimc;
  final String appAccount = "100";
  bool isOnline = false;
  List<Map<String, String>> logs = [];
  TextEditingController accountCtr = TextEditingController();
  TextEditingController contentCtr = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 初始化 FlutterMimc
    initFlutterMimc();

  }

  // 初始化
  void initFlutterMimc() async{
    flutterMimc = FlutterMimc.init({
      "debug": false,
      "appId": "2882303761517669588",
      "appKey": "5111766983588",
      "appSecret": "b0L3IOz/9Ob809v8H2FbVg==",
      "appAccount": appAccount
    });
    addLog("init==实例化完成");
    listener();
  }

  // 登录
  void login() async{
    await flutterMimc.login();
  }

  // add log
  addLog(String content){
    print(content);
    logs.insert(0,{
      "date": DateTime.now().toIso8601String(),
      "content": content
    });
    setState(() {});
  }

  // addEventListener
  void listener(){


    // 监听登录状态
    flutterMimc.addEventListenerStatusChanged().listen((status){
      isOnline = status;
      if(status){
        addLog("$appAccount====状态变更====上线");
      }else{
        addLog("$appAccount====状态变更====下线");
      }
      setState(() {});
    }).onError((err){
      print(err);
    });

    // 接收单聊
    flutterMimc.addEventListenerHandleMessage().listen((MimcChatMessage resource){
      print(resource);
      String content =utf8.decode(base64.decode(resource.message.payload));
      addLog("收到${resource.fromAccount}消息: $content");
      setState(() {});
    }).onError((err){
      print(err);
    });



  }

  // 退出登录
  void logout() async{
    await flutterMimc.logout();
  }

  // 发送消息
  void sendMessage(int type){
    String id = accountCtr.value.text;
    String content = contentCtr.value.text;
    MimcChatMessage messageRes = MimcChatMessage();
    MimcMessageBena messageBena = MimcMessageBena();
    messageRes.timestamp = DateTime.now().millisecondsSinceEpoch;
    messageRes.bizType = "bizType";
    messageRes.fromAccount = appAccount;
    messageBena.timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    messageBena.payload = base64Encode(utf8.encode(content));
    messageBena.version  = 0;
    messageBena.msgId  = "msgId";
    messageRes.message = messageBena;
    if(type == 0){
      messageRes.toAccount = id;
      addLog("发送给$id: $content");
      flutterMimc.sendMessage(messageRes);
    }else{
      messageRes.topicId = int.parse(id);
    }
    contentCtr.clear();
  }

  // 获取token
  void getToken() async{
    String token = await flutterMimc.getToken();
    addLog("获取token成功：$token");
  }

  // 获取当前账号
  void getAccount() async{
    String account = await flutterMimc.getAccount();
    addLog("获取当前账号成功：$account");
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlutterMimc example app'),
          actions: <Widget>[
            RaisedButton(
              color: Colors.blue,
              onPressed: isOnline ? logout :  login,
              child: Text( isOnline ? "退出登录" : "登录", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: Colors.white70,
              height: double.infinity,
              padding: EdgeInsets.only(top: 300.0, left: 10.0, right:10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("操作日志"),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index){
                          return ListTile(title: Text(logs[index]['content'], maxLines: 3, overflow: TextOverflow.ellipsis,), subtitle: Text(logs[index]['date']),);
                        }
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 300.0,
              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Text("当前账号：$appAccount,  当前状态：${isOnline ? '在线' : '离线'}"),
                  SizedBox(
                    height: 35.0,
                    child: TextField(
                        controller: accountCtr,
                        decoration: InputDecoration(
                            hintText: "输入对方群ID、或对方账号"
                        )
                    ),
                  ),
                  SizedBox(
                    height: 35.0,
                    child: TextField(
                        controller: contentCtr,
                        decoration: InputDecoration(
                            hintText: "输入发送的内容"
                        )
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed:() => sendMessage(0),
                        child: Text( "发送单聊", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 20.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed:() => sendMessage(1),
                        child: Text( "发送群聊", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: getToken,
                        child: Text( "获取token", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 20.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: getAccount,
                        child: Text( "获取当前账号", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                  Divider()
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}
