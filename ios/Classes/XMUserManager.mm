//
//  XMUserManager.m
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.
//

#import "XMUserManager.h"
#import "voiceCallViewController.h"

int const TIMEOUT_ON_LAUNCHED = 30;
int const STATE_INIT = 0;
int const STATE_TIMEOUT = 999;
int const STATE_AGREE = 1;
int const STATE_REJECT = 2;
int const CALL_SENDER = 1;
int const CALL_RECEIVER = 2;
int const CALLID_INVALID = -1;
static dispatch_source_t timer;

/**
 * @important!!! appId/appKey/appSecret：
 * 小米开放平台(https://dev.mi.com/cosole/man/)申请
 * 信息敏感，不应存储于APP端，应存储在AppProxyService
 * appAccount:
 * APP帐号系统内唯一ID
 * 此处appId/appKey/appSecret为小米MIMC Demo所有，会在一定时间后失效
 * 请替换为APP方自己的appId/appKey/appSecret
 **/

@interface XMUserManager () {
}
@property(nonatomic) int64_t appId;
@property(nonatomic) NSString *appKey;
@property(nonatomic) NSString *appSecret;
@property(nonatomic) NSString *appAccount;
@property(nonatomic) NSString *url;
@property(nonatomic, strong) MCUser *user;
@property(nonatomic, assign) NSInteger answer;
@property(nonatomic, strong) UIViewController *loginVC;

- (NSMutableURLRequest *)generateHttpRequest:(NSURL *)url appId:(int64_t)appId
                                      appKey:(NSString *)appKey appSecret:(NSString *)appSecret
                                  appAccount:(NSString *)appAccount;
@end

static XMUserManager *_sharedInstance = nil;
static NSString * hangUpNotificationStr = @"kMIMCHangupNotification";
static NSString * answerNotificationStr = @"kMIMCanswerNotification";

@implementation XMUserManager
@synthesize appAccount = _appAccount;
@synthesize user = _user;

+ (XMUserManager *)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[XMUserManager alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    /**
     * @important!!! appId/appKey/appSecret：
     * 小米开放平台(https://dev.mi.com/cosole/man/)申请
     * 信息敏感，不应存储于APP端，应存储在AppProxyService
     * 此处appId/appKey/appSecret为小米MIMC Demo所有，会在一定时间后失效
     * 请替换为APP方自己的appId/appKey/appSecret
     **/
    if (self = [super init]) {
        self.appId = 2882303761517669588L;
        self.appKey = @"5111766983588";
        self.appSecret = @"b0L3IOz/9Ob809v8H2FbVg==";
        self.url = @"https://mimc.chat.xiaomi.net/api/account/token";
    }
    return self;
}

- (NSMutableURLRequest *)generateHttpRequest:(NSURL *)url appId:(int64_t)appId appKey:(NSString *)appKey
                                   appSecret:(NSString *)appSecret appAccount:(NSString *)appAccount {
    /**
     * @important!!!
     * appId/appKey/appSecret：
     *     小米开放平台(https://dev.mi.com/cosole/man/)申请
     *     信息敏感，不应存储于APP端，应存储在AppProxyService
     * appAccount:
     *      APP帐号系统内唯一ID
     * AppProxyService：
     *     a) 验证appAccount合法性；
     *     b) 访问TokenService，获取Token并下发给APP；
     * !!此为Demo APP所以appId/appKey/appSecret存放于APP本地!!
     **/
    
    if (url == nil || appId == 0 || appKey == nil || appKey.length == 0 || appSecret == nil
        || appSecret.length== 0 || appAccount == nil || appAccount.length == 0) {
        NSLog(@"generateRequest, fail, parameter:url=%@, appId=%lld, appKey=%@, appKey_len=%lu, appSecret=%@, appSecret_len=%lu, appAccount=%@, appAccount_len=%lu", url, appId, appKey, (long)appKey.length, appSecret, (long)appSecret.length, appAccount, (long)appAccount.length);
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *dicObj = [[NSMutableDictionary alloc] init];
    [dicObj setObject:[NSNumber numberWithLongLong:appId] forKey:@"appId"];
    [dicObj setObject:appKey forKey:@"appKey"];
    [dicObj setObject:appSecret forKey:@"appSecret"];
    [dicObj setObject:appAccount forKey:@"appAccount"];
    [dicObj setObject:@"REGION_CN" forKey:@"regionKey"];
    
    NSData *dicData = [NSJSONSerialization dataWithJSONObject:dicObj options:NSJSONWritingPrettyPrinted error:nil];
    if (dicData == nil || dicData.length == 0) {
        NSLog(@"generateRequest, dicData is nil");
        return nil;
    }
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:dicData];
    return request;
}

- (BOOL)userLogin {
    _user = [[MCUser alloc] initWithAppId:_appId andAppAccount:_appAccount];
    _user.parseTokenDelegate = self;
    _user.onlineStatusDelegate = self;
    _user.handleMessageDelegate = self;
    _user.handleRtsCallDelegate = self;
    
    return [_user login];
}

- (BOOL)userLogout {
    return [_user logout];
}

- (void)GDCTimer {
    __block int timeout = TIMEOUT_ON_LAUNCHED;//倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    typeof(self) __weak wself = self;
    dispatch_source_set_event_handler(timer, ^{
        if (timeout > 0) {
            timeout--;
        }else{
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.answer = STATE_TIMEOUT;
            });
        }
    });
    dispatch_resume(timer);
}

- (void)parseProxyServiceToken:(void(^)(NSString *data))callback {
    NSLog(@"parseProxyServiceToken, comes");
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *request = [self generateHttpRequest:url appId:self.appId appKey:self.appKey appSecret:self.appSecret appAccount:self.appAccount];
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data == nil || data.length == 0 || response == nil || [(NSHTTPURLResponse *)response statusCode] != 200) {
            [MIMCLoggerWrapper.sharedInstance warn:@"parseProxyServiceToken, HTTP_REQUEST_FAIL, data=%@, data_len=%lu, response=%@, response_statusCode=%ld", data, (long)data.length, response, (long)[(NSHTTPURLResponse *)response statusCode]];
            return;
        }
        [MIMCLoggerWrapper.sharedInstance info:@"parseProxyServiceToken, HTTP_REQUEST_SUCCESS, data=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        
        NSMutableDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dataDic == nil || dataDic.count == 0) {
            [MIMCLoggerWrapper.sharedInstance warn:@"parseProxyServiceToken, dataDic is nil"];
            return;
        }
        if ([[dataDic objectForKey:@"code"] intValue] != 200) {
            [MIMCLoggerWrapper.sharedInstance warn:@"parseProxyServiceToken, JSON_RESULT_CODE NOT EQUAL 200"];
            return;
        }
        NSMutableDictionary *tokenDic = [dataDic objectForKey:@"data"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tokenDic options:0 error:0];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (callback) {
            callback(jsonString);
        }
    };
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler] resume];

}

- (void)statusChange:(MCUser *)user status:(int)status type:(NSString *)type reason:(NSString *)reason desc:(NSString *)desc {
    if (user == nil) {
        NSLog(@"statusChange, user is nil");
        return;
    }
    [self.returnUserStatusDelegate returnUserStatus:user status:status];
    NSLog(@"statusChange, Called, uuid=%@, user=%@, status=%d, type=%@, reason=%@, desc=%@",user.getUuid, user, status, type, reason, desc);
}

- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user {
    for (MIMCMessage *p in packets) {
        if (p == nil) {
            NSLog(@"handleMessage, ReceiveMessage, P2P is nil");
            continue;
        }
        NSLog(@"handleMessage, ReceiveMessage, P2P, {%@}-->{%@}, packetId=%@, payload=%@, bizType=%@", p.getFromAccount, user.getAppAccount, p.getPacketId, p.getPayload, p.getBizType);
        
        [self.showRecvMsgDelegate showRecvMsg:p user:user];
    }
}

- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets {
    NSLog(@"handleGroupMessage, Called");
}

- (void)handleServerAck:(MIMCServerAck *)serverAck {
    NSLog(@"handleServerAck, ReceiveMessageAck, ackPacketId=%@, sequence=%lld, timestamp=%lld, code=%d, desc=%@", serverAck.getPacketId, serverAck.getSequence, serverAck.getTimestamp, serverAck.getCode, serverAck.getDesc);
}

- (void)handleSendMessageTimeout:(MIMCMessage *)message {
    NSLog(@"handleSendMessageTimeout, message.packetId=%@, message.sequence=%lld, message.timestamp=%lld, message.fromAccount=%@, message.toAccount=%@, message.payload=%@, message.bizType=%@", message.getPacketId, message.getSequence, message.getTimestamp, message.getFromAccount, message.getToAccount, message.getPayload, message.getBizType);
}

- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage {
    NSLog(@"handleSendGroupMessageTimeout, groupMessag.packetId=%@, groupMessag.sequence=%lld, groupMessage.timestamp=%lld, groupMessage.fromAccount=%@, groupMessage.topicId=%lld, groupMessag.payload=%@, groupMessag.bizType=%@", groupMessage.getPacketId, groupMessage.getSequence, groupMessage.getTimestamp, groupMessage.getFromAccount, groupMessage.getTopicId, groupMessage.getPayload, groupMessage.getBizType);
}

- (void)handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets {
    NSLog(@"handleUnlimitedGroupMessage");
}

- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage {
    NSLog(@"handleSendUnlimitedGroupMessageTimeout, groupMessage=%@", groupMessage);
}

- (MIMCLaunchedResponse *)onLaunched:(NSString *)fromAccount fromResource:(NSString *)fromResource callId:(int64_t)callId appContent:(NSData *)appContent {
    NSLog(@"onLaunched, fromAccount=%@, fromResource=%@, callId=%lld, appContent=%@", fromAccount, fromResource, callId, appContent);
    
    self.answer = STATE_INIT;
    dispatch_async(dispatch_get_main_queue(), ^{
        voiceCallViewController  *_voiceCallView = [[voiceCallViewController alloc] init];
        _voiceCallView.receiver = fromAccount;
        _voiceCallView.audioConnState = @"邀请你进行语音通话";
        _voiceCallView.numButton = 2;
        _voiceCallView.callId = callId;
        [self.loginVC presentViewController:_voiceCallView animated:NO completion:nil];
        
        __weak typeof(self)weakSelf = self;
        _voiceCallView.callBackBlock = ^(int answer) {
            weakSelf.answer = answer;
        };
    });
    
    [self GDCTimer];
    
    while (self.answer != STATE_TIMEOUT) {
        if (self.answer == STATE_AGREE) {
            return [[MIMCLaunchedResponse alloc] initWithAccepted:true desc:@"answerOK"];
        }
        else if(self.answer == STATE_REJECT) {
            [self.OnCallStateDelegate onClosed:callId desc:@"answerNO"];
            return [[MIMCLaunchedResponse alloc] initWithAccepted:false desc:@"answerNO"];
        }
    }
    [self.OnCallStateDelegate onClosed:callId desc:@"answerTimeOut"];
    return [[MIMCLaunchedResponse alloc] initWithAccepted:false desc:@"answerTimeOut"];
}

- (void)onAnswered:(int64_t)callId accepted:(Boolean)accepted desc:(NSString *)desc {
    [self.OnCallStateDelegate onAnswered:callId accepted:accepted desc:desc];
}

- (void)onClosed:(int64_t)callId desc:(NSString *)desc {
    [self.OnCallStateDelegate onClosed:callId desc:desc];
}

- (void)onData:(int64_t)callId fromAccount:(NSString *)fromAccount resource:(NSString *)resource data:(NSData *)data dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType {
    [self.OnCallStateDelegate onData:callId fromAccount:fromAccount resource:resource data:data dataType:dataType channelType:channelType];
}

- (void)onSendDataSuccess:(int64_t)callId dataId:(int)dataId context:(id)context {
    NSLog(@"onSendDataSuccess, callId=%lld, dataId=%d", callId, dataId);
}

- (void)onSendDataFailure:(int64_t)callId dataId:(int)dataId context:(id)context {
    NSLog(@"onSendDataFailure, callId=%lld, dataId=%d", callId, dataId);
}

- (NSString *)getAppAccount {
    return self.appAccount;
}

- (void)setAppAccount:(NSString *)appAccount {
    _appAccount = appAccount;
}

- (MCUser *)getUser {
    return self.user;
}

- (void)setUser:(MCUser *)user {
    _user = user;
}

- (void)setLoginVC:(UIViewController *)loginVC {
    _loginVC = loginVC;
}

@end
