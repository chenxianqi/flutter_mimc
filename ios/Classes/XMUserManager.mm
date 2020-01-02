#import "XMUserManager.h"
@interface XMUserManager () {
}
@property(nonatomic) int64_t appId;
@property(nonatomic) NSString *appAccount;
@property(nonatomic) NSString *stringToken;
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
    }
    return self;
}

// 通过服务端的鉴权获得的String 初始化
-(void)initStringToken:(NSString *)stringToken{
    _stringToken = stringToken;
    NSDictionary *dic = [XMUserManager dictionaryWithJsonString:stringToken];
    _appId = [[[dic valueForKey:@"data"] valueForKey:@"appId"] longLongValue];
    _appAccount = [[dic valueForKey:@"data"] valueForKey:@"appAccount"];
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

// token
- (void)parseProxyServiceToken:(void(^)(NSString *data))callback {
    NSDictionary *dic = [XMUserManager dictionaryWithJsonString:_stringToken];
    NSMutableDictionary *tokenDic = [dic objectForKey:@"data"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tokenDic options:0 error:0];
    NSString *jsonTokenString = [[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding];
    if (callback) {
        callback(jsonTokenString);
    }
    return;
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

// 获取appid
- (NSString *) getAppId{
    return [[NSNumber numberWithLongLong:self.appId] stringValue];
}

// 设置当前账号
- (void)setAppAccount:(NSString *)appAccount {
    _appAccount = appAccount;
}

// 获取当前登录用户实例
- (MCUser *)getUser {
    return _user;
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
