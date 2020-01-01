#import "XMUserManager.h"
@interface XMUserManager () {
}
@property(nonatomic) int64_t appId;
@property(nonatomic) NSString *appKey;
@property(nonatomic) NSString *appSecret;
@property(nonatomic) NSString *appAccount;
@property(nonatomic) NSString *url;
@property(nonatomic) NSString *stringToken;
@property(nonatomic) BOOL isStringTokenInit;
@property(nonatomic, strong) MCUser *user;

@end


@implementation XMUserManager;
@synthesize appAccount = _appAccount;
@synthesize user = _user;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



// 构造函数
-(id)init{
    if (self = [super init]) {
         self.url = @"https://mimc.chat.xiaomi.net";
    }
    return self;
}

// 参数设置
- (void)initArgs:(int64_t)appId appKey:(NSString *)appKey appSecret:(NSString *)appSecret  appAccount:(NSString *)appAccount{
    if(appId == 0 || appKey == nil || appSecret == nil || appAccount == nil){
        NSLog(@"参数错误");
        return;
    }
    self.isStringTokenInit = NO;
    self.appId = appId;
    self.appKey = appKey;
    self.appSecret = appSecret;
    self.appAccount = appAccount;
}

// 通过服务端的鉴权获得的String 初始化
-(void)initStringToken:(NSString *)stringToken{
    self.stringToken = stringToken;
    self.isStringTokenInit = YES;
    NSDictionary *dic = [XMUserManager dictionaryWithJsonString:stringToken];
    self.appId = [[[dic valueForKey:@"data"] valueForKey:@"appId"] longLongValue];
    self.appAccount = [[dic valueForKey:@"data"] valueForKey:@"appAccount"];
}


// 用户登录
- (BOOL)userLogin {
    _user = [[MCUser alloc] initWithAppId:_appId andAppAccount:_appAccount];
    _user.parseTokenDelegate = self;
    return [_user login];
}

// 用户退出
- (BOOL)userLogout {
    return [_user logout];
}

// geturl
- (NSString *)getUrl{
    return _url;
}

// token
- (void)parseProxyServiceToken:(void(^)(NSString *data))callback {
    if(self.isStringTokenInit == YES){
        if (callback) {
            callback(self.stringToken);
        }
        return;
    }
}


- (void)onSendDataSuccess:(int64_t)callId dataId:(int)dataId context:(id)context {
    NSLog(@"onSendDataSuccess, callId=%lld, dataId=%d", callId, dataId);
}

- (void)onSendDataFailure:(int64_t)callId dataId:(int)dataId context:(id)context {
    NSLog(@"onSendDataFailure, callId=%lld, dataId=%d", callId, dataId);
}

// 获取当前账号
- (NSString *)getAppAccount {
    return self.appAccount;
}

// 设置当前账号
- (void)setAppAccount:(NSString *)appAccount {
    _appAccount = appAccount;
}

// 获取当前登录用户实例
- (MCUser *)getUser {
    return self.user;
}
// 设置当前用户
- (void)setUser:(MCUser *)user {
    _user = user;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
