package com.keith.flutter_mimc;
import android.content.Context;
import android.util.Log;
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

import java.io.IOException;
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
        void onHandleDismissUnlimitedGroup(String json, boolean isSuccess);


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
    public void sendGroupMsg(long groupID, byte[] content, String bizType, boolean isUnlimitedGroup) {
//        mimcUser.sendUnlimitedGroupMessage(groupID, json.getBytes(), bizType);
//        mimcUser.sendGroupMessage(groupID, json.getBytes(), bizType);
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
            Log.i(TAG, String.format("handleCreateUnlimitedGroup topicId:%d topicName:%s code:%d errMsg:%s", topicId, topicName, code, desc));
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
            onHandleMIMCMsgListener.onHandleDismissUnlimitedGroup(errMsg, false);
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
            /**
             * fetchToken()由SDK内部线程调用，获取小米Token服务器返回的JSON字符串
             * 本MimcDemo直接从小米Token服务器获取JSON串，只解析出键data对应的值返回即可，切记！！！
             * 强烈建议，APP从自己服务器获取data对应的JSON串，APP自己的服务器再从小米Token服务器获取，以防appKey和appSecret泄漏
             */

            url = domain + "api/account/token";
            String appAccount = getAccount();
            String json = "{\"appId\":" + appId + ",\"appKey\":\"" + appKey + "\",\"appSecret\":\"" +
                    appSecret + "\",\"appAccount\":\"" + appAccount + "\",\"regionKey\":\"" + regionKey + "\"}";
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
            Log.d("token====", data.toString());
            return data != null ? data.toString() : null;
        }
    }

}