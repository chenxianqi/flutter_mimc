import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mimc/flutter_mimc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FlutterMimc flutterMimc;
  final String appAccount = "100";
  bool isOnline = false;

  @override
  void initState() {
    super.initState();

    // 初始化 FlutterMimc
    initFlutterMimc();

    // 监听登录状态
    print(flutterMimc);
    flutterMimc.onStatusChangedListener().listen((status){
      isOnline = status;
      if(status){
        debugPrint("登录成功");
      }else{
        debugPrint("登录失败");
      }
      setState(() {});
    }).onError((err){
      print(err);
    });

  }

  // 初始化 FlutterMimc
  void initFlutterMimc() async{
    flutterMimc = FlutterMimc.init({
      "appId": "2882303761517669588",
      "appKey": "5111766983588",
      "appSecret": "b0L3IOz/9Ob809v8H2FbVg==",
      "appAccount": appAccount
    });
  }

  // 登录
  void login() async{
    await flutterMimc.login();
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
        ),
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("当前账号：$appAccount,  当前状态：${isOnline ? '在线' : '离线'}"),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: login,
                    child: Text("登录", style: TextStyle(color: Colors.white),),
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: logout,
                    child: Text("退出", style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ],
          )
        )
      ),
    );
  }
}
