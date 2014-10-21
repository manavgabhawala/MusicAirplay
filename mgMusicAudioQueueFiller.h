//
//  mgMusicAudioQueueFiller.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class mgMusicAudioQueue;

@interface mgMusicAudioQueueFiller : NSObject

+ (void)fillAudioQueue:(mgMusicAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length offset:(UInt32)offset;
+ (void)fillAudioQueue:(mgMusicAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;

@end
