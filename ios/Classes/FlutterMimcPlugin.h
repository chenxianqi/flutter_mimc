#import <Flutter/Flutter.h>
#import <MMCSDK/MCUser.h>
@interface FlutterMimcPlugin : NSObject<FlutterPlugin, onlineStatusDelegate, handleMessageDelegate, handleUnlimitedGroupDelegate>
- (void)statusChange:(MCUser *)user status:(int)status type:(NSString *)type reason:(NSString *)reason desc:(NSString *)desc;
- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user;
- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleServerAck:(MIMCServerAck *)serverAck;
- (void)handleSendMessageTimeout:(MIMCMessage *)message;
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleCreateUnlimitedGroup:(int64_t)topicId topicName:(NSString *)topicName code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleJoinUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleQuitUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleDismissUnlimitedGroup:(int64_t)topicId code:(int)code desc:(NSString *)desc context:(id)context;
- (void)handleDismissUnlimitedGroup:(int64_t)topicId;
@end
