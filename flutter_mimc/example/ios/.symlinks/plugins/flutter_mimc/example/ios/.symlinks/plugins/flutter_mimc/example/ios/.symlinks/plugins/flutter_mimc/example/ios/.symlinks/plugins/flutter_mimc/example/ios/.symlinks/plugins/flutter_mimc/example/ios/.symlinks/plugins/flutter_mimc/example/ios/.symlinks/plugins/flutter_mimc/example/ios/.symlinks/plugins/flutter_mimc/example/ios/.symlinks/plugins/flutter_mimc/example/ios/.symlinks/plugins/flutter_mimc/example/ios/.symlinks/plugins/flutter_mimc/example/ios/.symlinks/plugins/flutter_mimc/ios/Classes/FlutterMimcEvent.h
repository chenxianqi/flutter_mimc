//
//  FlutterMimcEvent.h
//  Pods
//
//  Created by chenxianqi on 2019/8/9.
//

#import <Flutter/Flutter.h>


@interface FlutterMimcEvent : NSObject<FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;
@property (nonatomic, strong) FlutterEventChannel* eventChannel;
@end

