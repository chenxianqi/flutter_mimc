#import "XMUserManager.h"

@interface XMUserManager () {
}
@property(nonatomic) int64_t appId;
@property(nonatomic) NSString *appKey;
@property(nonatomic) NSString *appSecret;
@property(nonatomic) NSString *appAccount;
@property(nonatomic) NSString *url;
@property(nonatomic, strong) MCUser *user;

- (NSMutableURLRequest *)generateHttpRequest:(NSURL *)url appId:(int64_t)appId
                                      appKey:(NSString *)appKey appSecret:(NSString *)appSecret
                                  appAccount:(NSString *)appAccount;
@end


@implementation XMUserManager;
@synthesize appAccount = _appAccount;
@synthesize user = _user;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 参数设置
- (void)initArgs:(int64_t)appId appKey:(NSString *)appKey appSecret:(NSString *)appSecret  appAccount:(NSString *)appAccount{
    if(appId == 0 || appKey == nil || appSecret == nil || appAccount == nil){
        NSLog(@"参数错误");
        return;
    }
    self.appId = appId;
    self.appKey = appKey;
    self.appSecret = appSecret;
    self.appAccount = appAccount;
    self.url = @"https://mimc.chat.xiaomi.net/api/account/token";
}

// 发起请求获取签名认证
- (NSMutableURLRequest *)generateHttpRequest:(NSURL *)url appId:(int64_t)appId appKey:(NSString *)appKey
                                   appSecret:(NSString *)appSecret appAccount:(NSString *)appAccount {
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

// 获取token
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

@end