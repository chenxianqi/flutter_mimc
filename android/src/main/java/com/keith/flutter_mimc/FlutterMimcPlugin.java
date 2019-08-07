package com.keith.flutter_mimc;

import android.content.Context;
import android.util.Log;

import com.xiaomi.mimc.MIMCUser;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterMimcPlugin */
public class FlutterMimcPlugin implements MethodCallHandler {
  private static Context context;
  private EventChannel eventChannel;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    context = registrar.context();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_mimc");
    channel.setMethodCallHandler(new FlutterMimcPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("init")) {

      String appId = call.argument("appId");
      String appKey = call.argument("appKey");
      String appSecret = call.argument("appSecret");
      String appAccount = call.argument("appAccount");
      boolean isSuccess = MimcUserManager.getInstance().init(context, appId, appKey, appSecret, appAccount);
      result.success(isSuccess);

    }else if(call.method.equals("login")) {
      MimcUserManager.getInstance().login();
      result.success(null);
    }else if(call.method.equals("logout")) {

      MimcUserManager.getInstance().logout();

      result.success(null);
    }else if(call.method.equals("is_online")) {

      result.success(MimcUserManager.getInstance().isOnline());

    }else {
      result.notImplemented();
    }
  }



}
