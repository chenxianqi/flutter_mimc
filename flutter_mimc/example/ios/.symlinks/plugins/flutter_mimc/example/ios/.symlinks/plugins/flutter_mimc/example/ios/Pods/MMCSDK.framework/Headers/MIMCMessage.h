//
//  MIMCMessage.h
//  MIMCSDK
//
//  Created by zhangdan on 2017/12/13.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIMCMessage : NSObject

- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andToAccount:(NSString *)toAccount andPayload:(NSData *)payload;
- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andToAccount:(NSString *)toAccount andPayload:(NSData *)payload andBizType:(NSString *)bizType;
- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andToAccount:(NSString *)toAccount andFromResource:(NSString *)fromResource andToResource:(NSString *)toResource andPayload:(NSData *)payload andBizType:(NSString *)bizType;
- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andToAccount:(NSString *)toAccount andFromResource:(NSString *)fromResource andToResource:(NSString *)toResource andPayload:(NSData *)payload andBizType:(NSString *)bizType andConvIndex:(int64_t)convIndex;
- (NSString *)getPacketId;
- (int64_t)getSequence;
- (int64_t)getTimestamp;
- (NSString *)getFromAccount;
- (NSString *)getToAccount;
- (NSString *)getFromResource;
- (NSString *)getToResource;
- (NSData *)getPayload;
- (NSString *)getBizType;
- (int64_t)getConvIndex;
@end
