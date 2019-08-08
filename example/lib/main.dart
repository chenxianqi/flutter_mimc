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
  final String appAccount = "10315";
  bool isOnline = false;
  List<Map<String, String>> logs = [];

  @override
  void initState() {
    super.initState();

    // 初始化 FlutterMimc
    initFlutterMimc();
//    initWithTokenFlutterMimc();

  }

  // 通过参数实例化
  void initFlutterMimc() async{
    flutterMimc = FlutterMimc.init({
      "appId": "2882303761517669588",
      "appKey": "5111766983588",
      "appSecret": "b0L3IOz/9Ob809v8H2FbVg==",
      "appAccount": appAccount
    });
    addLog("init==实例化完成");
    listener();
  }

  // 通过服务端生成原样返回的数据token，实例化
  void initWithTokenFlutterMimc() async{
    // http get token
    String tokenString = '{"code":200,"message":"success","data":{"appId":"2882303761517669588","appPackage":"com.xiaomi.mimcdemo","appAccount":"10315","miChid":9,"miUserId":"21304982171287553","miUserSecurityKey":"RkIyO1qaN1YB0omFM4E5tQ==","token":"bJRLeg7AgtSh0T13YjL\/IFDdK0JTjCJG4KdSfB9L7c0N56uq0EiflNyh2H5qmlOwqeOEcudSjEicejSfy+BJz2ui\/bkYYYPpT9rKkuChjVDMAXpIv1L7ItYzsCaYjygYQD\/FuVQ+0xiiFJqDudzL2vHwjH\/X7NJbH7JCqycZkfVvhFrrVJatrUOKHDsHlZZuzSdaTD9EZTsCIN7heUaKLHqRxyFGPmynxpmkAYj\/HCOOb\/mVNa\/tFeafWqArXAv57V4MH+X2Bk6V7gIXJNvNk+am9l9KtVFqfTomqU4pkpypMHyUfD1H2qBQPO63xOEN4yFfutQx4SX2qREZJ0nAi77s7tGl8YkTBv\/KxMr8Js2nZljqe3TODbeatLigYI8+xzY6PyqfigT4+KNOFzmrFRina623MclbU9vYLJM7672KprimiNg\/YC3+qUCsWJKcqXtHSVb0GrYH9JVcZcU1Hg==","regionBucket":154,"feDomainName":"app.chat.xiaomi.net","relayDomainName":"relay.mimc.chat.xiaomi.net"}}';
    flutterMimc = FlutterMimc.initWithToken(tokenString);
    addLog("initWithToken==实例化完成");
    listener();
  }

  // 登录
  void login() async{
    await flutterMimc.login();
  }

  // add log
  addLog(String content){
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
    await FlutterMimc.logout();
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
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("当前账号：$appAccount,  当前状态：${isOnline ? '在线' : '离线'}"),
                ],
              ),
              Container(
                width: double.infinity,
                height: 300.0,
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
              )
            ],
          )
        )
      ),
    );
  }
}
