//
//  MIMCStreamConfig.h
//  MMCSDK
//
//  Created by lijia8 on 2018/11/12.
//  Copyright © 2018 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int const STRATEGY_FEC;
extern int const STRATEGY_ACK;

@interface MIMCStreamConfig : NSObject

- (id)initWithStrategy:(int)strategy andAckWaitTimeMs:(int)ackWaitTimeMs andIsEncrypt:(BOOL)isEncrypt;
- (int)getStrategy;
- (int)getAckWaitTimeMs;
- (BOOL)getIsEncrypt;

@end
