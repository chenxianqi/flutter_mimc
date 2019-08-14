## Flutter_mimc  v 0.0.3

### 感谢@小米MIMC团队的贡献
   让IM实现变得简单，喜欢本插件的客观留下您的一个小脚印（star一下）非常感谢

### 目前功能
* 单聊
* 普通群聊
* 无限大群聊
* 实时流（暂未实现）

## 使用需知
 使用`flutter_mimc`，建议先阅读[小米即时消息云官方文档](https://admin.mimc.chat.xiaomi.net/docs/)，
 这有助于你使用`flutter_mimc`。


# 安装 flutter_mimc
## 引入

在你的 `pubspec.yaml` 文件中添加如下依赖:

```yaml
dependencies:
  flutter_mimc: ^${latestVersion}
```


## 初始化
使用`flutter_mimc`前，需要进行初始化操作：
 ```dart

    import 'package:flutter_mimc/flutter_mimc.dart';

     FlutterMimc flutterMimc = FlutterMimc.init(
          debug: true,
          appId: "xxxxxxxx",
          appKey: "xxxxxxxx",
          appSecret: "xxxxxxxx",
          appAccount: appAccount
    );
 ```
 
 
## 消息体注意事项
  消息体一致性
  flutter_mimc提供MIMCMessage模型类
 ```dart
     MIMCMessage message = MIMCMessage();
     message.bizType = "bizType";      // 消息类型(开发者自定义)
     message.toAccount = "";           // 接收者账号(发送单聊留null)
     message.topicId = "";             // 指定发送的群ID(发送群聊时留null)
     message.payload = "";             // 开发者自定义消息体
 
     // 自定义消息体(官方建议的消息体，我多加了几个字段，因为我没有使用上层的任何字段)
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
     
     // 发送单聊
     var pid = await flutterMimc.sendMessage(message);
     
     // 发送普通群聊
     var gid = await flutterMimc.sendGroupMsg(message);
     
     // 发送无限大群聊
     var gid = flutterMimc.sendGroupMsg(message, isUnlimitedGroup: true);
 ```
 
 ## 接口使用用例
```dart

  FlutterMimc flutterMimc;
  final String appAccount = "100";         // 我的账号
  String groupID = "21351198708203520";    // 操作的普通群ID
  String maxGroupID = "21360839299170304"; // 操作的无限通群ID
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
    flutterMimc = FlutterMimc.init(
      debug: true,
      appId: "xxxxxxxx",
      appKey: "xxxxxxxx",
      appSecret: "xxxxxxxx",
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
    print(messageRes.toJson());
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

  // =========监听回调==============

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



 ```


## LICENSE


    Copyright 2019 keith

    Licensed to the Apache Software Foundation (ASF) under one or more contributor
    license agreements.  See the NOTICE file distributed with this work for
    additional information regarding copyright ownership.  The ASF licenses this
    file to you under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License.  You may obtain a copy of
    the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
    License for the specific language governing permissions and limitations under
    the License.
