//
//  mgMusicMultipeerGuestViewController.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

@import MediaPlayer;

#import "mgMusicGuestViewController.h"
#import "mgMusicSession.h"
#import "mgMusicAudioStreamer.h"

@interface mgMusicGuestViewController () <mgMusicSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;

@property (strong, nonatomic) mgMusicSession *session;
@property (strong, nonatomic) mgMusicAudioInputStreamer *inputStream;
@property (strong, nonatomic) NSTimer *musicTimer;
@end

@implementation mgMusicGuestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.session = [[mgMusicSession alloc] initWithPeerDisplayName:[[UIDevice currentDevice] name]];
    [self.session startAdvertisingForServiceType:@"airplaymusic" discoveryInfo:nil];
    self.session.delegate = self;
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.session = [[mgMusicSession alloc] initWithPeerDisplayName:[[UIDevice currentDevice] name]];
    [self.session startAdvertisingForServiceType:@"airplaymusic" discoveryInfo:nil];
    self.session.delegate = self;

}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopAdvertising];
}
- (void)changeSongInfo:(NSDictionary *)info
{
    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = nil;

    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];
    //double songLength = info[@"time"];
    /*self.musicTimer = [NSTimer scheduledTimerWithTimeInterval:songLength
                                                      target:self
                                                    selector:@selector(songEndedPlaying)
                                                    userInfo:nil
                                                     repeats:NO];*/
}

#pragma mark - mgMusicSessionDelegate

- (void)session:(mgMusicSession *)session didReceiveData:(NSData *)data
{
    NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self performSelectorOnMainThread:@selector(changeSongInfo:) withObject:info waitUntilDone:NO];
}

- (void)session:(mgMusicSession *)session didReceiveAudioStream:(NSInputStream *)stream
{
    if (!self.inputStream)
    {
        self.inputStream = [[mgMusicAudioInputStreamer alloc] initWithInputStream:stream];
        [self.inputStream start];
    }
}
@end
