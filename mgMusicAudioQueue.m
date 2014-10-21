//
//  mgAudioQueue.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import "mgMusicAudioQueue.h"
#import "mgMusicAudioQueueBuffer.h"
#import "mgMusicAudioQueueController.h"
#import "mgMusicAudioQueueBufferManager.h"
#import "mgMusicAudioStreamerConstants.h"

@interface mgMusicAudioQueue ()

@property (assign, nonatomic) AudioQueueRef audioQueue;
@property (strong, nonatomic) mgMusicAudioQueueBufferManager *bufferManager;
@property (strong, nonatomic) NSCondition *waitForFreeBufferCondition;
@property (assign, nonatomic) NSUInteger buffersToFillBeforeStart;

- (void)didFreeAudioQueueBuffer:(AudioQueueBufferRef)audioQueueBuffer;

@end

void mgMusicAudioQueueOutputCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inAudioQueueBuffer)
{
    mgMusicAudioQueue *audioQueue = (__bridge mgMusicAudioQueue *)inUserData;
    [audioQueue didFreeAudioQueueBuffer:inAudioQueueBuffer];
}

@implementation mgMusicAudioQueue

- (instancetype)initWithBasicDescription:(AudioStreamBasicDescription)basicDescription bufferCount:(UInt32)bufferCount bufferSize:(UInt32)bufferSize magicCookieData:(void *)magicCookieData magicCookieSize:(UInt32)magicCookieSize
{
    self = [self init];
    if (!self) return nil;

    OSStatus err = AudioQueueNewOutput(&basicDescription, mgMusicAudioQueueOutputCallback, (__bridge void *)self, NULL, NULL, 0, &_audioQueue);

    if (err) return nil;

    self.bufferManager = [[mgMusicAudioQueueBufferManager alloc] initWithAudioQueue:self.audioQueue size:bufferSize count:bufferCount];

    AudioQueueSetProperty(self.audioQueue, kAudioQueueProperty_MagicCookie, magicCookieData, magicCookieSize);
    free(magicCookieData);

    AudioQueueSetParameter(self.audioQueue, kAudioQueueParam_Volume, 1.0);

    self.waitForFreeBufferCondition = [[NSCondition alloc] init];
    self.state = mgMusicAudioQueueStateBuffering;
    self.buffersToFillBeforeStart = kmgMusicAudioQueueStartMinimumBuffers;

    return self;
}

#pragma mark - Audio Queue Events

- (void)didFreeAudioQueueBuffer:(AudioQueueBufferRef)audioQueueBuffer
{
    [self.bufferManager freeAudioQueueBuffer:audioQueueBuffer];

    [self.waitForFreeBufferCondition lock];
    [self.waitForFreeBufferCondition signal];
    [self.waitForFreeBufferCondition unlock];

    if (self.state == mgMusicAudioQueueStateStopped && ![self.bufferManager isProcessingAudioQueueBuffer]) {
        [self.delegate audioQueueDidFinishPlaying:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:mgMusicAudioStreamDidFinishPlayingNotification object:nil];
    }
}

#pragma mark - Public Methods

- (mgMusicAudioQueueBuffer *)nextFreeBuffer
{
    if (![self.bufferManager hasAvailableAudioQueueBuffer]) {
        [self.waitForFreeBufferCondition lock];
        [self.waitForFreeBufferCondition wait];
        [self.waitForFreeBufferCondition unlock];
    }

    mgMusicAudioQueueBuffer *nextBuffer = [self.bufferManager nextFreeBuffer];

    if (!nextBuffer) return [self nextFreeBuffer];
    return nextBuffer;
}

- (void)enqueue
{
    [self.bufferManager enqueueNextBufferOnAudioQueue:self.audioQueue];

    if (self.state == mgMusicAudioQueueStateBuffering && --self.buffersToFillBeforeStart == 0) {
        AudioQueuePrime(self.audioQueue, 0, NULL);
        [self play];
        [self.delegate audioQueueDidStartPlaying:self];
    }
}

#pragma mark - Audio Queue Controls

- (void)play
{
    if (self.state == mgMusicAudioQueueStatePlaying) return;

    [mgMusicAudioQueueController playAudioQueue:self.audioQueue];
    self.state = mgMusicAudioQueueStatePlaying;
}

- (void)pause
{
    if (self.state == mgMusicAudioQueueStatePaused) return;

    [mgMusicAudioQueueController pauseAudioQueue:self.audioQueue];
    self.state = mgMusicAudioQueueStatePaused;
}

- (void)stop
{
    if (self.state == mgMusicAudioQueueStateStopped) return;
    NSLog(@"Stop in AudioQueue Called");
    [mgMusicAudioQueueController stopAudioQueue:self.audioQueue];
    self.state = mgMusicAudioQueueStateStopped;
}

- (void)finish
{
    if (self.state == mgMusicAudioQueueStateStopped) return;
    NSLog(@"Finish in AudioQueue Called");
    //[mgMusicAudioQueueController finishAudioQueue:self.audioQueue];
    self.state = mgMusicAudioQueueStateStopped;
}

#pragma mark - Cleanup

- (void)dealloc
{
    [self.bufferManager freeBufferMemoryFromAudioQueue:self.audioQueue];
    AudioQueueDispose(self.audioQueue, YES);
}

@end
