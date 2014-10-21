//
//  mgMusicAudioOutputStreamer.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "mgMusicAudioOutputStreamer.h"
#import "mgMusicAudioStream.h"
#import "mgMusicAudioStreamerConstants.h"

@interface mgMusicAudioOutputStreamer () <mgMusicAudioStreamDelegate>

@property (strong, nonatomic) mgMusicAudioStream *audioStream;
@property (strong, nonatomic) AVAssetReader *assetReader;
@property (strong, nonatomic) AVAssetReaderTrackOutput *assetOutput;
@property (strong, nonatomic) NSThread *streamThread;

@property (assign, atomic) BOOL isStreaming;

@end

@implementation mgMusicAudioOutputStreamer

- (instancetype) initWithOutputStream:(NSOutputStream *)stream
{
    self = [super init];
    if (!self) return nil;

    self.audioStream = [[mgMusicAudioStream alloc] initWithOutputStream:stream];
    self.audioStream.delegate = self;
    NSLog(@"Init");

    return self;
}

- (void)start
{
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]])
    {
        return [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    }

    NSLog(@"Start");
    self.streamThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.streamThread start];
}

- (void)run
{
    @autoreleasepool {
        [self.audioStream open];

        self.isStreaming = YES;
        NSLog(@"Loop");

        while (self.isStreaming && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);

        NSLog(@"Done");
    }
}

- (void)streamAudioFromURL:(NSURL *)url
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSError *assetError;

    self.assetReader = [AVAssetReader assetReaderWithAsset:asset error:&assetError];
    self.assetOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:asset.tracks[0] outputSettings:nil];
    if (![self.assetReader canAddOutput:self.assetOutput]) return;

    [self.assetReader addOutput:self.assetOutput];
    [self.assetReader startReading];
    NSLog(@"Read Asset");
}

- (void)sendDataChunk
{
    CMSampleBufferRef sampleBuffer;

    sampleBuffer = [self.assetOutput copyNextSampleBuffer];

    if (sampleBuffer == NULL || CMSampleBufferGetNumSamples(sampleBuffer) == 0) {
        CFRelease(sampleBuffer);
        return;
    }

    CMBlockBufferRef blockBuffer;
    AudioBufferList audioBufferList;

    OSStatus err = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);

    if (err) {
        CFRelease(sampleBuffer);
        return;
    }

    for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++)
    {
        AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
        [self.audioStream writeData:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
        NSLog(@"buffer size: %u", (unsigned int)audioBuffer.mDataByteSize);
    }
    CFRelease(blockBuffer);
    CFRelease(sampleBuffer);
}

- (void)stop
{
    [self performSelector:@selector(stopThread) onThread:self.streamThread withObject:nil waitUntilDone:YES];
}

- (void)stopThread
{
    self.isStreaming = NO;
    [self.audioStream close];
    NSLog(@"Stop");
}

#pragma mark - mgMusicAudioStreamDelegate

- (void)audioStream:(mgMusicAudioStream *)audioStream didRaiseEvent:(mgMusicAudioStreamEvent)event
{
    switch (event)
    {
        case mgMusicAudioStreamEventWantsData:
            [self sendDataChunk];
            break;

        case mgMusicAudioStreamEventError:
              [[NSNotificationCenter defaultCenter] postNotificationName:mgMusicAudioStreamDidFinishPlayingNotification object:nil];
            NSLog(@"Stream Error");
            break;

        case mgMusicAudioStreamEventEnd:
              [[NSNotificationCenter defaultCenter] postNotificationName:mgMusicAudioStreamDidFinishPlayingNotification object:nil];
            [self.audioStream close];
            
            NSLog(@"Stream Ended");
            break;

        default:
            break;
    }
}

@end
