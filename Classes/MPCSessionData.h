//
//  MPCSessionData.h
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-24.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@import MediaPlayer;
@import AVFoundation;

@interface MPCSessionData : NSObject

@property (strong, nonatomic) NSMutableArray *mySongs; //of MPMediaItems
@property (strong, nonatomic) NSMutableArray *songsData; //of NSDictionaries with song data
@property (strong, nonatomic) NSMutableArray *justSelectedSongsData; //of NSDictionaries with just selected song data (to be sent)
@property (strong, nonatomic) NSDictionary *currentPlayingSong;
@property (strong, nonatomic) MPMediaItem *songToStream;


- (void)storeSongDataFromSongs:(NSArray *)songs withMyPeerID:(MCPeerID *)peerID;

@end
