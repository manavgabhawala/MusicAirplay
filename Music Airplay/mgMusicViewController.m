//
//  mgMusicViewController.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

@import MediaPlayer;
@import MultipeerConnectivity;
@import AVFoundation;

#import "mgMusicViewController.h"
#import "mgMusicAudioStreamer.h"
#import "mgMusicSession.h"
#import "mgMusicAudioStreamerConstants.h"

@interface mgMusicViewController () <MPMediaPickerControllerDelegate>
@property (strong, nonatomic) NSTimer *musicTime;
@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;
@property (strong, nonatomic) MPMediaItemCollection *nextSongs;
@property (strong, nonatomic) MPMediaItem *song;
@property (strong, nonatomic) mgMusicAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) mgMusicSession *session;
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic) int songCount;
@property (nonatomic, getter = isTimerOn) BOOL timerOn;

@end

@implementation mgMusicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.session = [[mgMusicSession alloc] initWithPeerDisplayName:[[UIDevice currentDevice]name]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localNotificationRecieved:) name:nil object:nil];
}
- (void) viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NotificationCenter Handler
- (void) localNotificationRecieved:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:mgMusicAudioStreamDidFinishPlayingNotification])
    {
        NSLog(@"Notification: %@", [notification name]);
        //[self songEndedPlaying];
    }
    if ([[notification name] isEqualToString:mgMusicAudioStreamerDidPauseNotification])
    {
        if (self.musicTime)
        {
                NSLog(@"Pause Notification");
        }
    }
    if ([[notification name] isEqualToString:mgMusicAudioStreamerDidPlayNotification])
    {
        NSLog(@"Play Notification");
    }
}
#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *items;
    if (self.outputStreamer)
    {
        if (self.nextSongs.items)
        {
            items = [NSMutableArray arrayWithArray: self.nextSongs.items];
        }
        if (!items[0])
        {
            items = [NSMutableArray arrayWithArray:mediaItemCollection.items];
        }
        else
        {
            [items addObject:mediaItemCollection.items];
        }
        if (items)
        {
            self.nextSongs = [MPMediaItemCollection collectionWithItems:items];
        }
        [self songEndedPlaying];
        return;
    }
    else
    {
        if (mediaItemCollection.items.count > 1)
        {
            items = [NSMutableArray arrayWithArray: mediaItemCollection.items];
            self.nextSongs = [[MPMediaItemCollection alloc] initWithItems:items];
            [self clearNextSong];
            for (MPMediaItem * aSong in items)
            {
                NSLog(@"Song: %@ \nArtist: %@", [aSong valueForProperty:MPMediaItemPropertyTitle], [aSong valueForProperty:MPMediaItemPropertyArtist]);
            }
            self.songCount = 0;
        }
    }
    self.song = mediaItemCollection.items[0];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"title"] = [self.song valueForProperty:MPMediaItemPropertyTitle];
    info[@"artist"] = [self.song valueForProperty:MPMediaItemPropertyArtist];
    info[@"time"] = [self.song valueForProperty:MPMediaItemPropertyPlaybackDuration];
    double tempTime = [[self.song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue] + 1.25;
    NSLog(@"Length of song is: %@", [self.song valueForProperty:MPMediaItemPropertyPlaybackDuration]);
    self.timerOn = NO;
    [self timerStateChange];
    self.musicTime = [NSTimer scheduledTimerWithTimeInterval:tempTime
                                                      target:self
                                                    selector:@selector(timerStateChange)
                                                    userInfo:nil
                                                     repeats:NO];
    MPMediaItemArtwork *artwork = [self.song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:self.albumImage.frame.size];
    if (image)
        info[@"artwork"] = image;
    
    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = nil;
    
    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];
    
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[info copy]]];
    
    NSArray *peers = [self.session connectedPeers];
    
    if (peers.count) {
        self.outputStreamer = [[mgMusicAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:peers[0]]];
        [self.outputStreamer streamAudioFromURL:[self.song valueForProperty:MPMediaItemPropertyAssetURL]];
        [self.outputStreamer start];
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) clearNextSong
{
    NSMutableArray* upcomingSongs = [NSMutableArray arrayWithArray:self.nextSongs.items];
    [upcomingSongs removeObjectAtIndex:0];
    if (upcomingSongs[0])
    {
        self.nextSongs  = [MPMediaItemCollection collectionWithItems:upcomingSongs];
    }
}
- (void) timerStateChange
{
    self.timerOn = !self.isTimerOn;
    [self songEndedPlaying];
}
-(void)songEndedPlaying
{
    
    if (!self.isTimerOn)
    {
        NSLog(@"The timer has ended");
        
        //self.songCount++;
        /*for (MPMediaItem* aSong in self.nextSongs.items)
         {
         NSLog(@"Song: %@ \nArtist: %@", [aSong valueForProperty:MPMediaItemPropertyTitle], [aSong valueForProperty:MPMediaItemPropertyArtist]);
         }*/
        if (self.nextSongs.items[self.songCount])
        {
            self.song = self.nextSongs.items[self.songCount];
        }
        else
        {
            NSLog(@"There are no more songs in nextSongs");
            //set everything to the inital state.
            return;
        }
        //[self clearNextSong];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"title"] = [self.song valueForProperty:MPMediaItemPropertyTitle];
        info[@"artist"] = [self.song valueForProperty:MPMediaItemPropertyArtist];
        
        NSLog(@"Song: %@ \nArtist: %@", [self.song valueForProperty:MPMediaItemPropertyTitle], [self.song valueForProperty:MPMediaItemPropertyArtist]);
        /*if (self.musicTime)
         {
         [self.musicTime invalidate];
         }*/
        NSLog(@"Length of song is: %@", [self.song valueForProperty:MPMediaItemPropertyPlaybackDuration]);
        [self timerStateChange];
        double tempTime = [[self.song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        self.musicTime = [NSTimer scheduledTimerWithTimeInterval:tempTime
                                                          target:self
                                                        selector:@selector(songEndedPlaying)
                                                        userInfo:nil
                                                         repeats:NO];
        NSLog(@"Timer Restarted");
        MPMediaItemArtwork *artwork = [self.song valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *image = [artwork imageWithSize:self.albumImage.frame.size];
        if (image)
            info[@"artwork"] = image;
        
        if (info[@"artwork"])
            self.albumImage.image = info[@"artwork"];
        else
            self.albumImage.image = nil;
        
        self.songTitle.text = info[@"title"];
        self.songArtist.text = info[@"artist"];
        
        [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[info copy]]];
        
        NSArray *peers = [self.session connectedPeers];
        
        if (peers.count)
        {
            NSLog(@"Peers are still connected");
            [self.outputStreamer streamAudioFromURL:[self.song valueForProperty:MPMediaItemPropertyAssetURL]];
            [self.outputStreamer start];
        }
    }
}
#pragma mark - View Actions

- (IBAction)invite:(id)sender
{
    //[self.session startAdvertisingForServiceType:@"airplaymusic" discoveryInfo:nil];
    [self presentViewController:[self.session browserViewControllerForSeriviceType:@"airplaymusic"] animated:YES completion:nil];
}

- (IBAction)addSongs:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems	= YES;
	picker.prompt = NSLocalizedString (@"AddSongsPrompt", @"Prompt to user to choose some songs to play");
    [self presentViewController:picker animated:YES completion:nil];
}

@end
