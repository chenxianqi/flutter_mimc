//
//  MCOnlineMessageAck.h
//  MMCSDK
//
//  Created by lijia8 on 2019/12/19.
//  Copyright © 2019 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOnlineMessageAck : NSObject

- (id)initWithPacketId:(NSString *)packetId andCode:(int)code andDesc:(NSString *)desc;

- (NSString *)getPacketId;

- (int)getCode;

- (NSString *)getDesc;

@end

