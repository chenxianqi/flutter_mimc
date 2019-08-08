package com.keith.flutter_mimc;
import android.os.Handler;
import android.os.Looper;
import android.content.Context;

import com.alibaba.fastjson.JSONObject;

import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterMimcPlugin */
public class FlutterMimcPlugin implements MethodCallHandler{
  private final Context context;
  private final Registrar registrar;
  private final MethodChannel channel;
  public static EventChannel.EventSink eventSink = null;

  private static class MainThreadEventSink implements EventChannel.EventSink    {
        private EventChannel.EventSink _eventSink;
        private Handler handler;

        MainThreadEventSink(EventChannel.EventSink sink) {
            this._eventSink = sink;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object o) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    _eventSink.success(o);
                }
            });
        }

        @Override
        public void error(final String s, final String s1, final Object o) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    _eventSink.error(s, s1, o);
                }
            });
        }

      @Override
      public void endOfStream() {
      }
  }


  private EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
    @Override
    public void onListen(Object o, EventChannel.EventSink sink)
    {
        eventSink = new MainThreadEventSink(sink);
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
    new MimcHandleMIMCMsgListener();
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

    }
    else if(call.method.equals("initWithToken")) {

        String tokenString = call.argument("token");
        MimcUserManager.getInstance().initWithToken(context, tokenString);
        result.success(null);

    }
    else if(call.method.equals("sendMessage"))
    {

        System.out.println(call.arguments);
        String toAccount = call.argument("toAccount");
        String bizType = call.argument("bizType");
        Map<String, Object> message = call.argument("message");
        byte[] payload = JSONObject.toJSONBytes(message);
        MimcUserManager.getInstance().sendMsg(toAccount, payload, bizType);
        result.success(null);

    }
    else if(call.method.equals("login"))
    {

        MimcUserManager.getInstance().login();
        result.success(null);

    }
    else if(call.method.equals("logout"))
    {

      MimcUserManager.getInstance().logout();
      result.success(null);

    }
    else if(call.method.equals("isOnline"))
    {

      result.success(MimcUserManager.getInstance().isOnline());

    }
    else {
      result.notImplemented();
    }
  }



}
