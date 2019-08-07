package com.keith.flutter_mimc;

import com.xiaomi.mimc.data.RtsDataType;

/**
 * Created by houminjiang on 18-5-24.
 */

public interface MimcOnCallStateListener {
    void onLaunched(String fromAccount, String fromResource, long callId, byte[] data);
    void onAnswered(long callId, boolean accepted, String errMsg);
    void handleData(long callId, RtsDataType dataType, byte[] data);
    void onClosed(long callId, String errMsg);
}
