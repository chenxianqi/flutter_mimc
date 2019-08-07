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

  final String appAccount = "888888";
  bool isOnline = false;

  @override
  void initState() {
    super.initState();

    // 初始化 FlutterMimc
    initFlutterMimc();

  }

  // 初始化 FlutterMimc
  void initFlutterMimc() async{
    bool initSuccess = await FlutterMimc.init({
      "appId": "2882303761517669588",
      "appKey": "5111766983588",
      "appSecret": "b0L3IOz/9Ob809v8H2FbVg==",
      "appAccount": appAccount
    });

    // 初始化成功
    if(initSuccess){
      print("初始化成功");
      login();
    }

  }

  // 登录
  void login() async{
    await FlutterMimc.login();
    isOnline = await FlutterMimc.isOnline();
    if(isOnline){
      print("登录成功");
    }else{
      print("登录失败");
    }
    setState(() {});
  }

  // 退出登录
  void logout() async{
    await FlutterMimc.logout();
    print("退出登录");
    // 获取登录状态
    isOnline = await FlutterMimc.isOnline();
    setState(() {});
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("当前账号：$appAccount,  当前状态：${isOnline ? '在线' : '离线'}"),
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: isOnline ? logout : login,
                    child: Text(isOnline ? "退出" :"登录", style: TextStyle(color: Colors.white),),
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
