//
//  PlaylistViewController.h
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;
@import MultipeerConnectivity;
#import "MPCSession.h"

@interface PlaylistViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *songsData;

@property (strong, nonatomic) MPCSession *session;



@end
