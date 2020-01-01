//
//  MCUser.h
//  MIMCSDK
//
//  Created by zhangdan on 2017/11/22.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objc/runtime.h"
#include <pthread.h>
#import "MIMCMessage.h"
#import "MIMCGroupMessage.h"
#import "MIMCLaunchedResponse.h"
#import "MIMCRtsDataType.h"
#import "MIMCRtsChannelType.h"
#import "MIMCLoggerWrapper.h"
#import "MIMCStreamConfig.h"
#import "MIMCServerAck.h"
#import "MIMCChannelUser.h"
#import "MCOnlineMessageAck.h"

@class XMDTransceiver;
@class MIMCConnection;
@class MCUser;
@class MIMCHistoryMessagesStorage;
@class UCPacket;
@class MIMCThreadSafeDic;
@class BindRelayResponse;

@protocol parseTokenDelegate <NSObject>
- (void)parseProxyServiceToken:(void(^)(NSString *data))callback;
@end

@protocol onlineStatusDelegate <NSObject>
- (void)statusChange:(MCUser *)user status:(int)status type:(NSString *)type reason:(NSString *)reason desc:(NSString *)desc;
@end

@protocol handleMessageDelegate <NSObject>
- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user;
- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleServerAck:(MIMCServerAck *)serverAck;
- (void)handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleOnlineMessage:(MIMCMessage *)onlineMessage;
- (void)handleOnlineMessageAck:(MCOnlineMessageAck *)onlineMessageAck;

- (void)handleSendMessageTimeout:(MIMCMessage *)message;
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
@end

@protocol handleUnlimitedGroupDelegate <NSObject>
- (void)handleCreateUnlimitedGroup:(int64_t)topicId topicName:(NSString *)topicName code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleJoinUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleQuitUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleDismissUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleDismissUnlimitedGroup:(int64_t)topicId;
@end

@protocol handleRtsCallDelegate <NSObject>
- (MIMCLaunchedResponse *)onLaunched:(NSString *)fromAccount fromResource:(NSString *)fromResource callId:(int64_t)callId appContent:(NSData *)appContent;
- (void)onAnswered:(int64_t)callId accepted:(Boolean)accepted desc:(NSString *)desc; // 会话接通之后的回调
- (void)onClosed:(int64_t)callId desc:(NSString *)desc; // 会话被关闭的回调
- (void)onData:(int64_t)callId fromAccount:(NSString *)fromAccount resource:(NSString *)resource data:(NSData *)data dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType; // 接收到数据的回调
- (void)onSendDataSuccess:(int64_t)callId dataId:(int)dataId context:(id)context; //发送数据成功的回调
- (void)onSendDataFailure:(int64_t)callId dataId:(int)dataId context:(id)context; //发送数据失败的回调
@end

@protocol handleRtsChannelDelegate <NSObject>
- (void)onCreateChannel:(int64_t)identity callId:(int64_t)callId callKey:(NSString *)callKey success:(Boolean)success desc:(NSString *)desc extra:(NSData *)extra; // 创建频道回调
- (void)onJoinChannel:(int64_t)callId appAccount:(NSString *)appAccount resource:(NSString *)resource success:(Boolean)success desc:(NSString *)desc extra:(NSData *)extra members:(NSArray<MIMCChannelUser*> *)members; // 加入频道回调
- (void)onLeaveChannel:(int64_t)callId appAccount:(NSString *)appAccount resource:(NSString *)resource success:(Boolean)success desc:(NSString *)desc; // 离开频道回调
- (void)onUserJoined:(int64_t)callId appAccount:(NSString *)appAccount resource:(NSString *)resource; // 新加入用户回调
- (void)onUserLeft:(int64_t)callId appAccount:(NSString *)appAccount resource:(NSString *)resource; // 用户离开回调
- (void)onData:(int64_t)callId fromAccount:(NSString *)fromAccount resource:(NSString *)resource data:(NSData *)data dataType:(RtsDataType)dataType; // 接收流数据
- (void)onSendDataSuccess:(int64_t)callId dataId:(int)dataId context:(id)context; // 发送流数据成功的回调
- (void)onSendDataFailure:(int64_t)callId dataId:(int)dataId context:(id)context; // 发送流数据失败的回调
@end

typedef enum _OnlineStatus {
    Offline,
    Online
} OnlineStatus;

typedef enum _RelayLinkState {
    NOT_CREATED,
    BEING_CREATED,
    SUCC_CREATED
} RelayLinkState;

typedef enum _MIMCDataPriority {
    MIMC_P0,
    MIMC_P1,
    MIMC_P2,
} MIMCDataPriority;

typedef enum _TimeUnit {
    MILLISECONDS,
    SECONDS,
    MINUTES
} TimeUnit;

static NSString *join(NSMutableDictionary *kvs) {
    if (kvs == nil) {
        return @"";
    }

    NSString *s = [[NSString alloc] init];
    for (NSString *key in kvs) {
        [s stringByAppendingFormat:@"%@:%@,", key, [kvs objectForKey:key]];
    }

    if (s.length > 1) {
        [s substringToIndex:s.length - 1];
    }
    return s;
}

@interface MCUser : NSObject

@property(nonatomic, weak) id<parseTokenDelegate> parseTokenDelegate;
@property(nonatomic, weak) id<onlineStatusDelegate> onlineStatusDelegate;
@property(nonatomic, weak) id<handleMessageDelegate> handleMessageDelegate;
@property(nonatomic, weak) id<handleUnlimitedGroupDelegate> handleUnlimitedGroupDelegate;
@property(nonatomic, weak) id<handleRtsCallDelegate> handleRtsCallDelegate;
@property(nonatomic, weak) id<handleRtsChannelDelegate> handleRtsChannelDelegate;

- (BOOL)logout;
//- (NSString *)pull;
- (BOOL)login;
- (BOOL)login:(BOOL)useCache DEPRECATED_ATTRIBUTE;
- (void)setOnlineStatus:(OnlineStatus)status;
- (void)addCloudAttr:(NSString *)key value:(NSString *)value;
- (void)addClientAttr:(NSString *)key value:(NSString *)value;
- (NSString *)createPacketId;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload isStore:(Boolean)isStore;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload isStore:(Boolean)isStore isConversation:(Boolean)isConversation;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload bizType:(NSString *)bizType;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload bizType:(NSString *)bizType isStore:(Boolean)isStore;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload bizType:(NSString *)bizType isStore:(Boolean)isStore isConversation:(Boolean)isConversation;
- (NSString *)sendOnlineMessage:(NSString *)toAppAccount payload:(NSData *)payload;
- (NSString *)sendOnlineMessage:(NSString *)toAppAccount payload:(NSData *)payload bizType:(NSString *)bizType;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload isStore:(Boolean)isStore;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload isStore:(Boolean)isStore isConversation:(Boolean)isConversation;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType isStore:(Boolean)isStore;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType isStore:(Boolean)isStore isConversation:(Boolean)isConversation;
- (Boolean)sendPacket:(NSString *)msgId payload:(NSData *)payload msgType:(NSString *)msgType;
- (id)initWithAppId:(int64_t)appId andAppAccount:(NSString *)appAccount;
- (id)initWithAppId:(int64_t)appId andAppAccount:(NSString *)appAccount andResource:(NSString *)resource;
- (id)initWithAppId:(int64_t)appId andAppAccount:(NSString *)appAccount andUseCache:(BOOL)useCache;
- (id)initWithAppId:(int64_t)appId andAppAccount:(NSString *)appAccount andResource:(NSString *)resource andUseCache:(BOOL)useCache;
- (BOOL)isOnline;
- (void)destroy;
- (void)handleUDPConnClosed:(int64_t)connId connCloseType:(int)connCloseType;

- (int64_t)dialCall:(NSString *)toAppAccount;
- (int64_t)dialCall:(NSString *)toAppAccount toResource:(NSString *)toResource;
- (int64_t)dialCall:(NSString *)toAppAccount appContent:(NSData *)appContent;
- (int64_t)dialCall:(NSString *)toAppAccount toResource:(NSString *)toResource appContent:(NSData *)appContent;
- (int)sendRtsData:(int64_t)callId data:(NSData *)data dataType:(RtsDataType)dataType dataPriority:(MIMCDataPriority)dataPriority canBeDropped:(Boolean)canBeDropped context:(id)context;
- (int)sendRtsData:(int64_t)callId data:(NSData *)data dataType:(RtsDataType)dataType dataPriority:(MIMCDataPriority)dataPriority canBeDropped:(Boolean)canBeDropped resendCount:(int)resendCount context:(id)context;
- (int)sendRtsData:(int64_t)callId data:(NSData *)data dataType:(RtsDataType)dataType dataPriority:(MIMCDataPriority)dataPriority canBeDropped:(Boolean)canBeDropped resendCount:(int)resendCount channelType:(RtsChannelType)channelType context:(id)context;

- (void)closeCall:(int64_t)callId;
- (void)closeCall:(int64_t)callId byeReason:(NSString *)byeReason;
- (void)clearLocalRelayLinkStateAndTs;

- (int64_t)createChannel:(NSData *)extra;
- (void)joinChannel:(int64_t)callId callKey:(NSString *)callKey;
- (void)leaveChannel:(int64_t)callId callKey:(NSString *)callKey;

- (BOOL)createUnlimitedGroup:(NSString *)topicName context:(id)context;
- (BOOL)dismissUnlimitedGroup:(int64_t)topicId context:(id)context;
- (NSString *)joinUnlimitedGroup:(int64_t)topicId context:(id)context;
- (NSString *)quitUnlimitedGroup:(int64_t)topicId context:(id)context;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload isStore:(Boolean)isStore;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType isStore:(Boolean)isStore;

- (int)getChid;
- (NSString *)getUuid;
- (NSString *)getResource;
- (NSString *)getSecurityKey;
- (NSString *)getToken;
- (int64_t)getAppId;
- (NSString *)getAppPackage;
- (NSString *)getAppAccount;
- (NSString *)getClientAttrs;
- (NSString *)getCloudAttrs;
- (MIMCConnection *)getConn;
- (OnlineStatus)getStatus;
- (int64_t)getLastLoginTimestamp;
- (MIMCHistoryMessagesStorage *)getHistoryMessagesStorage;
- (MIMCThreadSafeDic *)getCurrentCalls;
- (MIMCThreadSafeDic *)getCurrentChannels;
- (MIMCThreadSafeDic *)getTempRtsChannels;
- (RelayLinkState)getRelayLinkState;
- (int64_t)getLatestLegalRelayConnStateTs;
- (int64_t)getRelayConnId;
- (short)getRelayControlStreamId;
- (short)getRelayVideoStreamId;
- (short)getRelayAudioStreamId;
- (BindRelayResponse *)getBindRelayResponse;
- (XMDTransceiver *)getXmdTransceiver;
- (NSMutableSet *)getUcTopicSet;
- (int64_t)getLastPingCallManagerTimestamp;
- (int64_t)getLastPingRelayTimestamp;
- (int)getMaxRtsCallCount;
- (int)getPacketLoss;
- (int64_t)getRegionBucke;
- (NSString *)getFeDomain;
- (NSString *)getRelayDomain;
- (int64_t)getRegionBucketFromCallSession:(int64_t)callId;
- (NSArray<MIMCChannelUser *> *)getChannelUsers:(int64_t)callId;

- (void)setChid:(int)chid;
- (void)setUuid:(NSString *)uuid;
- (void)setResource:(NSString *)resource;
- (void)setSecurityKey:(NSString *)securityKey;
- (void)setToken:(NSString *)token;
- (void)setLastLoginTimestamp:(int64_t)lastLoginTimestamp;
- (void)setRelayLinkState:(RelayLinkState)relayLinkState;
- (void)setLatestLegalRelayConnStateTs:(int64_t)latestLegalRelayConnStateTs;
- (void)setRelayConnId:(int64_t)relayConnId;
- (void)setRelayControlStreamId:(short)relayControlStreamId;
- (void)setRelayVideoStreamId:(short)relayVideoStreamId;
- (void)setRelayAudioStreamId:(short)relayAudioStreamId;
- (void)setBindRelayResponse:(BindRelayResponse *)bindRelayResponse;
- (void)setLastPingCallManagerTimestamp:(int64_t)lastPingCallManagerTimestamp;
- (void)setLastPingRelayTimestamp:(int64_t)lastPingRelayTimestamp;
- (void)setPacketLoss:(int)packetLoss;
- (void)setRegionBucket:(int64_t)regionBucket;
- (void)setFeDomain:(NSString *)feDomain;
- (void)setRelayDomain:(NSString *)relayDomain;
- (void)setMaxRtsCallCount:(int)maxRtsCallCount;
- (NSArray *)getFeIpArr;
- (void)setFeIpArr:(NSArray *)feIpArr;
- (NSArray *)getRelayIpArr;
- (void)setRelayIpArr:(NSArray *)relayIpArr;

- (void)initAudioStreamConfig:(MIMCStreamConfig *)audioStreamConfig;
- (MIMCStreamConfig *)getAudioStreamConfig;
- (void)initVideoStreamConfig:(MIMCStreamConfig *)videoStreamConfig;
- (MIMCStreamConfig *)getVideoStreamConfig;
- (void)setSendBufferSize:(int)size;
- (int)getSendBufferSize;
- (void)clearSendBuffer;
- (float)getSendBufferUsageRate;
- (void)setRecvBufferSize:(int)size;
- (int)getRecvBufferSize;
- (void)clearRecvBuffer;
- (float)getRecvBufferUsageRate;

- (void)setBaseOfBackoffWhenFetchToken:(TimeUnit)timeUnit andBase:(int64_t)base;
- (void)setCapOfBackoffWhenFetchToken:(TimeUnit)timeUnit andCap:(int64_t)cap;
- (void)setBaseOfBackoffWhenConnectFe:(TimeUnit)timeUnit andBase:(int64_t)base;
- (void)setCapOfBackoffWhenConnectFe:(TimeUnit)timeUnit andCap:(int64_t)cap;

+ (void)setMIMCLogSwitch:(BOOL)logSwitch;
+ (void)setMIMCLogLevel:(MIMCLogLevel)level;
+ (void)writeLog2File:(void (^)(BOOL Susscess))callback;
@end
