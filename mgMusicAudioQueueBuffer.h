//
//  mgMusicAudioQueueBuffer.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface mgMusicAudioQueueBuffer : NSObject

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue size:(UInt32)size;

- (NSInteger)fillWithData:(const void *)data length:(UInt32)length offset:(UInt32)offset;
- (BOOL)fillWithData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;

- (void)enqueueWithAudioQueue:(AudioQueueRef)auidoQueue;
- (void)reset;

- (BOOL)isEqual:(AudioQueueBufferRef)audioQueueBuffer;

- (void)freeFromAudioQueue:(AudioQueueRef)audioQueue;

@end
