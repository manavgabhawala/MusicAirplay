//
//  mgMusicAudioQueueBufferManager.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import "mgMusicAudioQueueBufferManager.h"
#import "mgMusicAudioQueueBuffer.h"
#import "NSMutableArray+QueueMethods.h"

@interface mgMusicAudioQueueBufferManager ()

@property (assign, nonatomic) UInt32 bufferCount;
@property (assign, nonatomic) UInt32 bufferSize;
@property (strong, nonatomic) NSArray *audioQueueBuffers;
@property (strong, atomic) NSMutableArray *freeBuffers;

@end

@implementation mgMusicAudioQueueBufferManager

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue size:(UInt32)size count:(UInt32)count
{
    self = [super init];
    if (!self) return nil;

    self.bufferCount = count;
    self.bufferSize = size;

    self.freeBuffers = [NSMutableArray arrayWithCapacity:self.bufferCount];
    NSMutableArray *audioqueuebuffers = [NSMutableArray arrayWithCapacity:self.bufferCount];

    for (NSUInteger i = 0; i < self.bufferCount; i++)
    {
        mgMusicAudioQueueBuffer *buffer = [[mgMusicAudioQueueBuffer alloc] initWithAudioQueue:audioQueue size:self.bufferSize];

        if (!buffer) {
            i--;
            continue;
        }

        audioqueuebuffers[i] = buffer;
        [self.freeBuffers pushObject:@(i)];
    }

    self.audioQueueBuffers = [audioqueuebuffers copy];

    return self;
}

#pragma mark - Public Methods

- (void)freeAudioQueueBuffer:(AudioQueueBufferRef)audioQueueBuffer
{
    for (NSUInteger i = 0; i < self.bufferCount; i++) {
        if ([(mgMusicAudioQueueBuffer *)self.audioQueueBuffers[i] isEqual:audioQueueBuffer]) {
            [(mgMusicAudioQueueBuffer *)self.audioQueueBuffers[i] reset];

            @synchronized(self) {
                [self.freeBuffers pushObject:@(i)];
            }
            break;
        }
    }

#if DEBUG
    if (self.freeBuffers.count > self.bufferCount >> 1) {
        //NSLog(@"Free Buffers: %lu", (unsigned long)self.freeBuffers.count);
    }
#endif
}

- (mgMusicAudioQueueBuffer *)nextFreeBuffer
{
    if (![self hasAvailableAudioQueueBuffer]) return nil;
    @synchronized(self) {
        return self.audioQueueBuffers[[[self.freeBuffers topObject] integerValue]];
    }
}

- (void)enqueueNextBufferOnAudioQueue:(AudioQueueRef)audioQueue
{
    @synchronized(self) {
        NSInteger nextBufferIndex = [[self.freeBuffers popObject] integerValue];
        mgMusicAudioQueueBuffer *nextBuffer = self.audioQueueBuffers[nextBufferIndex];
        [nextBuffer enqueueWithAudioQueue:audioQueue];
    }
}

- (BOOL)hasAvailableAudioQueueBuffer
{
    @synchronized(self) {
        return self.freeBuffers.count > 0;
    }
}

- (BOOL)isProcessingAudioQueueBuffer
{
    @synchronized(self) {
        return self.freeBuffers.count != self.bufferCount;
    }
}

#pragma mark - Cleanup

- (void)freeBufferMemoryFromAudioQueue:(AudioQueueRef)audioQueue
{
    for (NSUInteger i = 0; i < self.audioQueueBuffers.count; i++) {
        [(mgMusicAudioQueueBuffer *)self.audioQueueBuffers[i] freeFromAudioQueue:audioQueue];
    }
}

@end
