//
//  MIMCLoggerWrapper.h
//  MMCDemo
//
//  Created by lijia8 on 2018/10/30.
//  Copyright © 2018 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _MIMCLogLevel {
    MIMC_ERROR,
    MIMC_WARN,
    MIMC_INFO,
    MIMC_DEBUG
} MIMCLogLevel;

@interface MIMCLoggerWrapper : NSObject

+ (MIMCLoggerWrapper *)sharedInstance;
- (void)setMIMCLogSwitch:(BOOL)logSwitch;
- (void)setMIMCLogLevel:(MIMCLogLevel)level;

- (void)info:(NSString *)msg, ...;
- (void)debug:(NSString *)msg, ...;
- (void)warn:(NSString *)msg, ...;
- (void)error:(NSString *)msg, ...;

@end

