//
//  MIMCRtsChannelType.h
//  MMCSDK
//
//  Created by zhangdan on 2018/10/6.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _RtsChannelTypes {
    RELAY,
    P2P_INTERNET,
    P2P_INTRANET
} RtsChannelType;

@interface MIMCRtsChannelType : NSObject

@end
