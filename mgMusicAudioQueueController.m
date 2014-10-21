//
//  mgMusicAudioQueueController.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//


#import "mgMusicAudioQueueController.h"

@implementation mgMusicAudioQueueController

+ (OSStatus)playAudioQueue:(AudioQueueRef)audioQueue
{
    return AudioQueueStart(audioQueue, NULL);
}

+ (OSStatus)pauseAudioQueue:(AudioQueueRef)audioQueue
{
    return AudioQueuePause(audioQueue);
}

+ (OSStatus)stopAudioQueue:(AudioQueueRef)audioQueue
{
    return [self stopAudioQueue:audioQueue immediately:YES];
}

+ (OSStatus)finishAudioQueue:(AudioQueueRef)audioQueue
{
    return [self stopAudioQueue:audioQueue immediately:NO];
}

+ (OSStatus)stopAudioQueue:(AudioQueueRef)audioQueue immediately:(BOOL)immediately
{
    return AudioQueueStop(audioQueue, immediately);
}

@end
