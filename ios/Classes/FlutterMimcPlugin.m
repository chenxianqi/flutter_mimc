#import "FlutterMimcPlugin.h"
#import "FlutterMimcEvent.h"
#import "XMUserManager.h"

@implementation FlutterMimcPlugin

FlutterMimcEvent *mimcEvent;
XMUserManager *mimcUserManager;


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
    methodChannelWithName:@"flutter_mimc"
    binaryMessenger:[registrar messenger]];
    FlutterMimcPlugin* instance = [[FlutterMimcPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    mimcEvent = [[FlutterMimcEvent alloc] init];
    mimcEvent.eventChannel = [FlutterEventChannel
                              eventChannelWithName:@"flutter_mimc.event"
                              binaryMessenger:[registrar messenger]];
    [mimcEvent.eventChannel setStreamHandler:mimcEvent];
    mimcUserManager = [[XMUserManager alloc] init];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* argsMap = call.arguments;

    // 通过服务端的鉴权获得的String 初始化
    if ([@"init" isEqualToString:call.method]) {
        
        NSString *tokenString = argsMap[@"token"];
        BOOL isDebug = [argsMap[@"debug"] boolValue];
        if(isDebug == YES){
            NSLog(@"打开log");
            [MCUser setMIMCLogSwitch:YES];
        };
        [mimcUserManager initStringToken:tokenString];
        result(NULL);
        
    }
    // 登录
    else if ([@"login" isEqualToString:call.method]) {
        
        [mimcUserManager userLogin];
        mimcUserManager.getUser.onlineStatusDelegate = self;
        mimcUserManager.getUser.handleMessageDelegate = self;
        mimcUserManager.getUser.handleUnlimitedGroupDelegate = self;
        result(NULL);
        
    }
    
    // 登录
    else if ([@"login" isEqualToString:call.method]) {
        
        [mimcUserManager userLogin];
        mimcUserManager.getUser.onlineStatusDelegate = self;
        mimcUserManager.getUser.handleMessageDelegate = self;
        mimcUserManager.getUser.handleUnlimitedGroupDelegate = self;
        result(NULL);
        
    }
    
    // 退出登录
    else if ([@"logout" isEqualToString:call.method]) {
        
        [mimcUserManager userLogout];
        result(NULL);
        
    }
    
    // 获取在线状态
    else if ([@"isOnline" isEqualToString:call.method]) {
        
        BOOL isOnline = [mimcUserManager.getUser isOnline];
        [NSNumber numberWithBool:isOnline];
        result([NSNumber numberWithBool:isOnline]);
        
    }
    
    // 获取token
    else if ([@"getToken" isEqualToString:call.method]) {
        
        result([mimcUserManager.getUser getToken]);
        
    }
    
    // 获取getAccount
    else if ([@"getAccount" isEqualToString:call.method]) {
        
        result([mimcUserManager.getUser getAppAccount]);
        
    }
    
    // 获取getAppId
   else if ([@"getAppID" isEqualToString:call.method]) {
       
       result([mimcUserManager getAppId]);
       
   }
    
    // 发送单聊
    else if ([@"sendMessage" isEqualToString:call.method]) {
        
        NSString *toAccount = argsMap[@"toAccount"];
        NSString *bizType = argsMap[@"bizType"];
        NSString *payloadString = argsMap[@"payload"];
        BOOL isStore = argsMap[@"isStore"];
        NSData *payload = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
        
        result([mimcUserManager.getUser sendMessage:toAccount payload: payload bizType: bizType isStore:isStore]);

    }
    
    // 发送在线消息
    else if ([@"sendOnLineMessage" isEqualToString:call.method]) {
        
        NSString *toAccount = argsMap[@"toAccount"];
        NSString *bizType = argsMap[@"bizType"];
        NSString *payloadString = argsMap[@"payload"];
        NSData *payload = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
        result([mimcUserManager.getUser sendOnlineMessage:toAccount payload: payload bizType: bizType]);
        
    }
    
    // 发送群聊
    else if ([@"sendGroupMsg" isEqualToString:call.method]) {
        
        NSDictionary *message = argsMap[@"message"];
        NSNumber *topicId = [message valueForKey:@"topicId"];
        NSString *bizType = [message valueForKey:@"bizType"];
        bool isUnlimitedGroup = argsMap[@"isUnlimitedGroup"];
        NSString *payloadString = [message valueForKey:@"payload"];
        NSData *payload = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
        if(isUnlimitedGroup != 1){
            result([mimcUserManager.getUser sendGroupMessage:[topicId longLongValue] payload:payload bizType:bizType]);
        }else{
            result([mimcUserManager.getUser sendUnlimitedGroupMessage:[topicId longLongValue] payload:payload bizType:bizType]);
        }

        
    }

    
    
    
    // 创建无限大群
    // @param topicName 群名称
    else if ([@"createUnlimitedGroup" isEqualToString:call.method]) {
        NSString *topicName = argsMap[@"topicName"];
        NSLog(@"topicName==%@", topicName);
        [mimcUserManager.getUser createUnlimitedGroup:topicName context:self];
        result(NULL);
    }
    
    // 加入无限大群
    // @param topicId 群ID
    // @param context 用户自定义传入的对象，通过回调函数原样传出
    // @return String 客户端生成的消息ID
    else if ([@"joinUnlimitedGroup" isEqualToString:call.method]) {
        NSString *topicId = argsMap[@"topicId"];
        result([mimcUserManager.getUser joinUnlimitedGroup:[topicId longLongValue] context:self]);
    }
    
    // 退出无限大群
    // @param topicId 群ID
    // @param context 用户自定义传入的对象，通过回调函数原样传出
    // @return String 客户端生成的消息ID
    else if ([@"quitUnlimitedGroup" isEqualToString:call.method]) {
        NSString *topicId = argsMap[@"topicId"];
        result([mimcUserManager.getUser quitUnlimitedGroup:[topicId longLongValue] context:self]);
    }
    
    //  解散无限大群
    // @param topicId 群ID
    // @param context 用户自定义传入的对象，通过回调函数原样传出
    else if ([@"dismissUnlimitedGroup" isEqualToString:call.method]) {
        NSString *topicId = argsMap[@"topicId"];
        [mimcUserManager.getUser dismissUnlimitedGroup:[topicId longLongValue] context:self];
        result(NULL);
    }
    
    // 无匹配
    else {
        result(FlutterMethodNotImplemented);
    }
}

// 登录状态变更
- (void)statusChange:(MCUser *)user status:(int)status type:(NSString *)type reason:(NSString *)reason desc:(NSString *)desc {
    if (mimcUserManager.getUser == nil) {
        NSLog(@"statusChange, user is nil");
        return;
    }
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onlineStatusListener",
            @"eventValue" : status == 1 ? @YES : @NO,
        });
    }
}

// 接收单聊消息
- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user {
    for (MIMCMessage *p in packets) {
        if (p == nil) {
            NSLog(@"handleMessage, ReceiveMessage, P2P is nil");
            continue;
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *payload = [[NSString alloc] initWithData:p.getPayload encoding:NSUTF8StringEncoding];
        NSNumber *timestamp = [NSNumber numberWithLongLong:p.getTimestamp];
        NSNumber *sequence = [NSNumber numberWithLongLong:p.getSequence];
        
        [dic setObject:sequence forKey:@"sequence"];
        [dic setObject:user.getAppAccount forKey:@"toAccount"];
        [dic setObject:@0 forKey:@"topicId"];
        [dic setObject:p.getFromAccount forKey:@"fromAccount"];
        [dic setObject:p.getBizType forKey:@"bizType"];
        [dic setObject:payload forKey:@"payload"];
        [dic setObject:timestamp forKey:@"timestamp"];
        FlutterEventSink eventSink = mimcEvent.eventSink;
        if(eventSink){
            eventSink(@{
                @"eventType" : @"onHandleMessage",
                @"eventValue": dic,
            });
        }
    }
}

// 接收群聊消息
- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets {
    for (MIMCGroupMessage *p in packets) {
        if (p == nil) {
            NSLog(@"handleMessage, ReceiveMessage, P2P is nil");
            continue;
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *payload = [[NSString alloc] initWithData:p.getPayload encoding:NSUTF8StringEncoding];
        NSNumber *timestamp = [NSNumber numberWithLongLong:p.getTimestamp];
        NSNumber *topicId = [NSNumber numberWithLongLong:p.getTopicId];
        [dic setObject:@"0" forKey:@"toAccount"];
        [dic setObject:topicId forKey:@"topicId"];
        [dic setObject:p.getFromAccount forKey:@"fromAccount"];
        [dic setObject:p.getBizType forKey:@"bizType"];
        [dic setObject:payload forKey:@"payload"];
        [dic setObject:timestamp forKey:@"timestamp"];
        FlutterEventSink eventSink = mimcEvent.eventSink;
        if(eventSink){
            eventSink(@{
                @"eventType" : @"onHandleGroupMessage",
                @"eventValue": dic,
            });
        }
    }
    
}

// 发送消息服务器回调确认
- (void)handleServerAck:(MIMCServerAck *)serverAck {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *timestamp = [NSNumber numberWithLongLong:serverAck.getTimestamp];
    NSNumber *sequence = [NSNumber numberWithLongLong:serverAck.getSequence];
    NSNumber *code = [NSNumber numberWithLongLong:serverAck.getCode];
    [dic setObject:serverAck.getPacketId forKey:@"packetId"];
    [dic setObject:sequence forKey:@"sequence"];
    [dic setObject:timestamp forKey:@"timestamp"];
    [dic setObject:code forKey:@"code"];
    [dic setObject:serverAck.getDesc forKey:@"desc"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleServerAck",
            @"eventValue": dic,
        });
    }
}



// 发送单聊消息超时
- (void)handleSendMessageTimeout:(MIMCMessage *)message {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *timestamp = [NSNumber numberWithLongLong:message.getTimestamp];
    NSString *payload = [[NSString alloc] initWithData:message.getPayload encoding:NSUTF8StringEncoding];
    [dic setObject:message.getToAccount forKey:@"toAccount"];
    [dic setObject:@0 forKey:@"topicId"];
    [dic setObject:message.getFromAccount forKey:@"fromAccount"];
    [dic setObject:message.getBizType forKey:@"bizType"];
    [dic setObject:payload forKey:@"payload"];
    [dic setObject:timestamp forKey:@"timestamp"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleSendMessageTimeout",
            @"eventValue": dic,
        });
    }
    
}

// 发送群聊消息超时
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *payload = [[NSString alloc] initWithData:groupMessage.getPayload encoding:NSUTF8StringEncoding];
    NSNumber *timestamp = [NSNumber numberWithLongLong:groupMessage.getTimestamp];
    NSNumber *topicId = [NSNumber numberWithLongLong:groupMessage.getTopicId];
    [dic setObject:@"0" forKey:@"toAccount"];
    [dic setObject:topicId forKey:@"topicId"];
    [dic setObject:groupMessage.getFromAccount forKey:@"fromAccount"];
    [dic setObject:groupMessage.getBizType forKey:@"bizType"];
    [dic setObject:payload forKey:@"payload"];
    [dic setObject:timestamp forKey:@"timestamp"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleSendGroupMessageTimeout",
            @"eventValue": dic,
        });
    }
}

// 接收无限群消息
- (void)handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets {
    for (MIMCGroupMessage *p in packets) {
        if (p == nil) {
            NSLog(@"handleMessage, ReceiveMessage, P2P is nil");
            continue;
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *payload = [[NSString alloc] initWithData:p.getPayload encoding:NSUTF8StringEncoding];
        NSNumber *timestamp = [NSNumber numberWithLongLong:p.getTimestamp];
        NSNumber *topicId = [NSNumber numberWithLongLong:p.getTopicId];
        [dic setObject:@"0" forKey:@"toAccount"];
        [dic setObject:topicId forKey:@"topicId"];
        [dic setObject:p.getFromAccount forKey:@"fromAccount"];
        [dic setObject:p.getBizType forKey:@"bizType"];
        [dic setObject:payload forKey:@"payload"];
        [dic setObject:timestamp forKey:@"timestamp"];
        FlutterEventSink eventSink = mimcEvent.eventSink;
        if(eventSink){
            eventSink(@{
                @"eventType" : @"onHandleGroupMessage",
                @"eventValue": dic,
            });
        }
    }
}



// 发送无限群消息超时
- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *payload = [[NSString alloc] initWithData:groupMessage.getPayload encoding:NSUTF8StringEncoding];
    NSNumber *timestamp = [NSNumber numberWithLongLong:groupMessage.getTimestamp];
    NSNumber *topicId = [NSNumber numberWithLongLong:groupMessage.getTopicId];
    [dic setObject:@"0" forKey:@"toAccount"];
    [dic setObject:topicId forKey:@"topicId"];
    [dic setObject:groupMessage.getFromAccount forKey:@"fromAccount"];
    [dic setObject:groupMessage.getBizType forKey:@"bizType"];
    [dic setObject:payload forKey:@"payload"];
    [dic setObject:timestamp forKey:@"timestamp"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleSendUnlimitedGroupMessageTimeout",
            @"eventValue": dic,
        });
    }
}

// 接收在线消息
- (void)handleOnlineMessage:(MIMCMessage *)onlineMessage {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *payload = [[NSString alloc] initWithData:onlineMessage.getPayload encoding:NSUTF8StringEncoding];
    NSNumber *timestamp = [NSNumber numberWithLongLong:onlineMessage.getTimestamp];
    NSNumber *sequence = [NSNumber numberWithLongLong:onlineMessage.getSequence];

    [dic setObject:sequence forKey:@"sequence"];
    [dic setObject:onlineMessage.getToAccount forKey:@"toAccount"];
    [dic setObject:@0 forKey:@"topicId"];
    [dic setObject:onlineMessage.getFromAccount forKey:@"fromAccount"];
    [dic setObject:onlineMessage.getBizType forKey:@"bizType"];
    [dic setObject:payload forKey:@"payload"];
    [dic setObject:timestamp forKey:@"timestamp"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleOnlineMessage",
            @"eventValue": dic,
        });
    }
    
}

// 发送在线消息回调Ack
- (void)handleOnlineMessageAck:(MCOnlineMessageAck *)onlineMessageAck {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *code = [NSNumber numberWithLongLong:onlineMessageAck.getCode];
    [dic setObject:onlineMessageAck.getPacketId forKey:@"packetId"];
    [dic setObject:@"" forKey:@"sequence"];
    [dic setObject:onlineMessageAck.getDesc forKey:@"timestamp"];
    [dic setObject:code forKey:@"code"];
    [dic setObject:onlineMessageAck.getDesc forKey:@"desc"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleOnlineMessageAck",
            @"eventValue": dic,
        });
    }
}

- (void)handleCreateUnlimitedGroup:(int64_t)topicId topicName:(NSString *)topicName code:(int)code desc:(NSString *)desc context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *tID = [NSNumber numberWithLongLong:topicId];
    NSNumber *_code = [NSNumber numberWithInt:code];
    [dic setObject:tID forKey:@"topicId"];
    [dic setObject:topicName forKey:@"topicName"];
    [dic setObject:_code forKey:@"code"];
    [dic setObject:desc forKey:@"errMsg"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleCreateUnlimitedGroup",
            @"eventValue": dic,
        });
    }
}

- (void)handleDismissUnlimitedGroup:(int64_t)topicId {
    
}

- (void)handleDismissUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *_code = [NSNumber numberWithInt:code];
    [dic setObject:@0 forKey:@"topicId"];
    [dic setObject:@"" forKey:@"topicName"];
    [dic setObject:_code forKey:@"code"];
    [dic setObject:desc forKey:@"errMsg"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleDismissUnlimitedGroup",
            @"eventValue": dic,
        });
    }
}

- (void)handleJoinUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *tID = [NSNumber numberWithLongLong:topicId];
    NSNumber *cd = [NSNumber numberWithInt:code];
    [dic setObject:tID forKey:@"topicId"];
    [dic setObject:@"" forKey:@"topicName"];
    [dic setObject:cd forKey:@"code"];
    [dic setObject:desc forKey:@"errMsg"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleJoinUnlimitedGroup",
            @"eventValue": dic,
        });
    }
}

- (void)handleQuitUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
   NSNumber *tID = [NSNumber numberWithLongLong:topicId];
   NSNumber *cd = [NSNumber numberWithInt:code];
   [dic setObject:tID forKey:@"topicId"];
   [dic setObject:@"" forKey:@"topicName"];
   [dic setObject:cd forKey:@"code"];
   [dic setObject:desc forKey:@"errMsg"];
   FlutterEventSink eventSink = mimcEvent.eventSink;
   if(eventSink){
       eventSink(@{
           @"eventType" : @"onHandleQuitUnlimitedGroup",
           @"eventValue": dic,
       });
   }
}

@end
