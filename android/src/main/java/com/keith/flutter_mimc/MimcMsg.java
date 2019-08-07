package com.keith.flutter_mimc;
import com.alibaba.fastjson.annotation.JSONField;

public class MimcMsg {
    @JSONField(ordinal = 1)
    private int version;

    @JSONField(ordinal = 2)
    private String msgId;

    @JSONField(ordinal = 3)
    private long timestamp;

    @JSONField(ordinal = 4)
    private byte[] payload;

    public MimcMsg() {}

    public MimcMsg(int version, String msgId, long timestamp, byte[] payload) {
        this.version = version;
        this.msgId = msgId;
        this.timestamp = timestamp;
        this.payload = payload;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public String getMsgId() {
        if (msgId == null) {
            msgId = MimcMsgHelper.nextID();
        }
        return msgId;
    }

    public void setMsgId(String msgId) {
        this.msgId = msgId;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public byte[] getPayload() {
        return payload;
    }

    public void setPayload(byte[] payload) {
        this.payload = payload;
    }
}
