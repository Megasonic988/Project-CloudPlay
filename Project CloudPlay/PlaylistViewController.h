//
//  PlaylistViewController.h
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
@import MultipeerConnectivity;
#import "MPCSession.h"
#import "KWMusicPlayer.h"

@protocol PlaylistViewControllerDelegate <NSObject>

- (void)startSongPlayback;
- (void)pauseSongPlayback;
- (void)popDelegateViewController;

@end

@interface PlaylistViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) id <PlaylistViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *songsData; //of NSDicts
@property (strong, nonatomic) NSArray *mySongs; //actual MPMediaItem songs

@property (strong, nonatomic) MPCSession *session;



@end
