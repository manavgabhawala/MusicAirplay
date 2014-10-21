//
//  mgMusicSession.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>

@class mgMusicSession, MCPeerID, MCBrowserViewController;
@protocol mgMusicSessionDelegate <NSObject>

- (void)session:(mgMusicSession *)session didReceiveAudioStream:(NSInputStream *)stream;
- (void)session:(mgMusicSession *)session didReceiveData:(NSData *)data;

@end

@interface mgMusicSession : NSObject

@property (weak, nonatomic) id<mgMusicSessionDelegate> delegate;

- (instancetype)initWithPeerDisplayName:(NSString *)name;

- (void)startAdvertisingForServiceType:(NSString *)type discoveryInfo:(NSDictionary *)info;
- (void)stopAdvertising;
- (MCBrowserViewController *)browserViewControllerForSeriviceType:(NSString *)type;

- (NSArray *)connectedPeers;
- (NSOutputStream *)outputStreamForPeer:(MCPeerID *)peer;

- (void)sendData:(NSData *)data;

@end
