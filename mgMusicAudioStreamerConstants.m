//
//  mgMusicAudioStreamerConstants.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import "mgMusicAudioStreamerConstants.h"

NSString *const mgMusicAudioStreamerDidChangeAudioNotification = @"mgMusicAudioStreamerDidChangeAudioNotification";
NSString *const mgMusicAudioStreamerDidPauseNotification = @"mgMusicAudioStreamerDidPauseNotification";
NSString *const mgMusicAudioStreamerDidPlayNotification = @"mgMusicAudioStreamerDidPlayNotification";
NSString *const mgMusicAudioStreamerDidStopNotification = @"mgMusicAudioStreamerDidStopNotification";

NSString *const mgMusicAudioStreamerNextTrackRequestNotification = @"mgMusicAudioStreamerNextTrackRequestNotification";
NSString *const mgMusicAudioStreamerPreviousTrackRequestNotification = @"mgMusicAudioStreamerPreviousTrackRequestNotification";

NSString *const mgMusicAudioStreamDidFinishPlayingNotification = @"mgMusicAudioStreamDidFinishPlayingNotification";
NSString *const mgMusicAudioStreamDidStartPlayingNotification = @"mgMusicAudioStreamDidStartPlayingNotification";

UInt32 const kmgMusicAudioStreamReadMaxLength = 512;
UInt32 const kmgMusicAudioQueueBufferSize = 2048;
UInt32 const kmgMusicAudioQueueBufferCount = 16;
UInt32 const kmgMusicAudioQueueStartMinimumBuffers = 2;
