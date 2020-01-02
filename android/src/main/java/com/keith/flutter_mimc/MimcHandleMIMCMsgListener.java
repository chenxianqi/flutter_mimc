package com.keith.flutter_mimc;
import com.keith.flutter_mimc.utils.ConstraintsMap;
import com.xiaomi.mimc.MIMCGroupMessage;
import com.xiaomi.mimc.MIMCMessage;
import com.xiaomi.mimc.MIMCOnlineMessageAck;
import com.xiaomi.mimc.MIMCServerAck;
import com.xiaomi.mimc.common.MIMCConstant;

class MIMCHandleMIMCMsgListener implements MIMCUserManager.OnHandleMIMCMsgListener {
    MIMCHandleMIMCMsgListener(){
        MIMCUserManager.getInstance().setHandleMIMCMsgListener(this);
    }

    // 消息处理
    private void eventSinkPushMessage(String eventType, MIMCMessage mimcMessage, MIMCGroupMessage mimcGroupMessage){

        try {
            long timestamp;
            String bizType;
            String payload;
            String fromAccount;
            String toAccount = "";
            long topicId = 0;
            ConstraintsMap params = new ConstraintsMap();
            ConstraintsMap paramChild = new ConstraintsMap();
            if(mimcMessage != null){
                timestamp = mimcMessage.getTimestamp();
                bizType = mimcMessage.getBizType();
                fromAccount = mimcMessage.getFromAccount();
                toAccount = mimcMessage.getToAccount();
                payload = new String(mimcMessage.getPayload());
                paramChild.putString("toAccount", toAccount);
            }else{
                timestamp = mimcGroupMessage.getTimestamp();
                bizType = mimcGroupMessage.getBizType();
                payload = new String(mimcGroupMessage.getPayload());
                topicId = mimcGroupMessage.getTopicId();
                fromAccount = mimcGroupMessage.getFromAccount();
            }
            paramChild.putString("toAccount", toAccount);
            paramChild.putString("fromAccount", fromAccount);
            paramChild.putString("bizType", bizType);
            paramChild.putString("payload", payload);
            paramChild.putLong("topicId", topicId);
            paramChild.putLong("timestamp", timestamp);
            params.putString("eventType", eventType);
            params.putMap("eventValue", paramChild.toMap());
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
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        eventSinkPushMessage("onHandleSendUnlimitedGroupMessageTimeout", null, groupMessage);
    }

    @Override
    public void onHandleOnlineMessage(MIMCMessage message) {
        eventSinkPushMessage("onHandleOnlineMessage", message, null);
    }

    @Override
    public void handleOnlineMessageAck(MIMCOnlineMessageAck mimcOnlineMessageAck) {
        if(FlutterMimcPlugin.eventSink == null)
        {
            System.out.println("eventSink  null");
            return;
        }
        ConstraintsMap params = new ConstraintsMap();
        ConstraintsMap paramsChild = new ConstraintsMap();
        paramsChild.putString("packetId", mimcOnlineMessageAck.getPacketId());
        paramsChild.putInt("code", mimcOnlineMessageAck.getCode());
        paramsChild.putString("desc", mimcOnlineMessageAck.getDesc());
        params.putString("eventType", "onHandleOnlineMessageAck");
        params.putMap("eventValue", paramsChild.toMap());
        FlutterMimcPlugin.eventSink.success(params.toMap());
    }

    @Override
    public void onPullNotification() {

    }
}
