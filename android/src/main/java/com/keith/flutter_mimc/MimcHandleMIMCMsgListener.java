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
            String payload = "";
            String fromAccount;
            String toAccount = "";
            long topicId = 0;
            ConstraintsMap params = new ConstraintsMap();
            ConstraintsMap paramChild = new ConstraintsMap();
            if(msg != null){
                timestamp = msg.getTimestamp();
                bizType = msg.getBizType();
                fromAccount = msg.getFromAccount();
                toAccount = msg.getToAccount();
                payload = new String(msg.getPayload());
                paramChild.putString("toAccount", toAccount);
            }else{
                timestamp = gmsg.getTimestamp();
                bizType = gmsg.getBizType();
                payload = new String(gmsg.getPayload());
                topicId = gmsg.getTopicId();
                fromAccount = gmsg.getFromAccount();
            }
            paramChild.putString("toAccount", toAccount);
            paramChild.putString("fromAccount", fromAccount);
            paramChild.putString("bizType", bizType);
            paramChild.putString("payload", payload);
            paramChild.putLong("topicId", topicId);
            paramChild.putLong("timestamp", timestamp);
            params.putString("eventType", eventType);
            params.putMap("eventValue", paramChild.toMap());
            System.out.println("消息" + paramChild.toMap());
            FlutterMimcPlugin.eventSink.success(params.toMap());
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
        ConstraintsMap paramsChild = new ConstraintsMap();
        paramsChild.putString("packetId", serverAck.getPacketId());
        paramsChild.putLong("sequence", serverAck.getSequence());
        paramsChild.putLong("timestamp", serverAck.getTimestamp());
        paramsChild.putInt("code", serverAck.getCode());
        paramsChild.putString("desc", serverAck.getDesc());
        params.putString("eventType", "onHandleServerAck");
        params.putMap("eventValue", paramsChild.toMap());
        FlutterMimcPlugin.eventSink.success(params.toMap());
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
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        try {
            ConstraintsMap params = new ConstraintsMap();
            ConstraintsMap paramsChild = new ConstraintsMap();
            paramsChild.putLong("topicId", topicId);
            paramsChild.putInt("code", code);
            paramsChild.putString("errMsg", errMsg);
            params.putString("eventType", "onHandleJoinUnlimitedGroup");
            params.putMap("eventValue", paramsChild.toMap());
            FlutterMimcPlugin.eventSink.success(params.toMap());
        }catch (Exception e){
            System.out.println("eventSink  Error:" + e.getMessage());
        }
    }

    @Override
    public void onHandleQuitUnlimitedGroup(long topicId, int code, String errMsg) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        try {
            ConstraintsMap params = new ConstraintsMap();
            ConstraintsMap paramsChild = new ConstraintsMap();
            paramsChild.putLong("topicId", topicId);
            paramsChild.putInt("code", code);
            paramsChild.putString("errMsg", errMsg);
            params.putString("eventType", "onHandleQuitUnlimitedGroup");
            params.putMap("eventValue", paramsChild.toMap());
            FlutterMimcPlugin.eventSink.success(params.toMap());
        }catch (Exception e){
            System.out.println("eventSink  Error:" + e.getMessage());
        }
    }

    @Override
    public void onHandleDismissUnlimitedGroup(long topicId, int code, String errMsg) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        try {
            ConstraintsMap params = new ConstraintsMap();
            ConstraintsMap paramsChild = new ConstraintsMap();
            paramsChild.putLong("topicId", topicId);
            paramsChild.putInt("code", code);
            paramsChild.putString("errMsg", errMsg);
            params.putString("eventType", "onHandleDismissUnlimitedGroup");
            params.putMap("eventValue", paramsChild.toMap());
            FlutterMimcPlugin.eventSink.success(params.toMap());
        }catch (Exception e){
            System.out.println("eventSink  Error:" + e.getMessage());
        }
    }

    @Override
    public void onHandleCreateUnlimitedGroup(long topicId, String topicName, int code, String errMsg) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        try {
            ConstraintsMap params = new ConstraintsMap();
            ConstraintsMap paramsChild = new ConstraintsMap();
            paramsChild.putLong("topicId", topicId);
            paramsChild.putString("topicName", topicName);
            paramsChild.putInt("code", code);
            paramsChild.putString("errMsg", errMsg);
            params.putString("eventType", "onHandleCreateUnlimitedGroup");
            params.putMap("eventValue", paramsChild.toMap());
            FlutterMimcPlugin.eventSink.success(params.toMap());
        }catch (Exception e){
            System.out.println("eventSink  Error:" + e.getMessage());
        }
    }

    @Override
    public void onHandleSendUnlimitedGroupMessageTimeout(MIMCGroupMessage groupMessage) {
        eventSinkPushMessage("onHandleSendUnlimitedGroupMessageTimeout", null, groupMessage);
    }
}
