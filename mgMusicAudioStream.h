//
//  mgMusicAudioStream.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, mgMusicAudioStreamEvent) {
    mgMusicAudioStreamEventHasData,
    mgMusicAudioStreamEventWantsData,
    mgMusicAudioStreamEventEnd,
    mgMusicAudioStreamEventError
};

@class mgMusicAudioStream;

@protocol mgMusicAudioStreamDelegate <NSObject>

@required
- (void)audioStream:(mgMusicAudioStream *)audioStream didRaiseEvent:(mgMusicAudioStreamEvent)event;

@end

@interface mgMusicAudioStream : NSObject

@property (assign, nonatomic) id<mgMusicAudioStreamDelegate> delegate;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream;
- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream;
- (void)open;
- (void)close;
- (UInt32)readData:(uint8_t *)data maxLength:(UInt32)maxLength;
- (UInt32)writeData:(uint8_t *)data maxLength:(UInt32)maxLength;

@end
