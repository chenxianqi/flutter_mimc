#import "FlutterMimcPlugin.h"
#import "FlutterMimcEvent.h"
#import "XMUserManager.h"

@implementation FlutterMimcPlugin

FlutterMimcEvent *mimcEvent;
XMUserManager *mimcUserManager;
AFHTTPSessionManager *httpManager;


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
    httpManager = [AFHTTPSessionManager manager];
    [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* argsMap = call.arguments;
    // 初始化
    if ([@"init" isEqualToString:call.method]) {
        
        NSString *appIdStr = argsMap[@"appId"];
        NSString *appKey = argsMap[@"appKey"];
        NSString *appSecret = argsMap[@"appSecret"];
        NSString *appAccount = argsMap[@"appAccount"];
        bool isDebug = argsMap[@"debug"];
        if(isDebug == 1){[MCUser setMIMCLogSwitch:YES];};
        int64_t appId =[appIdStr longLongValue];
        [mimcUserManager initArgs:appId appKey:appKey appSecret:appSecret appAccount:appAccount];
        result(NULL);
        
    }
    // 登录
    else if ([@"login" isEqualToString:call.method]) {
        
        [mimcUserManager userLogin];
        mimcUserManager.getUser.onlineStatusDelegate = self;
        mimcUserManager.getUser.handleMessageDelegate = self;
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
    
    // 发送单聊
    else if ([@"sendMessage" isEqualToString:call.method]) {
        
        NSString *toAccount = argsMap[@"toAccount"];
        NSString *bizType = argsMap[@"bizType"];
        NSData *payload = [NSJSONSerialization dataWithJSONObject:argsMap[@"message"] options:NSJSONWritingPrettyPrinted error:nil];
        result([mimcUserManager.getUser sendMessage:toAccount payload: payload bizType: bizType]);
        
    }
    
    // 发送群聊
    else if ([@"sendGroupMsg" isEqualToString:call.method]) {
        
        NSDictionary *message = argsMap[@"message"];
        NSNumber *topicId = [message valueForKey:@"topicId"];
        NSString *bizType = [message valueForKey:@"bizType"];
        bool isUnlimitedGroup = argsMap[@"isUnlimitedGroup"];
        NSData *payload = [NSJSONSerialization dataWithJSONObject:[message valueForKey:@"message"] options:NSJSONWritingPrettyPrinted error:nil];
        if(isUnlimitedGroup != 1){
            result([mimcUserManager.getUser sendGroupMessage:[topicId longLongValue] payload:payload bizType:bizType]);
        }else{
            result([mimcUserManager.getUser sendUnlimitedGroupMessage:[topicId longLongValue] payload:payload bizType:bizType]);
        }

        
    }
    
    // 创建普通群
    else if ([@"createGroup" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *groupName = argsMap[@"groupName"];
        NSString *users = argsMap[@"users"];
        if([groupName isEqual: @""]){
            [dic setValue:@"groupName不能为空!" forKey:@"message"];
             result(dic);
            return;
        }
        NSNumber *appid = [NSNumber numberWithLongLong:mimcUserManager.getUser.getAppId];
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/topic/"];
        [httpUrl appendString:[appid stringValue]];
        NSDictionary *parameters = @{@"topicName": groupName, @"accounts": users};
        httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        [httpManager POST:httpUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            int code = [[responseObject valueForKey:@"code"] intValue];
            NSString *message = [responseObject valueForKey:@"message"];
            NSDictionary *data = [responseObject valueForKey:@"data"];
            if(code == 200){
                [dic setValue:data forKey:@"data"];
                [dic setValue:@YES forKey:@"success"];
                result(dic);
            }else{
                [dic setValue:message forKey:@"message"];
                result(dic);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [dic setValue:error forKey:@"message"];
            result(dic);
        }];
    }
    
    // 查询群
    else if ([@"queryGroupInfo" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *groupId = argsMap[@"groupId"];
        if([groupId isEqual: @""]){
            [dic setValue:@"groupId不能为空!" forKey:@"message"];
            result(dic);
            return;
        }
        NSNumber *appid = [NSNumber numberWithLongLong:mimcUserManager.getUser.getAppId];
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/topic/"];
        [httpUrl appendString:[appid stringValue]];
        [httpUrl appendString:@"/"];
        [httpUrl appendString: groupId];
        httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        [httpManager GET:httpUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            int code = [[responseObject valueForKey:@"code"] intValue];
            NSString *message = [responseObject valueForKey:@"message"];
            NSDictionary *data = [responseObject valueForKey:@"data"];
            if(code == 200){
                [dic setValue:data forKey:@"data"];
                [dic setValue:@YES forKey:@"success"];
                result(dic);
            }else{
                [dic setValue:message forKey:@"message"];
                result(dic);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [dic setValue:error forKey:@"message"];
            result(dic);
        }];
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
        NSDictionary * message = [NSJSONSerialization JSONObjectWithData:p.getPayload options:NSJSONReadingMutableContainers error:nil];
        NSNumber *timestamp = [NSNumber numberWithLongLong:p.getTimestamp];
        [dic setObject:user.getAppAccount forKey:@"toAccount"];
        [dic setObject:@0 forKey:@"topicId"];
        [dic setObject:p.getFromAccount forKey:@"fromAccount"];
        [dic setObject:p.getBizType forKey:@"bizType"];
        [dic setObject:message forKey:@"message"];
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
        NSDictionary * message = [NSJSONSerialization JSONObjectWithData:p.getPayload options:NSJSONReadingMutableContainers error:nil];
        NSNumber *timestamp = [NSNumber numberWithLongLong:p.getTimestamp];
        NSNumber *topicId = [NSNumber numberWithLongLong:p.getTopicId];
        [dic setObject:@"0" forKey:@"toAccount"];
        [dic setObject:topicId forKey:@"topicId"];
        [dic setObject:p.getFromAccount forKey:@"fromAccount"];
        [dic setObject:p.getBizType forKey:@"bizType"];
        [dic setObject:message forKey:@"message"];
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
    NSLog(@"handleServerAck, ReceiveMessageAck, ackPacketId=%@, sequence=%lld, timestamp=%lld, code=%d, desc=%@", serverAck.getPacketId, serverAck.getSequence, serverAck.getTimestamp, serverAck.getCode, serverAck.getDesc);
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
    NSDictionary * msg = [NSJSONSerialization JSONObjectWithData:message.getPayload options:NSJSONReadingMutableContainers error:nil];
    [dic setObject:message.getToAccount forKey:@"toAccount"];
    [dic setObject:@0 forKey:@"topicId"];
    [dic setObject:message.getFromAccount forKey:@"fromAccount"];
    [dic setObject:message.getBizType forKey:@"bizType"];
    [dic setObject:msg forKey:@"message"];
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
    NSDictionary * message = [NSJSONSerialization JSONObjectWithData:groupMessage.getPayload options:NSJSONReadingMutableContainers error:nil];
    NSNumber *timestamp = [NSNumber numberWithLongLong:groupMessage.getTimestamp];
    NSNumber *topicId = [NSNumber numberWithLongLong:groupMessage.getTopicId];
    [dic setObject:@"0" forKey:@"toAccount"];
    [dic setObject:topicId forKey:@"topicId"];
    [dic setObject:groupMessage.getFromAccount forKey:@"fromAccount"];
    [dic setObject:groupMessage.getBizType forKey:@"bizType"];
    [dic setObject:message forKey:@"message"];
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
        NSDictionary * message = [NSJSONSerialization JSONObjectWithData:p.getPayload options:NSJSONReadingMutableContainers error:nil];
        NSNumber *timestamp = [NSNumber numberWithLongLong:p.getTimestamp];
        NSNumber *topicId = [NSNumber numberWithLongLong:p.getTopicId];
        [dic setObject:@"0" forKey:@"toAccount"];
        [dic setObject:topicId forKey:@"topicId"];
        [dic setObject:p.getFromAccount forKey:@"fromAccount"];
        [dic setObject:p.getBizType forKey:@"bizType"];
        [dic setObject:message forKey:@"message"];
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
    NSDictionary * message = [NSJSONSerialization JSONObjectWithData:groupMessage.getPayload options:NSJSONReadingMutableContainers error:nil];
    NSNumber *timestamp = [NSNumber numberWithLongLong:groupMessage.getTimestamp];
    NSNumber *topicId = [NSNumber numberWithLongLong:groupMessage.getTopicId];
    [dic setObject:@"0" forKey:@"toAccount"];
    [dic setObject:topicId forKey:@"topicId"];
    [dic setObject:groupMessage.getFromAccount forKey:@"fromAccount"];
    [dic setObject:groupMessage.getBizType forKey:@"bizType"];
    [dic setObject:message forKey:@"message"];
    [dic setObject:timestamp forKey:@"timestamp"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleSendUnlimitedGroupMessageTimeout",
            @"eventValue": dic,
        });
    }
}


- (void)handleCreateUnlimitedGroup:(int64_t)topicId topicName:(NSString *)topicName success:(Boolean)success desc:(NSString *)desc context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *tID = [NSNumber numberWithLongLong:topicId];
    NSNumber *code = [NSNumber numberWithInt:success ? 0 : -1];
    [dic setObject:tID forKey:@"topicId"];
    [dic setObject:topicName forKey:@"topicName"];
    [dic setObject:code forKey:@"code"];
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

- (void)handleDismissUnlimitedGroup:(Boolean)success desc:(NSString *)desc context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *code = [NSNumber numberWithInt:success ? 0 : -1];
    [dic setObject:@0 forKey:@"topicId"];
    [dic setObject:@"" forKey:@"topicName"];
    [dic setObject:code forKey:@"code"];
    [dic setObject:desc forKey:@"errMsg"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleDismissUnlimitedGroup",
            @"eventValue": dic,
        });
    }
}

- (void)handleJoinUnlimitedGroup:(int64_t)topicId code:(int)code message:(NSString *)message context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *tID = [NSNumber numberWithLongLong:topicId];
    NSNumber *cd = [NSNumber numberWithInt:code];
    [dic setObject:tID forKey:@"topicId"];
    [dic setObject:@"" forKey:@"topicName"];
    [dic setObject:cd forKey:@"code"];
    [dic setObject:message forKey:@"errMsg"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleJoinUnlimitedGroup",
            @"eventValue": dic,
        });
    }
}

- (void)handleQuitUnlimitedGroup:(int64_t)topicId code:(int)code message:(NSString *)message context:(id)context {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSNumber *tID = [NSNumber numberWithLongLong:topicId];
    NSNumber *cd = [NSNumber numberWithInt:code];
    [dic setObject:tID forKey:@"topicId"];
    [dic setObject:@"" forKey:@"topicName"];
    [dic setObject:cd forKey:@"code"];
    [dic setObject:message forKey:@"errMsg"];
    FlutterEventSink eventSink = mimcEvent.eventSink;
    if(eventSink){
        eventSink(@{
            @"eventType" : @"onHandleQuitUnlimitedGroup",
            @"eventValue": dic,
        });
    }
}


@end
