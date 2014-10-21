//
//  mgAudioFileStream.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class mgMusicAudioFileStream;
@protocol mgMusicAudioFileStreamDelegate <NSObject>

- (void)audioFileStream:(mgMusicAudioFileStream *)audioFileStream didReceiveError:(OSStatus)error;

@required
- (void)audioFileStreamDidBecomeReady:(mgMusicAudioFileStream *)audioFileStream;
- (void)audioFileStream:(mgMusicAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;
- (void)audioFileStream:(mgMusicAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length;

@end

@interface mgMusicAudioFileStream : NSObject

@property (assign, nonatomic) AudioStreamBasicDescription basicDescription;
@property (assign, nonatomic) UInt64 totalByteCount;
@property (assign, nonatomic) UInt32 packetBufferSize;
@property (assign, nonatomic) void *magicCookieData;
@property (assign, nonatomic) UInt32 magicCookieLength;
@property (assign, nonatomic) BOOL discontinuous;
@property (assign, nonatomic) id<mgMusicAudioFileStreamDelegate> delegate;

- (instancetype)init;

- (void)parseData:(const void *)data length:(UInt32)length;

@end
