//
//  mgMusicAudioQueueController.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface mgMusicAudioQueueController : NSObject

+ (OSStatus)playAudioQueue:(AudioQueueRef)audioQueue;
+ (OSStatus)pauseAudioQueue:(AudioQueueRef)audioQueue;
+ (OSStatus)stopAudioQueue:(AudioQueueRef)audioQueue;
+ (OSStatus)finishAudioQueue:(AudioQueueRef)audioQueue;

@end
