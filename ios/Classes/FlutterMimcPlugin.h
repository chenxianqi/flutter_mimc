#import <Flutter/Flutter.h>
#import <MMCSDK/MCUser.h>
#import <AFNetworking/AFNetworking.h>
@interface FlutterMimcPlugin : NSObject<FlutterPlugin, onlineStatusDelegate, handleMessageDelegate, handleUnlimitedGroupDelegate>
- (void)statusChange:(MCUser *)user status:(int)status type:(NSString *)type reason:(NSString *)reason desc:(NSString *)desc;
- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user;
- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleServerAck:(MIMCServerAck *)serverAck;
- (void)handleSendMessageTimeout:(MIMCMessage *)message;
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleCreateUnlimitedGroup:(int64_t)topicId topicName:(NSString *)topicName success:(Boolean)success desc:(NSString *)desc context:(id)context;
-(void)unlimitedGroupQueryInfo:(NSString *)topicId url:(NSString *)url result:(FlutterResult)result;
@end
