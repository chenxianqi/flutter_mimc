//
//  XMUserManager.h
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "<MMCSDK/MCUser.h"
#import "<MMCSDK/MIMCMessage.h>"
#import "<MMCSDK/MIMCGroupMessage.h>"
#import "<MMCSDK/MIMCRtsDataType.h>"
#import "<MMCSDK/MIMCRtsChannelType.h>"
#import <UIKit/UIKit.h>

extern int const TIMEOUT_ON_LAUNCHED;
extern int const STATE_INIT;
extern int const STATE_TIMEOUT;
extern int const STATE_AGREE;
extern int const STATE_REJECT;
extern int const CALL_SENDER;
extern int const CALL_RECEIVER;
extern int const CALLID_INVALID;

@protocol showRecvMsgDelegate
- (void)showRecvMsg:(MIMCMessage *)packet user:(MCUser *)user;
@end

@protocol returnUserStatusDelegate
- (void)returnUserStatus:(MCUser *)user status:(int)status;
@end

@protocol OnCallStateDelegate
- (void)onAnswered:(int64_t)callId accepted:(Boolean)accepted desc:(NSString *)desc;
- (void)onClosed:(int64_t)callId desc:(NSString *)desc;
- (void)onData:(int64_t)callId fromAccount:(NSString *)fromAccount resource:(NSString *)resource data:(NSData *)data dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType;
@end

@interface XMUserManager : NSObject<parseTokenDelegate, onlineStatusDelegate, handleMessageDelegate, handleRtsCallDelegate>

@property(nonatomic, weak) id<showRecvMsgDelegate> showRecvMsgDelegate;
@property(nonatomic, weak) id<returnUserStatusDelegate> returnUserStatusDelegate;
@property(nonatomic, weak) id<OnCallStateDelegate> OnCallStateDelegate;

- (id)init;
+ (XMUserManager *)sharedInstance;
- (BOOL)userLogin;
- (BOOL)userLogout;
- (void)GDCTimer;
- (NSString *)getAppAccount;
- (void)setAppAccount:(NSString *)appAccount;
- (MCUser *)getUser;
- (void)setUser:(MCUser *)user;
- (void)setLoginVC:(UIViewController *)loginVC;
- (void)parseProxyServiceToken:(void(^)(NSString *data))callback;
- (void)statusChange:(MCUser *)user status:(int)status type:(NSString *)type reason:(NSString *)reason desc:(NSString *)desc;
- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user;
- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleServerAck:(MIMCServerAck *)serverAck;
- (void)handleSendMessageTimeout:(MIMCMessage *)message;
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;

- (MIMCLaunchedResponse *)onLaunched:(NSString *)fromAccount fromResource:(NSString *)fromResource callId:(int64_t)callId appContent:(NSData *)appContent;
- (void)onAnswered:(int64_t)callId accepted:(Boolean)accepted desc:(NSString *)desc; // 会话接通之后的回调
- (void)onClosed:(int64_t)callId desc:(NSString *)desc; // 会话被关闭的回调
- (void)onData:(int64_t)callId fromAccount:(NSString *)fromAccount resource:(NSString *)resource data:(NSData *)data dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType; // 接收到数据的回调
- (void)onSendDataSuccess:(int64_t)callId dataId:(int)dataId context:(id)context;
- (void)onSendDataFailure:(int64_t)callId dataId:(int)dataId context:(id)context;
@end
