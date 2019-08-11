package com.keith.flutter_mimc;
import android.content.Context;
import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.serializer.JSONSerializable;
import com.keith.flutter_mimc.utils.ConstraintsMap;
import com.xiaomi.mimc.MIMCGroupMessage;
import com.xiaomi.mimc.MIMCMessage;
import com.xiaomi.mimc.MIMCMessageHandler;
import com.xiaomi.mimc.MIMCOnlineStatusListener;
import com.xiaomi.mimc.MIMCServerAck;
import com.xiaomi.mimc.MIMCTokenFetcher;
import com.xiaomi.mimc.MIMCUnlimitedGroupHandler;
import com.xiaomi.mimc.MIMCUser;
import com.xiaomi.mimc.common.MIMCConstant;
import com.xiaomi.msg.logger.Logger;
import com.xiaomi.msg.logger.MIMCLog;
import org.json.JSONObject;

import java.util.List;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MimcUserManager {

    // 配置信息
    private long appId;
    private String appKey;
    private String appSecret;
    public String appAccount;
    private String regionKey = "REGION_CN";
    private String domain = "https://mimc.chat.xiaomi.net/";

    private Context context; // 上下文

    // 用户登录APP的帐号
    private String url;
    private MIMCUser mimcUser;
    private MIMCConstant.OnlineStatus mStatus;
    private final static MimcUserManager instance = new MimcUserManager();
    private OnHandleMIMCMsgListener onHandleMIMCMsgListener;
    private static final String TAG = "MimcUserManager";


    //  参数 初始化
    public void init(Context context, String appId, String appKey,String appSecret, String appAccount){
        try {
            this.appId = Long.parseLong(appId);
            this.appKey = appKey;
            this.appSecret = appSecret;
            this.appAccount = appAccount;
            this.context = context;
            newMIMCUser();
        }catch (Exception e){
            System.err.println(e.getMessage());
        }
    }

    // 打开日志
    void openLog(){
        MIMCLog.setLogger(new Logger() {
            @Override
            public void d(String tag, String msg) {
                Log.d(tag, msg);
            }

            @Override
            public void d(String tag, String msg, Throwable th) {
                Log.d(tag, msg, th);
            }

            @Override
            public void i(String tag, String msg) {
                Log.i(tag, msg);
            }

            @Override
            public void i(String tag, String msg, Throwable th) {
                Log.i(tag, msg, th);
            }

            @Override
            public void w(String tag, String msg) {
                Log.w(tag, msg);
            }

            @Override
            public void w(String tag, String msg, Throwable th) {
                Log.w(tag, msg, th);
            }

            @Override
            public void e(String tag, String msg) {
                Log.e(tag, msg);
            }

            @Override
            public void e(String tag, String msg, Throwable th) {
                Log.e(tag, msg, th);
            }
        });
        MIMCLog.setLogPrintLevel(MIMCLog.DEBUG);
        MIMCLog.setLogSaveLevel(MIMCLog.DEBUG);
    }


    // 登录
    public void login(){
        if(mimcUser != null){
            mimcUser.login();
        }
    }

    // 退出登录
    public void logout(){
        if(mimcUser != null){
            mimcUser.logout();
        }
    }

    // 获取登录状态
    public boolean isOnline(){
        if(mimcUser == null){
            return false;
        }
        return MIMCConstant.OnlineStatus.ONLINE == mStatus;
    }

    // 设置消息监听
    public void setHandleMIMCMsgListener(OnHandleMIMCMsgListener listener) {
        this.onHandleMIMCMsgListener = listener;
    }

    public interface OnHandleMIMCMsgListener {
        void onHandleMessage(MIMCMessage chatMsg);
        void onHandleGroupMessage(MIMCGroupMessage chatMsg);
        void onHandleStatusChanged(MIMCConstant.OnlineStatus status);
        void onHandleServerAck(MIMCServerAck serverAck);
        void onHandleSendMessageTimeout(MIMCMessage message);
        void onHandleSendGroupMessageTimeout(MIMCGroupMessage groupMessage);
        void onHandleJoinUnlimitedGroup(long topicId, int code, String errMsg);
        void onHandleQuitUnlimitedGroup(long topicId, int code, String errMsg);
        void onHandleDismissUnlimitedGroup(long topicId, int code, String errMsg);
        void onHandleCreateUnlimitedGroup(long topicId,String topicName, int code, String errMsg);

    }

    public static MimcUserManager getInstance() {
        return instance;
    }

    /**
     * 获取用户帐号
     * @return 成功返回用户帐号，失败返回""
     */
    public String getAccount() {
        return getMIMCUser() != null ? getMIMCUser().getAppAccount() : "";
    }

    /**
     * 获取当前用户token
     * @return token
     */
    public String getToken() {
        return getMIMCUser() != null ? getMIMCUser().getToken() : "";
    }


    public void addMsg(MIMCMessage chatMsg) {
        onHandleMIMCMsgListener.onHandleMessage(chatMsg);
    }

    public void addGroupMsg(MIMCGroupMessage chatMsg) {
        onHandleMIMCMsgListener.onHandleGroupMessage(chatMsg);
    }

    // 发送单聊
    public String sendMsg(String toAppAccount, byte[] payload, String bizType) {
        return mimcUser.sendMessage(toAppAccount, payload, bizType);
    }

    // 发送群聊
    public String sendGroupMsg(long groupID, byte[] payload, String bizType, boolean isUnlimitedGroup) {
        if(isUnlimitedGroup){
            return mimcUser.sendUnlimitedGroupMessage(groupID, payload, bizType);
        }else{
            return  mimcUser.sendGroupMessage(groupID, payload, bizType);
        }
    }


    /**
     * 获取用户
     * @return  返回已创建用户
     */
    public MIMCUser getMIMCUser() {
        return mimcUser;
    }

    /**
     * 创建用户
     * @return 返回新创建的用户
     */
    public MIMCUser newMIMCUser(){
        if (appAccount == null || appAccount.isEmpty() || context == null){
            System.err.println("参数错误");
            return null;
        }

        // 若是新用户，先释放老用户资源
        if (mimcUser != null) {
            mimcUser.logout();
            mimcUser.destroy();
        }

        // create new user
        mimcUser = MIMCUser.newInstance(appId, appAccount, context.getExternalFilesDir(null).getAbsolutePath());

        // 注册相关监听，必须
        mimcUser.registerTokenFetcher(new TokenFetcher());
        mimcUser.registerMessageHandler(new MessageHandler());
        mimcUser.registerOnlineStatusListener(new OnlineStatusListener());
        mimcUser.registerUnlimitedGroupHandler(new UnlimitedGroupHandler());

        return mimcUser;
    }

    // 无限群聊消息回调
    class UnlimitedGroupHandler implements MIMCUnlimitedGroupHandler {
        @Override
        public void handleCreateUnlimitedGroup(long topicId, String topicName, int code, String desc, Object obj) {
            onHandleMIMCMsgListener.onHandleCreateUnlimitedGroup(topicId, topicName, code, desc);
        }

        @Override
        public void handleJoinUnlimitedGroup(long topicId, int code, String errMsg, Object obj) {
            onHandleMIMCMsgListener.onHandleJoinUnlimitedGroup(topicId, code, errMsg);
        }

        @Override
        public void handleQuitUnlimitedGroup(long topicId, int code, String errMsg, Object obj) {
            onHandleMIMCMsgListener.onHandleQuitUnlimitedGroup(topicId, code, errMsg);
        }

        @Override
        public void handleDismissUnlimitedGroup(long topicId, int code, String errMsg, Object obj) {
            onHandleMIMCMsgListener.onHandleDismissUnlimitedGroup(topicId, code, errMsg);
        }

        @Override
        public void handleDismissUnlimitedGroup(long topicId) {

        }
    }

    // 状态回调通知
    class OnlineStatusListener implements MIMCOnlineStatusListener {
        @Override
        public void statusChange(MIMCConstant.OnlineStatus status, String type, String reason, String desc) {
            mStatus = status;
            onHandleMIMCMsgListener.onHandleStatusChanged(status);
        }
    }

    // 消息回调
    class MessageHandler implements MIMCMessageHandler {
        /**
         * 接收单聊消息
         * MIMCMessage类
         * String packetId 消息ID
         * long sequence 序列号
         * String fromAccount 发送方帐号
         * String toAccount 接收方帐号
         * byte[] payload 消息体
         * long timestamp 时间戳
         */
        @Override
        public void handleMessage(List<MIMCMessage> packets) {
            for (int i = 0; i < packets.size(); ++i) {
                MIMCMessage mimcMessage = packets.get(i);
                try {
                    addMsg(mimcMessage);
                } catch (Exception e) {
                    addMsg(mimcMessage);
                }
            }
        }

        /**
         * 接收群聊消息
         * MIMCGroupMessage类
         * String packetId 消息ID
         * long groupId 群ID
         * long sequence 序列号
         * String fromAccount 发送方帐号
         * byte[] payload 消息体
         * long timestamp 时间戳
         */
        @Override
        public void handleGroupMessage(List<MIMCGroupMessage> packets) {
            for (int i = 0; i < packets.size(); i++) {
                MIMCGroupMessage mimcGroupMessage = packets.get(i);
                try {
                    addGroupMsg(mimcGroupMessage);
                } catch (Exception e) {
                    addGroupMsg(mimcGroupMessage);
                }
            }
        }

        /**
         * 接收服务端已收到发送消息确认
         * MIMCServerAck类
         * String packetId 消息ID
         * long sequence 序列号
         * long timestamp 时间戳
         */
        @Override
        public void handleServerAck(MIMCServerAck serverAck) {
            onHandleMIMCMsgListener.onHandleServerAck(serverAck);
        }

        /**
         * 接收单聊超时消息
         * @param message 单聊消息类
         */
        @Override
        public void handleSendMessageTimeout(MIMCMessage message) {
            onHandleMIMCMsgListener.onHandleSendMessageTimeout(message);
        }

        /**
         *接收发送群聊超时消息
         * @param groupMessage 群聊消息类
         */
        @Override
        public void handleSendGroupMessageTimeout(MIMCGroupMessage groupMessage) {
            onHandleMIMCMsgListener.onHandleSendGroupMessageTimeout(groupMessage);
        }

        @Override
        public void handleSendUnlimitedGroupMessageTimeout(MIMCGroupMessage mimcGroupMessage) {

        }

        @Override
        public void handleUnlimitedGroupMessage(List<MIMCGroupMessage> packets) {
            for (int i = 0; i < packets.size(); i++) {
                MIMCGroupMessage mimcGroupMessage = packets.get(i);
                try {
                    addGroupMsg(mimcGroupMessage);
                } catch (Exception e) {
                    addGroupMsg(mimcGroupMessage);
                }
            }
        }
    }

    // TokenFetcher
    class TokenFetcher implements MIMCTokenFetcher {
        @Override
        public String fetchToken() {
            url = domain + "api/account/token";
            final ConstraintsMap params = new ConstraintsMap();
            params.putLong("appId", appId);
            params.putString("appKey", appKey);
            params.putString("appSecret", appSecret);
            params.putString("appAccount", getAccount());
            params.putString("regionKey", regionKey);
            String json = JSON.toJSONString(params.toMap());
            MediaType JSON = MediaType.parse("application/json;charset=utf-8");
            OkHttpClient client = new OkHttpClient();
            Request request = new Request
                .Builder()
                .url(url)
                .post(RequestBody.create(JSON, json))
                .build();
            Call call = client.newCall(request);
            JSONObject data = null;
            try {
                Response response = call.execute();
                data = new JSONObject(response.body().string());
                int code = data.getInt("code");
                if (code != 200) {
                    System.err.println("Error, code = " + code);
                    return null;
                }
            } catch (Exception e) {
                System.err.println("Get token exception: " + e);
            }
            return data != null ? data.toString() : null;
        }
    }

    /**
     * 创建群
     * @param groupName 群名
     * @param users 群成员，多个成员之间用英文逗号(,)分隔
     */
    public void createGroup(final String groupName, final String users, Callback responseCallback) {
        url = domain + "api/topic/" + appId;
        final ConstraintsMap params = new ConstraintsMap();
        params.putString("topicName", groupName);
        params.putString("accounts", users);
        String json = JSON.toJSONString(params.toMap());
        MediaType JSON = MediaType.parse("application/json");
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .post(RequestBody.create(JSON, json))
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 查询指定群信息
     * @param groupId 群ID
     */
    public void queryGroupInfo(final String groupId, Callback responseCallback) {
        url = domain + "api/topic/" + appId + "/" + groupId;
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .get()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 查询所属群信息
     */
    public void queryGroupsOfAccount(Callback responseCallback) {
        url = domain + "api/topic/" + appId + "/account";
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .get()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 邀请用户加入群
     * @param groupId 群ID
     * @param users 加入成员，多个成员之间用英文逗号(,)分隔
     */
    public void joinGroup(final String groupId, final String users, Callback responseCallback) {
        url = domain + "api/topic/" + appId + "/" + groupId + "/accounts";
        final ConstraintsMap params = new ConstraintsMap();
        params.putString("accounts", users);
        String json = JSON.toJSONString(params.toMap());
        MediaType JSON = MediaType.parse("application/json");
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .post(RequestBody.create(JSON, json))
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 非群主成员退群
     * @param groupId 群ID
     */
    public void quitGroup(final String groupId, Callback responseCallback) {
        url = domain + "api/topic/" + appId + "/" + groupId + "/account";
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .delete()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 群主踢成员出群
     * @param groupId 群ID
     * @param users 群成员，多个成员之间用英文逗号(,)分隔
     */
    public void kickGroup(final String groupId, final String users, Callback responseCallback) {
        url = domain + "api/topic/" + appId + "/" + groupId + "/accounts?accounts=" + users;
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .delete()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 群主更新群信息
     * @param groupId 群ID
     * @param newOwnerAccount 若为群成员则指派新的群主
     * @param newGroupName 群名
     * @param newGroupBulletin 群公告
     */
    public void updateGroup(final String groupId, final String newOwnerAccount,  final String newGroupName, final String newGroupBulletin, Callback responseCallback) {
        url = domain + "api/topic/" + appId + "/" + groupId;
        final ConstraintsMap params = new ConstraintsMap();
        if (!newOwnerAccount.isEmpty()) {
            params.putString("ownerAccount", newOwnerAccount);
        }
        if (!newGroupName.isEmpty()) {
            params.putString("topicName", newGroupName);
        }
        if (!newGroupBulletin.isEmpty()) {
            params.putString("bulletin", newGroupBulletin);
        }
        String json = JSON.toJSONString(params.toMap());
        MediaType JSON = MediaType.parse("application/json");
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .put(RequestBody.create(JSON, json))
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    /**
     * 群主销毁群
     * @param groupId 群ID
     */
    public void dismissGroup(final String groupId, Callback responseCallback) {
        url = domain + "api/topic/" + appId + "/" + groupId;
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .delete()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 拉取单聊消息记录
     * @param toAccount 接收方帐号
     * @param fromAccount 发送方帐号
     * @param utcFromTime 开始时间
     * @param utcToTime 结束时间
     * 注意：utcFromTime和utcToTime的时间间隔不能超过24小时，查询状态为[utcFromTime,utcToTime)，单位毫秒，UTC时间
     */
    public void pullP2PHistory(String toAccount, String fromAccount, String utcFromTime, String utcToTime, Callback responseCallback) {
        url = domain + "api/msg/p2p/query/";
        final ConstraintsMap params = new ConstraintsMap();
        params.putString("toAccount", toAccount);
        params.putString("fromAccount", fromAccount);
        params.putString("utcFromTime", utcFromTime);
        params.putString("utcToTime", utcToTime);
        String json = JSON.toJSONString(params.toMap());
        MediaType JSON = MediaType.parse("application/json;charset=UTF-8");
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("Accept", "application/json;charset=UTF-8")
                .addHeader("token", mimcUser.getToken())
                .post(RequestBody.create(JSON, json))
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 拉取群聊消息记录
     * @param account 拉取者帐号
     * @param topicId 群ID
     * @param utcFromTime 开始时间
     * @param utcToTime 结束时间
     * 注意：utcFromTime和utcToTime的时间间隔不能超过24小时，查询状态为[utcFromTime,utcToTime)，单位毫秒，UTC时间
     */
    public void pullP2THistory(String account, String topicId, String utcFromTime, String utcToTime, Callback responseCallback) {
        url = domain + "api/msg/p2t/query/";
        final ConstraintsMap params = new ConstraintsMap();
        params.putString("account", account);
        params.putString("topicId", topicId);
        params.putString("utcFromTime", utcFromTime);
        params.putString("utcToTime", utcToTime);
        String json = JSON.toJSONString(params.toMap());
        MediaType JSON = MediaType.parse("application/json;charset=UTF-8");
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("Accept", "application/json;charset=UTF-8")
                .addHeader("token", mimcUser.getToken())
                .post(RequestBody.create(JSON, json))
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /** 创建无限大群
     * @param topicName 群名
     * @param context 用户自定义传入的对象，通过回调函数原样传出
     */
    public void createUnlimitedGroup(String topicName, Object context) {
        mimcUser.createUnlimitedGroup(topicName, context);
    }

    /** 加入无限大群
     * @param topicId 群ID
     * @param context 用户自定义传入的对象，通过回调函数原样传出
     * @return String 客户端生成的消息ID
     */
    public String joinUnlimitedGroup(long topicId, Object context) {
        return mimcUser.joinUnlimitedGroup(topicId, context);
    }

    /** 退出无限大群
     * @param topicId 群ID
     * @param context 用户自定义传入的对象，通过回调函数原样传出
     * @return 客户端生成的消息ID
     */
    public String quitUnlimitedGroup(long topicId, Object context) {
        return mimcUser.quitUnlimitedGroup(topicId, context);
    }

    /** 解散无限大群
     * @param topicId 群ID
     * @param context  用户自定义传入的对象，通过回调函数原样传出
     */
    public void dismissUnlimitedGroup(long topicId, Object context) {
        mimcUser.dismissUnlimitedGroup(topicId, context);
    }

    /**
     * 查询无限大群成员
     * @param topicId 群ID
     */
    public void queryUnlimitedGroupMembers(long topicId, Callback responseCallback) {
        url = domain + "/api/uctopic/userlist";
        OkHttpClient client = new OkHttpClient();
        final Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .addHeader("topicId", String.valueOf(topicId))
                .get()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 查询无限大群所属群
     */
    public void queryUnlimitedGroups(Callback responseCallback) {
        String url = domain + "/api/uctopic/topics";
        OkHttpClient client = new OkHttpClient();
        final Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .get()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 查询无限大群在线用户数
     * @param topicId
     */
    public void queryUnlimitedGroupOnlineUsers(long topicId, Callback responseCallback) {
        url = domain + "/api/uctopic/onlineinfo";
        OkHttpClient client = new OkHttpClient();
        final Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .addHeader("topicId", String.valueOf(topicId))
                .get()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 查询无限大群基本信息
     * @param topicId
     */
    public void queryUnlimitedGroupInfo(long topicId, Callback responseCallback) {
        url = domain + "/api/uctopic/topic";
        OkHttpClient client = new OkHttpClient();
        final Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .addHeader("topicId", String.valueOf(topicId))
                .get()
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 更新大群
     * @param topicId
     * @param newGroupName
     * @param newOwnerAccount
     * 更新群，topicId必填，其他参数必填一个
     * 必须群主才能转让群，更新群信息，转让群主需要被转让用户在群中
     */
    public void updateUnlimitedGroup(long topicId, String newGroupName, String newOwnerAccount, Callback responseCallback) {
        url = domain + "/api/uctopic/update";
        final ConstraintsMap params = new ConstraintsMap();
        params.putLong("topicId", topicId);
        if (!newOwnerAccount.isEmpty()) {
            params.putString("ownerAccount", newOwnerAccount);
        }
        if (!newGroupName.isEmpty()) {
            params.putString("topicName", newGroupName);
        }
        String json = JSON.toJSONString(params.toMap());
        System.out.println(json);
        MediaType JSON = MediaType.parse("application/json");
        OkHttpClient client = new OkHttpClient();
        Request request = new Request
                .Builder()
                .url(url)
                .addHeader("token", mimcUser.getToken())
                .post(RequestBody.create(JSON, json))
                .build();
        try {
            Call call = client.newCall(request);
            call.enqueue(responseCallback);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }


}