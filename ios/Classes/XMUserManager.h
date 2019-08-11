#import <Foundation/Foundation.h>
#import <MMCSDK/MCUser.h>

@interface XMUserManager : NSObject<parseTokenDelegate>

- (void)initArgs:(int64_t)appId appKey:(NSString *)appKey appSecret:(NSString *)appSecret appAccount:(NSString *)appAccount;
- (BOOL)userLogin;
- (BOOL)userLogout;
- (NSString *)getAppAccount;
- (void)setAppAccount:(NSString *)appAccount;
- (MCUser *)getUser;
- (NSString *)getUrl;
- (void)setUser:(MCUser *)user;
- (void)parseProxyServiceToken:(void(^)(NSString *data))callback;
@end
