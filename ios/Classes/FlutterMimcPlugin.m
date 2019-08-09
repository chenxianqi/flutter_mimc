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
    if ([@"init" isEqualToString:call.method]) {
        
        NSString *appIdStr = argsMap[@"appId"];
        NSString *appKey = argsMap[@"appKey"];
        NSString *appSecret = argsMap[@"appSecret"];
        NSString *appAccount = argsMap[@"appAccount"];
        bool isDebug = argsMap[@"debug"];
        if(isDebug == 1){[MCUser setMIMCLogSwitch:isDebug];};
        int64_t appId =[appIdStr longLongValue];
        [mimcUserManager initArgs:appId appKey:appKey appSecret:appSecret appAccount:appAccount];
        result(NULL);
        
    }else if ([@"login" isEqualToString:call.method]) {
        
        [mimcUserManager userLogin];
        mimcUserManager.getUser.onlineStatusDelegate = self;
        mimcUserManager.getUser.handleMessageDelegate = self;
        result(NULL);
        
    }else if ([@"logout" isEqualToString:call.method]) {
        
        [mimcUserManager userLogout];
        result(NULL);
        
    }else if ([@"sendMessage" isEqualToString:call.method]) {
        NSString *toAccount = argsMap[@"toAccount"];
        NSString *bizType = argsMap[@"bizType"];
        NSData *payload = [NSJSONSerialization dataWithJSONObject:argsMap[@"message"] options:NSJSONWritingPrettyPrinted error:nil];
        [mimcUserManager.getUser sendMessage:toAccount payload: payload bizType: bizType];
        result(NULL);
    } else {
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
        NSLog(@"消息, {%@}-->{%@}, packetId=%@, payload=%@, bizType=%@", p.getFromAccount, user.getAppAccount, p.getPacketId, p.getPayload, p.getBizType);
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
    NSLog(@"handleGroupMessage, Called");
}


// 发送消息服务器回调确认
- (void)handleServerAck:(MIMCServerAck *)serverAck {
    NSLog(@"handleServerAck, ReceiveMessageAck, ackPacketId=%@, sequence=%lld, timestamp=%lld, code=%d, desc=%@", serverAck.getPacketId, serverAck.getSequence, serverAck.getTimestamp, serverAck.getCode, serverAck.getDesc);
}



// 发送单聊消息超时
- (void)handleSendMessageTimeout:(MIMCMessage *)message {
    NSLog(@"handleSendMessageTimeout, message.packetId=%@, message.sequence=%lld, message.timestamp=%lld, message.fromAccount=%@, message.toAccount=%@, message.payload=%@, message.bizType=%@", message.getPacketId, message.getSequence, message.getTimestamp, message.getFromAccount, message.getToAccount, message.getPayload, message.getBizType);
}

// 发送群聊消息超时
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage {
    NSLog(@"handleSendGroupMessageTimeout, groupMessag.packetId=%@, groupMessag.sequence=%lld, groupMessage.timestamp=%lld, groupMessage.fromAccount=%@, groupMessage.topicId=%lld, groupMessag.payload=%@, groupMessag.bizType=%@", groupMessage.getPacketId, groupMessage.getSequence, groupMessage.getTimestamp, groupMessage.getFromAccount, groupMessage.getTopicId, groupMessage.getPayload, groupMessage.getBizType);
}

// 接收无限群消息
- (void)handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets {
    NSLog(@"handleUnlimitedGroupMessage");
}

// 发送无限群消息超时
- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage {
    NSLog(@"handleSendUnlimitedGroupMessageTimeout, groupMessage=%@", groupMessage);
}


- (void)handleCreateUnlimitedGroup:(int64_t)topicId topicName:(NSString *)topicName success:(Boolean)success desc:(NSString *)desc context:(id)context {
    <#code#>
}

- (void)handleDismissUnlimitedGroup:(int64_t)topicId {
    <#code#>
}

- (void)handleDismissUnlimitedGroup:(Boolean)success desc:(NSString *)desc context:(id)context {
    <#code#>
}

- (void)handleJoinUnlimitedGroup:(int64_t)topicId code:(int)code message:(NSString *)message context:(id)context {
    <#code#>
}

- (void)handleQuitUnlimitedGroup:(int64_t)topicId code:(int)code message:(NSString *)message context:(id)context {
    <#code#>
}

@end
