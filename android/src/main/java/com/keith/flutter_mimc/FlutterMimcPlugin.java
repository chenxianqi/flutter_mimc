package com.keith.flutter_mimc;

import android.content.Context;
import android.util.Log;

import com.keith.flutter_mimc.utils.ConstraintsMap;
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
  private final Context context;
  private final Registrar registrar;
  private final MethodChannel channel;
  private EventChannel.EventSink eventSink = null;

  private EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
    @Override
    public void onListen(Object o, EventChannel.EventSink sink)
    {
      eventSink = sink;
      MimcUserManager.setEventSink(sink);
    }

    @Override
    public void onCancel(Object o)
    {
      eventSink = null;
    }
  };

  private FlutterMimcPlugin(Registrar registrar, MethodChannel channel)
  {
    this.registrar = registrar;
    this.channel = channel;
    this.context = registrar.context();
    EventChannel eventChannel = new EventChannel(registrar.messenger(), "flutter_mimc.event");
    eventChannel.setStreamHandler(streamHandler);
  }


  public static void registerWith(Registrar registrar)
  {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_mimc");
    channel.setMethodCallHandler(new FlutterMimcPlugin(registrar, channel));

  }

  @Override
  public void onMethodCall(MethodCall call, Result result)
  {
    if (call.method.equals("init")) {

      String appId = call.argument("appId");
      String appKey = call.argument("appKey");
      String appSecret = call.argument("appSecret");
      String appAccount = call.argument("appAccount");
      MimcUserManager.getInstance().init(context, appId, appKey, appSecret, appAccount);
      result.success(null);

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
