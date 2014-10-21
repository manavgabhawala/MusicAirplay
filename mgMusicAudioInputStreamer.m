//
//  mgMusicAudioInputStreamer.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import "mgMusicAudioInputStreamer.h"
#import "mgMusicAudioFileStream.h"
#import "mgMusicAudioStream.h"
#import "mgMusicAudioQueue.h"
#import "mgMusicAudioQueueBuffer.h"
#import "mgMusicAudioQueueFiller.h"
#import "mgMusicAudioStreamerConstants.h"

@interface mgMusicAudioInputStreamer () <mgMusicAudioStreamDelegate, mgMusicAudioFileStreamDelegate, mgMusicAudioQueueDelegate>

@property (strong, nonatomic) NSThread *audioStreamerThread;
@property (assign, atomic) BOOL isPlaying;

@property (strong, nonatomic) mgMusicAudioStream *audioStream;
@property (strong, nonatomic) mgMusicAudioFileStream *audioFileStream;
@property (strong, nonatomic) mgMusicAudioQueue *audioQueue;

@end

@implementation mgMusicAudioInputStreamer

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    self.audioFileStream = [[mgMusicAudioFileStream alloc] init];
    if (!self.audioFileStream) return nil;

    self.audioFileStream.delegate = self;

    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream
{
    self = [self init];
    if (!self) return nil;

    self.audioStream = [[mgMusicAudioStream alloc] initWithInputStream:inputStream];
    if (!self.audioStream) return nil;

    self.audioStream.delegate = self;

    return self;
}

- (void)start
{
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        return [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    }

    self.audioStreamerThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.audioStreamerThread start];
}

- (void)run
{
    @autoreleasepool {
        [self.audioStream open];

        self.isPlaying = YES;

        while (self.isPlaying && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) ;
    }
}

#pragma mark - Properties

- (UInt32)audioStreamReadMaxLength
{
    if (!_audioStreamReadMaxLength)
        _audioStreamReadMaxLength = kmgMusicAudioStreamReadMaxLength;

    return _audioStreamReadMaxLength;
}

- (UInt32)audioQueueBufferSize
{
    if (!_audioQueueBufferSize)
        _audioQueueBufferSize = kmgMusicAudioQueueBufferSize;

    return _audioQueueBufferSize;
}

- (UInt32)audioQueueBufferCount
{
    if (!_audioQueueBufferCount)
        _audioQueueBufferCount = kmgMusicAudioQueueBufferCount;

    return _audioQueueBufferCount;
}

#pragma mark - mgMusicAudioStreamDelegate

- (void)audioStream:(mgMusicAudioStream *)audioStream didRaiseEvent:(mgMusicAudioStreamEvent)event
{
    switch (event) {
        case mgMusicAudioStreamEventHasData: {
            uint8_t bytes[self.audioStreamReadMaxLength];
            UInt32 length = [audioStream readData:bytes maxLength:self.audioStreamReadMaxLength];
            [self.audioFileStream parseData:bytes length:length];
            break;
        }

        case mgMusicAudioStreamEventEnd:
            NSLog(@"StreamEventEnd AudioStream");
            self.isPlaying = NO;
            [self.audioQueue finish];
            break;

        case mgMusicAudioStreamEventError:
            [[NSNotificationCenter defaultCenter] postNotificationName:mgMusicAudioStreamDidFinishPlayingNotification object:nil];
            break;

        default:
            break;
    }
}

#pragma mark - mgMusicAudioFileStreamDelegate

- (void)audioFileStreamDidBecomeReady:(mgMusicAudioFileStream *)audioFileStream
{
    UInt32 bufferSize = audioFileStream.packetBufferSize ? audioFileStream.packetBufferSize : self.audioQueueBufferSize;

    self.audioQueue = [[mgMusicAudioQueue alloc] initWithBasicDescription:audioFileStream.basicDescription bufferCount:self.audioQueueBufferCount bufferSize:bufferSize magicCookieData:audioFileStream.magicCookieData magicCookieSize:audioFileStream.magicCookieLength];

    self.audioQueue.delegate = self;
}

- (void)audioFileStream:(mgMusicAudioFileStream *)audioFileStream didReceiveError:(OSStatus)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:mgMusicAudioStreamDidFinishPlayingNotification object:nil];
}

- (void)audioFileStream:(mgMusicAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length
{
    [mgMusicAudioQueueFiller fillAudioQueue:self.audioQueue withData:data length:length offset:0];
}

- (void)audioFileStream:(mgMusicAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription
{
    [mgMusicAudioQueueFiller fillAudioQueue:self.audioQueue withData:data length:length packetDescription:packetDescription];
}

#pragma mark - mgMusicAudioQueueDelegate

- (void)audioQueueDidFinishPlaying:(mgMusicAudioQueue *)audioQueue
{
    NSLog(@"Input Streamer: mgMusicAudioQueueDelegate, queue did finish playing");
    [[NSNotificationCenter defaultCenter] postNotificationName:mgMusicAudioStreamDidFinishPlayingNotification object:nil];
    [self performSelectorOnMainThread:@selector(notifyMainThread:) withObject:mgMusicAudioStreamDidFinishPlayingNotification waitUntilDone:NO];
}

- (void)audioQueueDidStartPlaying:(mgMusicAudioQueue *)audioQueue
{
    [self performSelectorOnMainThread:@selector(notifyMainThread:) withObject:mgMusicAudioStreamDidStartPlayingNotification waitUntilDone:NO];
}

- (void)notifyMainThread:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

#pragma mark - Public Methods

- (void)resume
{
    [self.audioQueue play];
}

- (void)pause
{
    [self.audioQueue pause];
}

- (void)stop
{
    [self performSelector:@selector(stopThread) onThread:self.audioStreamerThread withObject:nil waitUntilDone:YES];
}

- (void)stopThread
{
    self.isPlaying = NO;
    [self.audioQueue stop];
}

@end
