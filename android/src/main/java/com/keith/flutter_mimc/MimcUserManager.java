package com.keith.flutter_mimc;
import com.alibaba.fastjson.JSON;
import com.xiaomi.mimc.MIMCGroupMessage;
import com.xiaomi.mimc.MIMCMessage;
import com.xiaomi.mimc.MIMCMessageHandler;
import com.xiaomi.mimc.MIMCOnlineMessageAck;
import com.xiaomi.mimc.MIMCOnlineStatusListener;
import com.xiaomi.mimc.MIMCServerAck;
import com.xiaomi.mimc.MIMCTokenFetcher;
import com.xiaomi.mimc.MIMCUnlimitedGroupHandler;
import com.xiaomi.mimc.MIMCUser;
import com.xiaomi.mimc.common.MIMCConstant;


import java.util.List;

class MIMCUserManager {

    // 配置信息
    private long appId;
    private String appAccount;

    // 用户登录APP的帐号
    private static String tokenString;
    private  MIMCUser mimcUser;
    private MIMCConstant.OnlineStatus mStatus;
    private final static MIMCUserManager instance = new MIMCUserManager();
    private OnHandleMIMCMsgListener onHandleMIMCMsgListener;

    //  通过服务的鉴权获得的String 初始化
    void init(String tokenString){
        try {
            MIMCUserManager.tokenString = tokenString;
            com.alibaba.fastjson.JSONObject tokenMap = JSON.parseObject(tokenString);
            this.appId = Long.parseLong(tokenMap.getJSONObject("data").getString("appId"));
            this.appAccount = tokenMap.getJSONObject("data").getString("appAccount");
            newMIMCUser();
        }catch (Exception e){
            System.err.println(e.getMessage());
        }
    }

    // 登录
    void login(){
        if(mimcUser != null){
            mimcUser.login();
        }
    }

    // 退出登录
    void logout(){
        if(mimcUser != null){
            mimcUser.logout();
        }
    }

    // 获取appId
    String getAppId(){
        return String.valueOf(appId);
    }

    // 获取登录状态
    boolean isOnline(){
        if(mimcUser == null){
            return false;
        }
        return MIMCConstant.OnlineStatus.ONLINE == mStatus;
    }

    // 设置消息监听
    void setHandleMIMCMsgListener(OnHandleMIMCMsgListener listener) {
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
        void onHandleCreateUnlimitedGroup(long topicId, String topicName, int code, String errMsg);
        void onHandleSendUnlimitedGroupMessageTimeout(MIMCGroupMessage groupMessage);
        void onHandleOnlineMessage(MIMCMessage message);
        void handleOnlineMessageAck(MIMCOnlineMessageAck mimcOnlineMessageAck);
        void onPullNotification();
    }

    static MIMCUserManager getInstance() {
        return instance;
    }

    /**
     * 获取用户帐号
     * @return 成功返回用户帐号，失败返回""
     */
    String getAccount() {
        return getMIMCUser() != null ? getMIMCUser().getAppAccount() : "";
    }

    /**
     * 获取当前用户token
     * @return token
     */
    String getToken() {
        return getMIMCUser() != null ? getMIMCUser().getToken() : "";
    }


    private void addMsg(MIMCMessage chatMsg) {
        onHandleMIMCMsgListener.onHandleMessage(chatMsg);
    }

    private void addGroupMsg(MIMCGroupMessage chatMsg) {
        onHandleMIMCMsgListener.onHandleGroupMessage(chatMsg);
    }

    // 发送单聊
    String sendMsg(String toAppAccount, byte[] payload, String bizType,boolean isStore) {
        return mimcUser.sendMessage(toAppAccount, payload, bizType,isStore);
    }

    // 发送在线消息
    String sendOnlineMsg(String toAppAccount, byte[] payload, String bizType) {
        return mimcUser.sendOnlineMessage(toAppAccount, payload, bizType);
    }

    // 发送群聊
    String sendGroupMsg(long groupID, byte[] payload, String bizType, boolean isUnlimitedGroup) {
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
    private MIMCUser getMIMCUser() {
        return mimcUser;
    }

    /**
     * 创建用户
     */
    private void newMIMCUser(){
        if (appAccount == null || appAccount.isEmpty()){
            System.err.println("参数错误");
            return;
        }
        // 若是新用户，先释放老用户资源
        if (mimcUser != null) {
            mimcUser.logout();
            mimcUser.destroy();
        }

        // create new user
        mimcUser = MIMCUser.newInstance(appId, appAccount, null);

        // 注册相关监听，必须
        mimcUser.registerTokenFetcher(new TokenFetcherString());
        mimcUser.registerMessageHandler(new MessageHandler());
        mimcUser.registerOnlineStatusListener(new OnlineStatusListener());
        mimcUser.registerUnlimitedGroupHandler(new UnlimitedGroupHandler());

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
        public void handleDismissUnlimitedGroup(long l) {

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
         * @return bool
         */
        @Override
        public boolean handleMessage(List<MIMCMessage> packets) {
            for (int i = 0; i < packets.size(); ++i) {
                MIMCMessage mimcMessage = packets.get(i);
                try {
                    addMsg(mimcMessage);
                } catch (Exception e) {
                    addMsg(mimcMessage);
                }
            }
            return true;
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
         * @return bool
         */
        @Override
        public boolean handleGroupMessage(List<MIMCGroupMessage> packets) {
            for (int i = 0; i < packets.size(); i++) {
                MIMCGroupMessage mimcGroupMessage = packets.get(i);
                try {
                    addGroupMsg(mimcGroupMessage);
                } catch (Exception e) {
                    addGroupMsg(mimcGroupMessage);
                }
            }
            return true;
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
            onHandleMIMCMsgListener.onHandleSendUnlimitedGroupMessageTimeout(mimcGroupMessage);
        }

        @Override
        public boolean onPullNotification() {
            onHandleMIMCMsgListener.onPullNotification();
            return true;
        }

        @Override
        public void handleOnlineMessage(MIMCMessage mimcMessage) {
            onHandleMIMCMsgListener.onHandleOnlineMessage(mimcMessage);
        }

        @Override
        public void handleOnlineMessageAck(MIMCOnlineMessageAck mimcOnlineMessageAck) {
            onHandleMIMCMsgListener.handleOnlineMessageAck(mimcOnlineMessageAck);
        }

        @Override
        public boolean handleUnlimitedGroupMessage(List<MIMCGroupMessage> packets) {
            for (int i = 0; i < packets.size(); i++) {
                MIMCGroupMessage mimcGroupMessage = packets.get(i);
                try {
                    addGroupMsg(mimcGroupMessage);
                } catch (Exception e) {
                    addGroupMsg(mimcGroupMessage);
                }
            }
            return true;
        }
    }

    // TokenFetcherString
    static class TokenFetcherString implements MIMCTokenFetcher {
        @Override
        public String fetchToken() {
            return MIMCUserManager.tokenString;
        }
    }

    /** 创建无限大群
     * @param topicName 群名
     *
     */
    void createUnlimitedGroup(String topicName) {
        mimcUser.createUnlimitedGroup(topicName, null);
    }

    /** 加入无限大群
     * @param topicId 群ID
     * @return String 客户端生成的消息ID
     */
    String joinUnlimitedGroup(long topicId) {
        return mimcUser.joinUnlimitedGroup(topicId, null);
    }

    /** 退出无限大群
     * @param topicId 群ID
     * @return 客户端生成的消息ID
     */
    String quitUnlimitedGroup(long topicId) {
        return mimcUser.quitUnlimitedGroup(topicId, null);
    }

    /** 解散无限大群
     * @param topicId 群ID
     *
     */
    void dismissUnlimitedGroup(long topicId) {
        mimcUser.dismissUnlimitedGroup(topicId, null);
    }

}