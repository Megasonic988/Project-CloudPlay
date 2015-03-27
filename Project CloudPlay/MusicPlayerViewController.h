//
//  MusicPlayerViewController.h
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistViewController.h"

@interface MusicPlayerViewController : UIViewController

@property (strong, nonatomic) KWMusicPlayer *musicPlayer;
@property (strong, nonatomic) PlaylistViewController *playlistVC;

@property (strong, nonatomic) NSDictionary *currentSong;
@property (assign, nonatomic) BOOL isLeader;

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

@end
