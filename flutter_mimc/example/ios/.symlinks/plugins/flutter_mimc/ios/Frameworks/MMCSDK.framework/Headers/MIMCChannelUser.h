//
//  MIMCChannelUser.h
//  MMCSDK
//
//  Created by lijia8 on 2019/3/4.
//  Copyright © 2019 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIMCChannelUser : NSObject

- (id)initWithAppAccount:(NSString *)appAccount resource:(NSString *)resource;

- (NSString *)getAppAccount;

- (NSString *)getResource;

@end
