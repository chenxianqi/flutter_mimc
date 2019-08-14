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
    
    // httpManager
    httpManager = [AFHTTPSessionManager manager];
    [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* argsMap = call.arguments;
    // 初始化
    if ([@"init" isEqualToString:call.method]) {
        
        NSString *appIdStr = argsMap[@"appId"];
        NSString *appKey = argsMap[@"appKey"];
        NSString *appSecret = argsMap[@"appSecret"];
        NSString *appAccount = argsMap[@"appAccount"];
        BOOL isDebug = [argsMap[@"debug"] boolValue];
        NSLog(@"call.arguments%@", call.arguments);
        if(isDebug == YES){
            NSLog(@"打开了log=%@", appIdStr);
            [MCUser setMIMCLogSwitch:YES];
        };
        int64_t appId =[appIdStr longLongValue];
        [mimcUserManager initArgs:appId appKey:appKey appSecret:appSecret appAccount:appAccount];
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
    
    // 发送单聊
    else if ([@"sendMessage" isEqualToString:call.method]) {
        
        NSString *toAccount = argsMap[@"toAccount"];
        NSString *bizType = argsMap[@"bizType"];
        NSString *payloadString = argsMap[@"payload"];
        NSData *payload = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
        result([mimcUserManager.getUser sendMessage:toAccount payload: payload bizType: bizType]);
        
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
    
    // 创建普通群
    // @param groupName 群名
    // @param users 群成员，多个成员之间用英文逗号(,)分隔
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
    
    // 查询群信息
    // @param groupId 群ID
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
    
    // 查询所属群信息
    // @param groupId 群ID
    else if ([@"queryGroupsOfAccount" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSNumber *appid = [NSNumber numberWithLongLong:mimcUserManager.getUser.getAppId];
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/topic/"];
        [httpUrl appendString:[appid stringValue]];
        [httpUrl appendString:@"/account"];
        [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        [httpManager GET:httpUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            int code = [[responseObject valueForKey:@"code"] intValue];
            NSString *message = [responseObject valueForKey:@"message"];
            NSArray *data = [responseObject valueForKey:@"data"];
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
    
    // 邀请用户加入群
    // @param groupId 群ID
    // @param users 加入成员，多个成员之间用英文逗号(,)分隔
    else if ([@"joinGroup" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *groupId = argsMap[@"groupId"];
        NSString *users = argsMap[@"users"];
        if([groupId isEqual: @""] || [users isEqual: @""]){
            [dic setValue:@"groupId或users不能为空！" forKey:@"message"];
            result(dic);
            return;
        }
        NSNumber *appid = [NSNumber numberWithLongLong:mimcUserManager.getUser.getAppId];
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/topic/"];
        [httpUrl appendString:[appid stringValue]];
        [httpUrl appendString: @"/"];
        [httpUrl appendString: groupId];
        [httpUrl appendString: @"/accounts"];
        NSDictionary *parameters = @{@"accounts": users};
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
    
    // 非群主成员退群
    // @param groupId 群ID
    else if ([@"quitGroup" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *groupId = argsMap[@"groupId"];
        if([groupId isEqual: @""]){
            [dic setValue:@"groupId不能为空！" forKey:@"message"];
            result(dic);
            return;
        }
        NSNumber *appid = [NSNumber numberWithLongLong:mimcUserManager.getUser.getAppId];
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/topic/"];
        [httpUrl appendString:[appid stringValue]];
        [httpUrl appendString: @"/"];
        [httpUrl appendString: groupId];
        [httpUrl appendString: @"/account"];
        [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        [httpManager DELETE:httpUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            int code = [[responseObject valueForKey:@"code"] intValue];
            NSString *message = [responseObject valueForKey:@"message"];
            if(code == 200){
                [dic setValue:@"" forKey:@"data"];
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
    
    // 群主踢成员出群
    // @param groupId 群ID
    // @param users 群成员，多个成员之间用英文逗号(,)分隔
    else if ([@"kickGroup" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *groupId = argsMap[@"groupId"];
        NSString *users = argsMap[@"users"];
        if([groupId isEqual: @""] || [users isEqual: @""]){
            [dic setValue:@"groupId或users不能为空！" forKey:@"message"];
            result(dic);
            return;
        }
        NSNumber *appid = [NSNumber numberWithLongLong:mimcUserManager.getUser.getAppId];
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/topic/"];
        [httpUrl appendString:[appid stringValue]];
        [httpUrl appendString: @"/"];
        [httpUrl appendString: groupId];
        [httpUrl appendString: @"/accounts?accounts="];
        [httpUrl appendString: users];
        [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        [httpManager DELETE:httpUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    // 群主更新群信息
    // @param groupId 群ID
    // @param newOwnerAccount 若为群成员则指派新的群主
    // @param newGroupName 群名
    // @param newGroupBulletin 群公告
    else if ([@"updateGroup" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *groupId = argsMap[@"groupId"];
         NSString *newOwnerAccount = argsMap[@"newOwnerAccount"];
         NSString *newGroupName = argsMap[@"newGroupName"];
        NSString *newGroupBulletin = argsMap[@"newGroupBulletin"];
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
        [httpUrl appendString: @"/"];
        [httpUrl appendString:groupId];
        NSDictionary *parameters = [NSMutableDictionary dictionary];
        if(![newOwnerAccount isEqual: @""]){
            [parameters setValue:newOwnerAccount forKey:@"ownerAccount"];
        }
        if(![newGroupName isEqual: @""]){
            [parameters setValue:newGroupName forKey:@"topicName"];
        }
        if(![newGroupBulletin isEqual: @""]){
            [parameters setValue:newGroupBulletin forKey:@"bulletin"];
        }
        [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        [httpManager PUT:httpUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    // 群主销毁群
    // @param groupId 群ID
    else if ([@"dismissGroup" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *groupId = argsMap[@"groupId"];
        if([groupId isEqual: @""]){
            [dic setValue:@"groupId不能为空！" forKey:@"message"];
            result(dic);
            return;
        }
        NSNumber *appid = [NSNumber numberWithLongLong:mimcUserManager.getUser.getAppId];
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/topic/"];
        [httpUrl appendString:[appid stringValue]];
        [httpUrl appendString: @"/"];
        [httpUrl appendString: groupId];
        [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        [httpManager DELETE:httpUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    // 拉取单聊消息记录
    // @param toAccount 接收方帐号
    // @param fromAccount 发送方帐号
    // @param utcFromTime 开始时间
    // @param utcToTime 结束时间
    // 注意：utcFromTime和utcToTime的时间间隔不能超过24小时，查询状态为[utcFromTime,utcToTime)，单位毫秒，UTC时间
    else if ([@"pullP2PHistory" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *toAccount = argsMap[@"toAccount"];
        NSString *fromAccount = argsMap[@"fromAccount"];
        NSString *utcFromTime = argsMap[@"utcFromTime"];
        NSString *utcToTime = argsMap[@"utcToTime"];
        if([toAccount isEqual: @""] || [fromAccount isEqual: @""] || [utcFromTime isEqual: @""]|| [utcToTime isEqual: @""]){
            [dic setValue:@"所有参数不能为空!" forKey:@"message"];
            result(dic);
            return;
        }
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/msg/p2p/query/"];
        NSDictionary *parameters = @{@"toAccount": toAccount, @"fromAccount": fromAccount, @"utcFromTime": utcFromTime, @"utcToTime": utcToTime};
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
    
    //  拉取群聊消息记录
    // @param account 拉取者帐号
    // @param topicId 群ID
    // @param utcFromTime 开始时间
    // @param utcToTime 结束时间
    // 注意：utcFromTime和utcToTime的时间间隔不能超过24小时，查询状态为[utcFromTime,utcToTime)，单位毫秒，UTC时间
    else if ([@"pullP2THistory" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *account = argsMap[@"account"];
        NSString *topicId = argsMap[@"topicId"];
        NSString *utcFromTime = argsMap[@"utcFromTime"];
        NSString *utcToTime = argsMap[@"utcToTime"];
        if([account isEqual: @""] || [topicId isEqual: @""] || [utcFromTime isEqual: @""]|| [utcToTime isEqual: @""]){
            [dic setValue:@"所有参数不能为空!" forKey:@"message"];
            result(dic);
            return;
        }
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/msg/p2t/query/"];
        NSDictionary *parameters = @{@"account": account, @"topicId": topicId, @"utcFromTime": utcFromTime, @"utcToTime": utcToTime};
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
    
    // 查询无限大群成员
    // @param topicId 群ID
    else if ([@"queryUnlimitedGroupMembers" isEqualToString:call.method]) {
        NSString *topicId = argsMap[@"topicId"];
        [self unlimitedGroupQueryInfo:topicId url:@"/api/uctopic/userlist/" result:result];
    }
    
    // 查询无限大群所属群
    else if ([@"queryUnlimitedGroups" isEqualToString:call.method]) {
        [self unlimitedGroupQueryInfo:@"null" url:@"/api/uctopic/topics" result:result];
    }
    
    // 查询无限大群在线用户数
    // @param topicId 群ID
    else if ([@"queryUnlimitedGroupOnlineUsers" isEqualToString:call.method]) {
        NSString *topicId = argsMap[@"topicId"];
        [self unlimitedGroupQueryInfo:topicId url:@"/api/uctopic/onlineinfo" result:result];
    }
    
    // 查询无限大群基本信息
    // @param topicId 群ID
    else if ([@"queryUnlimitedGroupInfo" isEqualToString:call.method]) {
        NSString *topicId = argsMap[@"topicId"];
        [self unlimitedGroupQueryInfo:topicId url:@"/api/uctopic/topic" result:result];
    }
    
    // 更新大群
    // @param topicId 群ID
    // @param newOwnerAccount 若为群成员则指派新的群主
    // @param newGroupName 群名
    else if ([@"updateUnlimitedGroup" isEqualToString:call.method]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"" forKey:@"data"];
        [dic setValue:@NO forKey:@"success"];
        [dic setValue:@"" forKey:@"message"];
        NSString *topicId = argsMap[@"topicId"];
        NSString *newOwnerAccount = argsMap[@"newOwnerAccount"];
        NSString *newGroupName = argsMap[@"newGroupName"];
        if([topicId isEqual: @""]){
            [dic setValue:@"topicId不能为空!" forKey:@"message"];
            result(dic);
            return;
        }
        NSString *token = [mimcUserManager.getUser getToken];
        NSMutableString *httpUrl = [NSMutableString string];
        [httpUrl appendString: [mimcUserManager getUrl]];
        [httpUrl appendString: @"/api/uctopic/update"];
        NSDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:topicId forKey:@"topicId"];
        if(![newOwnerAccount isEqual: @""]){
            [parameters setValue:newOwnerAccount forKey:@"ownerAccount"];
        }
        if(![newGroupName isEqual: @""]){
            [parameters setValue:newGroupName forKey:@"topicName"];
        }
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
    
    // 无匹配
    else {
        result(FlutterMethodNotImplemented);
    }
}

// 无限大群基本查询
- (void)unlimitedGroupQueryInfo:(NSString *)topicId url:(NSString *)url result:(FlutterResult)result{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"" forKey:@"data"];
    [dic setValue:@NO forKey:@"success"];
    [dic setValue:@"" forKey:@"message"];
    if([topicId isEqual: @""]){
        [dic setValue:@"topicId不能为空!" forKey:@"message"];
        result(dic);
        return;
    }
    NSString *token = [mimcUserManager.getUser getToken];
    NSMutableString *httpUrl = [NSMutableString string];
    [httpUrl appendString: [mimcUserManager getUrl]];
    [httpUrl appendString: url];
    [httpManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    [httpManager.requestSerializer setValue:topicId forHTTPHeaderField:@"topicId"];
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
