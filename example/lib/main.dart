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
    }else if(type == 1){
      messageRes.topicId = int.parse(id);
      addLog("发送普通群消息: $content");
      flutterMimc.sendGroupMsg(messageRes);
    }else{
      messageRes.topicId = int.parse(id);
      addLog("发送无限群消息: $content");
      flutterMimc.sendGroupMsg(messageRes, isUnlimitedGroup: true);
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

  // 创建一个群
  void createGroup() async{
    var res = await flutterMimc.createGroup("骚群", appAccount);
    if(res['error'] != null){
      addLog("创建群失败:${res['error']}" );
    }else{
      addLog("创建群成功：${res['data']}");
    }

  }

  // 查询群
  void queryGroupInfo() async{
    var res = await flutterMimc.queryGroupInfo("21354536967340032");
    if(res['error'] != null){
      addLog("查询群失败:${res['error']}" );
    }else{
      addLog("查询群成功：${res['data']}");
    }
  }

  // 查询所属群信息
  void queryGroupsOfAccount() async{
    var res = await flutterMimc.queryGroupsOfAccount();
    if(res['error'] != null){
      addLog("查询所属群失败:${res['error']}" );
    }else{
      addLog("查询所属群成功：${res['data']}");
    }
  }

  // 邀请用户加入群
  void joinGroup() async{
    var res = await flutterMimc.joinGroup("21354536967340032", "101,102,103");
    if(res['error'] != null){
      addLog("邀请用户加入群执行失败:${res['error']}" );
    }else{
      addLog("邀请用户加入群执行成功：${res['data']}");
    }
  }

  // 非群主用户退群
  void quitGroup() async{
    var res = await flutterMimc.quitGroup("21354536967340032");
    if(res['error'] != null){
      addLog("非群主用户退群执行失败:${res['error']}" );
    }else{
      addLog("非群主用户退群执行成功：${res['data']}");
    }
  }

  // 群主踢成员出群
  void kickGroup() async{
    var res = await flutterMimc.kickGroup("21354536967340032", "101,102,103");
    if(res['error'] != null){
      addLog("群主踢成员出群执行失败:${res['error']}" );
    }else{
      addLog("群主踢成员出群执行成功：${res['data']}");
    }
  }

  // 群主更新群信息
  void updateGroup() async{
    var res = await flutterMimc.updateGroup("21354536967340032", newOwnerAccount: "", newGroupName: "新群名", newGroupBulletin: "新公告");
    print(res);
    if(res['error'] != null){
      addLog("群主更新群信息执行失败:${res['error']}" );
    }else{
      addLog("群主更新群信息执行成功：${res['data']}");
    }
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

    // 接收群聊
    flutterMimc.addEventListenerHandleGroupMessage().listen((MimcChatMessage resource){
      print(resource);
      String content =utf8.decode(base64.decode(resource.message.payload));
      addLog("收到群${resource.topicId}消息: $content");
      setState(() {});
    }).onError((err){
      print(err);
    });

    // 发送单聊回调
    flutterMimc.addEventListenerServerAck().listen((MimcServeraAck ack){
      print("发送单聊回调==${ack.toJson()}");
    }).onError((err){
      print(err);
    });

    // 发送单聊超时
    flutterMimc.addEventListenerSendMessageTimeout().listen((MimcChatMessage resource){
      print("发送单聊超时==${resource.toJson()}");
    }).onError((err){
      print(err);
    });



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
              padding: EdgeInsets.only(top: 350.0, left: 10.0, right:10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("操作日志"),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index){
                          return ListTile(title: Text(logs[index]['content']), subtitle: Text(logs[index]['date']),);
                        }
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 350.0,
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
                      VerticalDivider(width: 5.0,),
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
                      VerticalDivider(width: 5.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: getAccount,
                        child: Text( "获取当前账号", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 5.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: createGroup,
                        child: Text( "创建群", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: queryGroupInfo,
                        child: Text( "查询群", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 5.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: queryGroupsOfAccount,
                        child: Text( "查询所属", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 5.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: joinGroup,
                        child: Text( "邀请加入群", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: quitGroup,
                        child: Text( "非群主退群", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 5.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: kickGroup,
                        child: Text( "踢成员出群", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 5.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: updateGroup,
                        child: Text( "更新群信息", style: TextStyle(color: Colors.white),),
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
