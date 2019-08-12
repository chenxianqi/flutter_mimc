import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mimc/flutter_mimc.dart';
import 'dart:convert';
void main() => runApp(MaterialApp(
    home: MyApp()
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FlutterMimc flutterMimc;
  final String appAccount = "100";             // 我的账号
  String groupID = "21351198708203520"; // 操作的普通群ID
  String maxGroupID = "21360839299170304"; // 操作的无限通群ID
  bool isOnline = false;
  List<Map<String, String>> logs = [];
  TextEditingController accountCtr = TextEditingController(text: '21351198708203520');
  TextEditingController contentCtr = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // 初始化 FlutterMimc
    initFlutterMimc();

  }

  // 初始化
  void initFlutterMimc() async{
    flutterMimc = FlutterMimc.init(
      debug: true,
      appId: "2882303761517669588",
      appKey: "5111766983588",
      appSecret: "b0L3IOz/9Ob809v8H2FbVg==",
      appAccount: appAccount
    );
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

    if(id == null || id.isEmpty || content == null || content.isEmpty){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("id 或 content参数错误"), backgroundColor: Colors.pink,));
      return;
    }

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

  // 获取当前状态
  void getStatus() async{
    bool isOnline =  await flutterMimc.isOnline();
    addLog("获取当前状态：${isOnline ? '在线' :'离线'}");
  }

  // 创建一个群
  void createGroup() async{
    var res = await flutterMimc.createGroup("ios群", appAccount);
    if(!res['success']){
      addLog("创建群失败:${res['message']}" );
    }else{
      groupID = res['data']['topicInfo']['topicId'];
      addLog("创建群成功：${res['data']}");
    }
    accountCtr.text = groupID;
    setState(() { });
  }

  // 查询群
  void queryGroupInfo() async{
    var res = await flutterMimc.queryGroupInfo(groupID);
    if(!res['success']){
      addLog("查询群失败:${res['message']}" );
    }else{
      addLog("查询群成功：${res['data']}");
    }
  }

  // 查询所属群信息
  void queryGroupsOfAccount() async{
    var res = await flutterMimc.queryGroupsOfAccount();
    if(!res['success']){
      addLog("查询所属群失败:${res['message']}" );
    }else{
      addLog("查询所属群成功：${res['data']}");
    }
  }

  // 邀请用户加入群
  void joinGroup() async{
    var res = await flutterMimc.joinGroup(groupID, "101,102,103");
    if(!res['success']){
      addLog("邀请用户加入群执行失败:${res['message']}" );
    }else{
      addLog("邀请用户加入群执行成功：${res['data']}");
    }
  }

  // 非群主用户退群
  void quitGroup() async{
    var res = await flutterMimc.quitGroup(groupID);
    if(!res['success']){
      addLog("非群主用户退群执行失败:${res['message']}" );
    }else{
      addLog("非群主用户退群执行成功：${res['data']}");
    }
  }

  // 群主踢成员出群
  void kickGroup() async{
    var res = await flutterMimc.kickGroup(groupID, "101,102,103");
    if(!res['success']){
      addLog("群主踢成员出群执行失败:${res['message']}");
    }else{
      addLog("群主踢成员出群执行成功：${res['data']}");
    }
  }

  // 群主更新群信息
  void updateGroup() async{
    var res = await flutterMimc.updateGroup(groupID, newOwnerAccount: "", newGroupName: "新群名" + groupID, newGroupBulletin: "新公告");
    if(!res['success']){
      addLog("群主更新群信息执行失败:${res['message']}" );
    }else{
      addLog("群主更新群信息执行成功：${res['data']}");
    }
  }

  // 群主销毁群
  void dismissGroup() async{
    var res = await flutterMimc.dismissGroup(groupID);
    if(!res['success']){
      addLog("群主销毁群执行失败:${res['message']}" );
    }else{
      addLog("群主销毁群执行成功：${res['data']}");
    }
  }

  // 拉取单聊消息记录
  void pullP2PHistory() async{
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String fromAccount = appAccount;
    String toAccount = "101";
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2PHistory(
      toAccount: toAccount,
      fromAccount: fromAccount,
      utcFromTime: utcFromTime,
      utcToTime: utcToTime
    );
    if(!res['success']){
      addLog("单聊消息记录执行失败:${res['message']}" );
    }else{
      addLog("单聊消息记录执行成功：${res['data']}");
    }
  }

  // 拉取群聊消息记录
  void pullP2THistory() async{
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String account = appAccount;
    String topicId = groupID;
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2THistory(
      account: account,
      topicId: topicId,
      utcFromTime: utcFromTime,
      utcToTime: utcToTime
    );
    if(!res['success']){
      addLog("群聊消息记录执行失败:${res['message']}" );
    }else{
      addLog("群聊消息记录执行成功：${res['data']}");
    }
  }

  // 创建无限大群
  void createUnlimitedGroup() async{
    await flutterMimc.createUnlimitedGroup("创建无限大群");
    addLog("创建一个无限大群" );
  }

  // 加入无限大群
  void joinUnlimitedGroup() async{
    await flutterMimc.joinUnlimitedGroup("21395272047788032");
    addLog("加入无限大群$maxGroupID" );
  }

  // 退出无限大群
  void quitUnlimitedGroup() async{
    await flutterMimc.quitUnlimitedGroup("21395272047788032");
    addLog("退出无限大群$maxGroupID" );
  }

  // 解散无限大群
  void dismissUnlimitedGroup() async{
    await flutterMimc.dismissUnlimitedGroup(maxGroupID);
    addLog("解散无限大群$maxGroupID" );
  }

  // 查询无限大群成员
  void queryUnlimitedGroupMembers() async{
    var res = await flutterMimc.queryUnlimitedGroupMembers(maxGroupID);
    addLog("无限大群成员: $res" );
  }

  // 查询无限大群
  void queryUnlimitedGroups() async{
    var res = await flutterMimc.queryUnlimitedGroups();
    addLog("我所在的大群: $res" );
  }

  // 查询无限大群在线用户数
  void queryUnlimitedGroupOnlineUsers() async{
    var res =  await flutterMimc.queryUnlimitedGroupOnlineUsers(maxGroupID);
    addLog("无限大群在线用户数：$res" );
  }

  // 查询无限大群基本信息
  void queryUnlimitedGroupInfo() async{
    var res =  await flutterMimc.queryUnlimitedGroupInfo(maxGroupID);
    addLog("查询无限大群基本信息：$res" );
  }

  // 更新大群基本信息
  void updateUnlimitedGroup() async{
    var res =  await flutterMimc.updateUnlimitedGroup(maxGroupID, newGroupName: "新大群名称1");
    addLog("更新大群基本信息：$res" );
  }

  // 监听回调消息
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
      addLog(err);
    });

    // 接收单聊
    flutterMimc.addEventListenerHandleMessage().listen((MimcChatMessage resource){
      String content =utf8.decode(base64.decode(resource.message.payload));
      addLog("收到${resource.fromAccount}消息: $content");
      setState(() {});
    }).onError((err){
      addLog(err);
    });

    // 接收群聊
    flutterMimc.addEventListenerHandleGroupMessage().listen((MimcChatMessage resource){
      String content =utf8.decode(base64.decode(resource.message.payload));
      addLog("收到群${resource.topicId}消息: $content");
      setState(() {});
    }).onError((err){
      addLog(err);
    });

    // 发送消息回调
    flutterMimc.addEventListenerServerAck().listen((MimcServeraAck ack){
      addLog("发送消息回调==${ack.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // 发送单聊超时
    flutterMimc.addEventListenerSendMessageTimeout().listen((MimcChatMessage resource){
      addLog("发送单聊超时==${resource.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // 发送群聊超时
    flutterMimc.addEventListenerSendGroupMessageTimeout().listen((MimcChatMessage resource){
      addLog("发送群聊超时==${resource.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // 发送无限群聊超时
    flutterMimc.addEventListenerSendUnlimitedGroupMessageTimeout().listen((MimcChatMessage resource){
      addLog("发送无限群聊超时==${resource.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // 创建大群回调
    flutterMimc.addEventListenerHandleCreateUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("创建大群回调==${res}");
      maxGroupID = (res['topicId'] as int).toString();
    }).onError((err){
      addLog(err);
    });

    // 加入大群回调
    flutterMimc.addEventListenerHandleJoinUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("加入大群回调==${res}");
    }).onError((err){
      addLog(err);
    });

    // 退出大群回调
    flutterMimc.addEventListenerHandleQuitUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("退出大群回调==${res}");
    }).onError((err){
      addLog(err);
    });

    // 解散大群回调
    flutterMimc.addEventListenerHandleDismissUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("解散大群回调==${res}");
    }).onError((err){
      addLog(err);
    });



  }



  Widget button(String title, VoidCallback onPressed){
    return SizedBox(
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(3.0),
          margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(3.0))
          ),
          child: Text(title, style: TextStyle(color: Colors.white),),
        ),
        onTap: onPressed
      ),
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
              onPressed: isOnline ? logout :  login,
              child: Text( isOnline ? "退出登录" : "登录", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                children: <Widget>[
                  Text("\r\n当前账号：$appAccount,  当前状态：${isOnline ? '在线' : '离线'}\r\n"),
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
                      VerticalDivider(width: 10.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed:() => sendMessage(1),
                        child: Text( "发送群聊", style: TextStyle(color: Colors.white),),
                      ),
                      VerticalDivider(width: 10.0,),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed:() => sendMessage(2),
                        child: Text( "发送无限群聊", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("获取token",getToken),
                      button("获取当前账号",getAccount),
                      button("获取账号状态",getStatus),
                      button("拉取单聊记录",pullP2PHistory),
                    ],
                  ),
                  Text('\r\n----普通群----', style: TextStyle(color: Colors.grey),),
                  Divider(),
                  Row(
                    children: <Widget>[
                      button("创建群",createGroup),
                      button("查询群信息",queryGroupInfo),
                      button("查询所属",queryGroupsOfAccount),
                      button("邀请加入群",joinGroup),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("非群主退群",quitGroup),
                      button("踢成员出群",kickGroup),
                      button("更新群信息",updateGroup),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("群主删除群",dismissGroup),
                      button("拉取群聊记录",pullP2THistory),
                    ],
                  ),
                  Text('\r\n----无限大群----', style: TextStyle(color: Colors.grey),),
                  Divider(),
                  Row(
                    children: <Widget>[
                      button("创建大群",createUnlimitedGroup),
                      button("加入大群",joinUnlimitedGroup),
                      button("退出大群",quitUnlimitedGroup),
                      button("解散大群",dismissUnlimitedGroup),
                      button("大群信息",queryUnlimitedGroupInfo),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      button("大群更新",updateUnlimitedGroup),
                      button("大群成员",queryUnlimitedGroupMembers),
                      button("在线用户数",queryUnlimitedGroupOnlineUsers),
                      button("我所在的无限大群",queryUnlimitedGroups),
                    ],
                  ),
                  Divider()
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white70,
                height: 100.0,
                padding: EdgeInsets.symmetric(horizontal:5.0),
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
            )
          ],
        )
    );
  }
}
