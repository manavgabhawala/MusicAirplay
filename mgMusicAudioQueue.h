//
//  mgAudioQueue.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSUInteger, mgMusicAudioQueueState) {
    mgMusicAudioQueueStateBuffering,
    mgMusicAudioQueueStateStopped,
    mgMusicAudioQueueStatePaused,
    mgMusicAudioQueueStatePlaying
};

@class mgMusicAudioQueue;

@protocol mgMusicAudioQueueDelegate <NSObject>

- (void)audioQueueDidFinishPlaying:(mgMusicAudioQueue *)audioQueue;
- (void)audioQueueDidStartPlaying:(mgMusicAudioQueue *)audioQueue;

@end

@class mgMusicAudioQueueBuffer;

@interface mgMusicAudioQueue : NSObject

@property (assign, nonatomic) mgMusicAudioQueueState state;
@property (assign, nonatomic) id<mgMusicAudioQueueDelegate> delegate;

- (instancetype)initWithBasicDescription:(AudioStreamBasicDescription)basicDescription bufferCount:(UInt32)bufferCount bufferSize:(UInt32)bufferSize magicCookieData:(void *)magicCookieData magicCookieSize:(UInt32)magicCookieSize;

- (mgMusicAudioQueueBuffer *)nextFreeBuffer;
- (void)enqueue;

- (void)play;
- (void)pause;
- (void)stop;
- (void)finish;

@end
