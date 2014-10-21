//
//  mgMusicAudioQueueFiller.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//


#import "mgMusicAudioQueueFiller.h"
#import "mgMusicAudioQueueBuffer.h"
#import "mgMusicAudioQueue.h"

@implementation mgMusicAudioQueueFiller

+ (void)fillAudioQueue:(mgMusicAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length offset:(UInt32)offset
{
    mgMusicAudioQueueBuffer *audioQueueBuffer = [audioQueue nextFreeBuffer];

    NSInteger leftovers = [audioQueueBuffer fillWithData:data length:length offset:offset];

    if (leftovers == 0) return;

    [audioQueue enqueue];

    if (leftovers > 0)
        [self fillAudioQueue:audioQueue withData:data length:length offset:(length - (UInt32)leftovers)];
}

+ (void)fillAudioQueue:(mgMusicAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription
{
    mgMusicAudioQueueBuffer *audioQueueBuffer = [audioQueue nextFreeBuffer];

    BOOL hasMoreRoomForPackets = [audioQueueBuffer fillWithData:data length:length packetDescription:packetDescription];

    if (!hasMoreRoomForPackets) {
        [audioQueue enqueue];
        [self fillAudioQueue:audioQueue withData:data length:length packetDescription:packetDescription];
    }
}

@end
