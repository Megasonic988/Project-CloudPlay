//
//  MusicPlayer.h
//  TDAudioStreamer
//
//  Created by Kevin Wang on 2015-03-10.
//  Copyright (c) 2015 Tony DiPasquale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
@import AVFoundation;

@interface KWMusicPlayer : NSObject

@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
@property (assign , atomic) BOOL isPlaying;

- (instancetype)initWithSong:(NSDictionary *)song;
- (void)configNowPlayingInfoForSong:(NSDictionary *)song;

- (void)play;
- (void)pause;
- (void)stop;

@end
