//
//  MIMCServerAck.h
//  MMCSDK
//
//  Created by lijia8 on 2018/12/29.
//  Copyright © 2018 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIMCServerAck : NSObject

- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andDesc:(NSString *)desc;
- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andCode:(int)code andDesc:(NSString *)desc;
- (NSString *)getPacketId;
- (int64_t)getSequence;
- (int64_t)getTimestamp;
- (NSString *)getDesc;
- (int)getCode;

@end
