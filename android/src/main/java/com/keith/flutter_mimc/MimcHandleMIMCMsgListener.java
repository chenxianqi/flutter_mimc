package com.keith.flutter_mimc;
import com.keith.flutter_mimc.utils.ConstraintsMap;
import com.xiaomi.mimc.MIMCGroupMessage;
import com.xiaomi.mimc.MIMCMessage;
import com.xiaomi.mimc.MIMCServerAck;
import com.xiaomi.mimc.common.MIMCConstant;
import com.alibaba.fastjson.JSONObject;

public class MimcHandleMIMCMsgListener implements MimcUserManager.OnHandleMIMCMsgListener {
    MimcHandleMIMCMsgListener(){
        MimcUserManager.getInstance().setHandleMIMCMsgListener(this);
    }


    // 消息处理
    private void eventSinkPushMessage(String eventType, MIMCMessage msg, MIMCGroupMessage gmsg){
        try {
            long timestamp;
            String bizType;
            JSONObject payload;
            String fromAccount;
            String toAccount = "";
            long topicId = 0;
            ConstraintsMap paramsParent = new ConstraintsMap();
            ConstraintsMap paramsChild = new ConstraintsMap();
            if(msg != null){
                MIMCMessage  message = msg;
                timestamp = message.getTimestamp();
                bizType = message.getBizType();
                payload = JSONObject.parseObject(new String(message.getPayload()));
                fromAccount = message.getFromAccount();
                toAccount = message.getToAccount();
                paramsChild.putString("toAccount", toAccount);
            }else{
                MIMCGroupMessage  message = gmsg;
                timestamp = message.getTimestamp();
                bizType = message.getBizType();
                topicId = message.getTopicId();
                payload = JSONObject.parseObject(new String(message.getPayload()));
                fromAccount = message.getFromAccount();
            }
            paramsChild.putString("toAccount", toAccount);
            paramsChild.putString("fromAccount", fromAccount);
            paramsChild.putString("bizType", bizType);
            paramsChild.putMap("message", payload);
            paramsChild.putLong("topicId", topicId);
            paramsChild.putLong("timestamp", timestamp);
            paramsParent.putString("eventType", eventType);
            paramsParent.putMap("eventValue", paramsChild.toMap());
            FlutterMimcPlugin.eventSink.success(paramsParent.toMap());
        }catch (Exception e){
            System.out.println("eventSink  Error:" + e.getMessage());
        }
    }

    @Override
    public void onHandleMessage(MIMCMessage message) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        eventSinkPushMessage("onHandleMessage", message, null);
    }

    @Override
    public void onHandleGroupMessage(MIMCGroupMessage message) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        eventSinkPushMessage("onHandleGroupMessage", null, message);
    }

    @Override
    public void onHandleStatusChanged(MIMCConstant.OnlineStatus status) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        try {
            ConstraintsMap params = new ConstraintsMap();
            params.putString("eventType", "onlineStatusListener");
            params.putBoolean("eventValue", MIMCConstant.OnlineStatus.ONLINE == status);
            FlutterMimcPlugin.eventSink.success(params.toMap());
        }catch (Exception e){
            System.out.println("eventSink  Error:" + e.getMessage());
        }
    }

    @Override
    public void onHandleServerAck(MIMCServerAck serverAck) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        ConstraintsMap params = new ConstraintsMap();
        params.putString("eventType", "onHandleServerAck");
        params.putString("eventValue", serverAck.toString());
        FlutterMimcPlugin.eventSink.success(params.toMap());
    }

    @Override
    public void onHandleCreateGroup(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleQueryGroupInfo(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleQueryGroupsOfAccount(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleJoinGroup(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleQuitGroup(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleKickGroup(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleUpdateGroup(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleDismissGroup(String json, boolean isSuccess) {

    }

    @Override
    public void onHandlePullP2PHistory(String json, boolean isSuccess) {

    }

    @Override
    public void onHandlePullP2THistory(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleSendMessageTimeout(MIMCMessage message) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        eventSinkPushMessage("onHandleSendMessageTimeout", message, null);
    }

    @Override
    public void onHandleSendGroupMessageTimeout(MIMCGroupMessage groupMessage) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        eventSinkPushMessage("onHandleSendGroupMessageTimeout", null, groupMessage);
    }

    @Override
    public void onHandleJoinUnlimitedGroup(long topicId, int code, String errMsg) {

    }

    @Override
    public void onHandleQuitUnlimitedGroup(long topicId, int code, String errMsg) {

    }

    @Override
    public void onHandleDismissUnlimitedGroup(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleQueryUnlimitedGroupMembers(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleQueryUnlimitedGroups(String json, boolean isSuccess) {

    }

    @Override
    public void onHandleQueryUnlimitedGroupOnlineUsers(String json, boolean isSuccess) {

    }
}
