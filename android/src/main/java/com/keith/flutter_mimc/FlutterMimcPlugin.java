package com.keith.flutter_mimc;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterMimcPlugin */
public class FlutterMimcPlugin implements FlutterPlugin, MethodCallHandler {

  static EventChannel.EventSink eventSink = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    System.out.println("FlutterPluginBinding");
    MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_mimc");
    channel.setMethodCallHandler(new FlutterMimcPlugin());
    EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_mimc.event");
    eventChannel.setStreamHandler(streamHandler);
    new MIMCHandleMIMCMsgListener();
  }

  public void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_mimc");
    channel.setMethodCallHandler(new FlutterMimcPlugin());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

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

  // MethodChannel.Result wrapper that responds on the platform thread.
  private static class MethodResultWrapper implements Result {
    private Result methodResult;
    private Handler handler;

    MethodResultWrapper(Result result) {
      methodResult = result;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  methodResult.success(result);
                }
              });
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  methodResult.error(errorCode, errorMessage, errorDetails);
                }
              });
    }

    @Override
    public void notImplemented() {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  methodResult.notImplemented();
                }
              });
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

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result rawResult) {

    final Result result = new MethodResultWrapper(rawResult);
    MIMCUserManager mimcUserManager = MIMCUserManager.getInstance();
    // 初始化
    switch (call.method) {

      // 通过服务端的鉴权获得的String 初始化
      case "init": {
        String token = call.argument("token");
        mimcUserManager.init(token);
        result.success(null);
        break;
      }

      // 发送单聊
      case "sendMessage": {
        String toAccount = call.argument("toAccount");
        String bizType = call.argument("bizType");
        String payload = call.argument("payload");
        boolean isStore = call.argument("isStore");

        assert payload != null;
        result.success(mimcUserManager.sendMsg(toAccount, payload.getBytes(), bizType,isStore));
        break;
      }

      // 发送在线消息
      case "sendOnLineMessage": {
        String toAccount = call.argument("toAccount");
        String bizType = call.argument("bizType");
        String payload = call.argument("payload");
        assert payload != null;
        result.success(mimcUserManager.sendOnlineMsg(toAccount, payload.getBytes(), bizType));
        break;
      }

      // 发送群聊
      case "sendGroupMsg": {
        boolean isUnlimitedGroup = call.argument("isUnlimitedGroup");
        Map<String, Object> message = call.argument("message");
        assert message != null;
        long topicId = Long.parseLong(Objects.requireNonNull(message.get("topicId")).toString());
        String payload = Objects.requireNonNull(message.get("payload")).toString();
        String bizType = Objects.requireNonNull(message.get("bizType")).toString();
        result.success(mimcUserManager.sendGroupMsg(topicId, payload.getBytes(), bizType, isUnlimitedGroup));

        break;
      }

      // 登录
      case "login":
        System.out.println("login");
        mimcUserManager.login();
        result.success(null);

        break;

      // 退出登录
      case "logout":
        mimcUserManager.logout();
        result.success(null);

        break;

      // 在线状态
      case "isOnline":
        result.success(mimcUserManager.isOnline());
        break;

      // 获取token
      case "getToken":
        result.success(mimcUserManager.getToken());
        break;

      // 获取appId
      case "getAppID":
        result.success(mimcUserManager.getAppId());
        break;

      // 获取账号
      case "getAccount":
        result.success(mimcUserManager.getAccount());
        break;

      // 创建无限大群
      case "createUnlimitedGroup":
        String topicName = call.argument("topicName");
        mimcUserManager.createUnlimitedGroup(topicName);
        result.success(null);
        break;

      // 加入无限大群
      case "joinUnlimitedGroup": {
        String topicId = call.argument("topicId");
        assert topicId != null;
        result.success(mimcUserManager.joinUnlimitedGroup(Long.parseLong(topicId)));
        break;
      }

      // 退出无限大群
      case "quitUnlimitedGroup": {
        String topicId = call.argument("topicId");
        assert topicId != null;
        result.success(mimcUserManager.quitUnlimitedGroup(Long.parseLong(topicId)));
        break;
      }

      // 解散无限大群
      case "dismissUnlimitedGroup": {
        String topicId = call.argument("topicId");
        assert topicId != null;
        mimcUserManager.dismissUnlimitedGroup(Long.parseLong(topicId));
        result.success(null);
        break;
      }

      // 其他
      default:
        result.notImplemented();
        break;
    }
  }






}
