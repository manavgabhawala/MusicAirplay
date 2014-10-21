//
//  mgMusicAudioOutputStreamer.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//
@import MediaPlayer;
#import <Foundation/Foundation.h>

@class AVURLAsset;
@interface mgMusicAudioOutputStreamer : NSObject


- (instancetype)initWithOutputStream:(NSOutputStream *)stream;

- (void)streamAudioFromURL:(NSURL *)url;
- (void)start;
- (void)stop;

@end
