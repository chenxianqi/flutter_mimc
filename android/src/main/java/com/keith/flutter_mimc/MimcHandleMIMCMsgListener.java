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
            System.out.println("收到群消息" + paramsParent.toMap());
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
}
