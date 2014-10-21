//
//  mgMusicAudioQueueBufferManager.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class mgMusicAudioQueueBuffer;

@interface mgMusicAudioQueueBufferManager : NSObject

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue size:(UInt32)size count:(UInt32)count;

- (void)freeAudioQueueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
- (mgMusicAudioQueueBuffer *)nextFreeBuffer;
- (void)enqueueNextBufferOnAudioQueue:(AudioQueueRef)audioQueue;

- (BOOL)hasAvailableAudioQueueBuffer;
- (BOOL)isProcessingAudioQueueBuffer;

- (void)freeBufferMemoryFromAudioQueue:(AudioQueueRef)audioQueue;

@end
