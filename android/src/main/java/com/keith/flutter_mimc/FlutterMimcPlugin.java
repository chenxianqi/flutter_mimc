package com.keith.flutter_mimc;
import android.os.Handler;
import android.os.Looper;
import android.content.Context;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.keith.flutter_mimc.utils.ConstraintsMap;

import java.io.IOException;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Response;

/** FlutterMimcPlugin */
public class FlutterMimcPlugin implements MethodCallHandler{
  private final Context context;
  private static Registrar registrar;
  private static MethodChannel channel;
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
  public void onMethodCall(MethodCall call, Result rawResult)
  {
    final Result result = new MethodResultWrapper(rawResult);

    // 初始化
    if (call.method.equals("init")) {

      String appId = call.argument("appId");
      String appKey = call.argument("appKey");
      String appSecret = call.argument("appSecret");
      String appAccount = call.argument("appAccount");
      Boolean isDebug = call.argument("debug");
      if(isDebug){
          MimcUserManager.getInstance().openLog();
      }
      MimcUserManager.getInstance().init(context, appId, appKey, appSecret, appAccount);
      result.success(null);

    }

    // 发送单聊
    else if(call.method.equals("sendMessage"))
    {
        String toAccount = call.argument("toAccount");
        String bizType = call.argument("bizType");
        String payload = call.argument("payload");
        assert payload != null;
        MimcUserManager.getInstance().sendMsg(toAccount, payload.getBytes(), bizType);
        result.success(null);

    }

    // 发送群聊
    else if(call.method.equals("sendGroupMsg"))
    {
        boolean isUnlimitedGroup = call.argument("isUnlimitedGroup");
        Map<String, Object> message = call.argument("message");
        assert message != null;
        long topicId = Long.parseLong(Objects.requireNonNull(message.get("topicId")).toString());
        String payload = Objects.requireNonNull(message.get("payload")).toString();
        String bizType = Objects.requireNonNull(message.get("bizType")).toString();
        MimcUserManager.getInstance().sendGroupMsg(topicId, payload.getBytes(), bizType, isUnlimitedGroup);
        result.success(null);

    }

    // 登录
    else if(call.method.equals("login"))
    {

        MimcUserManager.getInstance().login();
        result.success(null);

    }

    // 退出登录
    else if(call.method.equals("logout"))
    {

      MimcUserManager.getInstance().logout();
      result.success(null);

    }

    // 在线状态
    else if(call.method.equals("isOnline"))
    {

      result.success(MimcUserManager.getInstance().isOnline());

    }

    // 获取token
    else if(call.method.equals("getToken"))
    {

        result.success(MimcUserManager.getInstance().getToken());

    }

    // 获取账号
    else if(call.method.equals("getAccount"))
    {

        result.success(MimcUserManager.getInstance().getAccount());

    }

    //创建一个普通群
    else if(call.method.equals("createGroup"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String groupName = call.argument("groupName");
            String users = call.argument("users");
            if (groupName == null || groupName.isEmpty()) {
                params.putString("message", "groupName不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().createGroup(groupName,users,new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {
                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putBoolean("success", false);
                            params.putNull("data");
                        }
                        result.success(params.toMap());
                    }
                }
                }
            );
        }catch (Exception e){
            params.putString("error", e.getMessage());
            params.putNull("data");
            result.success(params.toMap());
        }

    }

    //查询指定群信息
    else if(call.method.equals("queryGroupInfo"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String groupId = call.argument("groupId");
            if (groupId == null || groupId.isEmpty()) {
                params.putString("message", "groupId不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().queryGroupInfo(groupId,new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {
                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("error", e.getMessage());
            params.putNull("data");
            result.success(params.toMap());
        }

    }

    //查询所属群信息
    else if(call.method.equals("queryGroupsOfAccount"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            MimcUserManager.getInstance().queryGroupsOfAccount(new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putBoolean("success", false);
                    params.putNull("data");
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {
                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putArray("data", json.getJSONArray("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    //邀请用户加入群
    else if(call.method.equals("joinGroup"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String groupId = call.argument("groupId");
            String users = call.argument("users");
            if (groupId == null || groupId.isEmpty() || users == null || users.isEmpty()) {
                params.putString("message", "groupId或users不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().joinGroup(groupId,users,new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {
                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putBoolean("success", false);
                            params.putNull("data");
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    //非群主成员退群
    else if(call.method.equals("quitGroup"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String groupId = call.argument("groupId");
            if (groupId == null || groupId.isEmpty()) {
                params.putString("message", "groupId不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().quitGroup(groupId,new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putBoolean("success", false);
                    params.putNull("data");
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {
                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putNull("data");
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 群主踢成员出群
    else if(call.method.equals("kickGroup"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String groupId = call.argument("groupId");
            String users = call.argument("users");
            if (groupId == null || groupId.isEmpty() || users == null || users.isEmpty()) {
                params.putString("message", "groupId或users不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().kickGroup(groupId, users,new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putBoolean("success", false);
                            params.putNull("data");
                        }
                        result.success(params.toMap());

                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 群主更新群信息
    else if(call.method.equals("updateGroup"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String groupId = call.argument("groupId");
            String newOwnerAccount = call.argument("newOwnerAccount");
            String newGroupName = call.argument("newGroupName");
            String newGroupBulletin = call.argument("newGroupBulletin");
            if (groupId == null || groupId.isEmpty()) {
                params.putString("message", "groupId不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().updateGroup(groupId, newOwnerAccount, newGroupName, newGroupBulletin, new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putBoolean("success", false);
                            params.putNull("data");
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 群主销毁群
    else if(call.method.equals("dismissGroup"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String groupId = call.argument("groupId");
            if (groupId == null || groupId.isEmpty()) {
                params.putString("message", "groupId不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().dismissGroup(groupId, new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putNull("data");
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 拉取单聊消息记录
    else if(call.method.equals("pullP2PHistory"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String toAccount = call.argument("toAccount");
            String fromAccount = call.argument("fromAccount");
            String utcFromTime = call.argument("utcFromTime");
            String utcToTime = call.argument("utcToTime");
            if (toAccount == null || toAccount.isEmpty() ||
                    fromAccount == null || fromAccount.isEmpty() ||
                    utcFromTime == null || utcFromTime.isEmpty() ||
                    utcToTime == null || utcToTime.isEmpty()) {
                params.putString("message", "所有参数不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().pullP2PHistory(toAccount, fromAccount, utcFromTime, utcToTime, new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 拉取群聊消息记录
    else if(call.method.equals("pullP2THistory"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String account = call.argument("account");
            String topicId = call.argument("topicId");
            String utcFromTime = call.argument("utcFromTime");
            String utcToTime = call.argument("utcToTime");
            if (account == null || account.isEmpty() ||
                    topicId == null || topicId.isEmpty() ||
                    utcFromTime == null || utcFromTime.isEmpty() ||
                    utcToTime == null || utcToTime.isEmpty()) {
                params.putString("message", "所有参数不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().pullP2THistory(account, topicId, utcFromTime, utcToTime, new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 创建无限大群
    else if(call.method.equals("createUnlimitedGroup"))
    {
        String topicName = call.argument("topicName");
        MimcUserManager.getInstance().createUnlimitedGroup(topicName, null);
        result.success(null);
    }

    // 加入无限大群
    else if(call.method.equals("joinUnlimitedGroup"))
    {
        String topicId = call.argument("topicId");
        result.success(MimcUserManager.getInstance().joinUnlimitedGroup(Long.parseLong(topicId), null));
    }

    // 退出无限大群
    else if(call.method.equals("quitUnlimitedGroup"))
    {
        String topicId = call.argument("topicId");
        result.success(MimcUserManager.getInstance().quitUnlimitedGroup(Long.parseLong(topicId), null));
    }

    // 解散无限大群
    else if(call.method.equals("dismissUnlimitedGroup"))
    {
        String topicId = call.argument("topicId");
        MimcUserManager.getInstance().dismissUnlimitedGroup(Long.parseLong(topicId), null);
        result.success(null);
    }

    // 查询无限大群成员
    else if(call.method.equals("queryUnlimitedGroupMembers"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String topicId = call.argument("topicId");
            if (topicId == null || topicId.isEmpty()) {
                params.putString("message", "topicId参数不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
                MimcUserManager.getInstance().queryUnlimitedGroupMembers(Long.parseLong(topicId), new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        System.out.println(json);
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 查询无限大群所属群
    else if(call.method.equals("queryUnlimitedGroups"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            MimcUserManager.getInstance().queryUnlimitedGroups(new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putArray("data", json.getJSONArray("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 查询无限大群在线用户数
    else if(call.method.equals("queryUnlimitedGroupOnlineUsers"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String topicId = call.argument("topicId");
            if (topicId == null || topicId.isEmpty()) {
                params.putString("message", "topicId参数不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().queryUnlimitedGroupOnlineUsers(Long.parseLong(topicId), new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 查询无限大群基本信息
    else if(call.method.equals("queryUnlimitedGroupInfo"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String topicId = call.argument("topicId");
            if (topicId == null || topicId.isEmpty()) {
                params.putString("message", "topicId参数不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().queryUnlimitedGroupInfo(Long.parseLong(topicId), new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 更新无限大群
    else if(call.method.equals("updateUnlimitedGroup"))
    {
        final  ConstraintsMap params = new ConstraintsMap();
        try {
            String topicId = call.argument("topicId");
            String newGroupName = call.argument("newGroupName");
            String newOwnerAccount = call.argument("newOwnerAccount");
            if (topicId == null || topicId.isEmpty()) {
                params.putString("message", "topicId参数不能为空！");
                params.putNull("data");
                params.putBoolean("success", false);
                result.success(params.toMap());
                return;
            }
            MimcUserManager.getInstance().updateUnlimitedGroup(Long.parseLong(topicId), newGroupName, newOwnerAccount, new Callback() {
                @Override
                public void onFailure(Call c, IOException e) {
                    params.putString("message", e.getMessage());
                    params.putNull("data");
                    params.putBoolean("success", false);
                    result.success(params.toMap());
                }
                @Override
                public void onResponse(Call c, Response response) throws IOException {
                    if (response.isSuccessful()) {

                        JSONObject json = JSONObject.parseObject(response.body().string());
                        if(json.getInteger("code") == 200){
                            params.putNull("message");
                            params.putBoolean("success", true);
                            params.putMap("data", json.getJSONObject("data"));
                        }else{
                            params.putString("message", json.getString("message"));
                            params.putNull("data");
                            params.putBoolean("success", false);
                        }
                        result.success(params.toMap());
                    }
                }}
            );
        }catch (Exception e){
            params.putString("message", e.getMessage());
            params.putNull("data");
            params.putBoolean("success", false);
            result.success(params.toMap());
        }

    }

    // 其他
    else {
      result.notImplemented();
    }
  }



}
