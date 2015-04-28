//
//  MusicPlayer.m
//  TDAudioStreamer
//
//  Created by Kevin Wang on 2015-03-10.
//  Copyright (c) 2015 Tony DiPasquale. All rights reserved.
//

#import "KWMusicPlayer.h"

@interface KWMusicPlayer ()

@property (strong, nonatomic) NSArray *songQueryItems;

@end

@implementation KWMusicPlayer

- (instancetype)initWithSong:(NSDictionary *)song
{
    self = [super init];
    if (self) {
        NSError *error;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[song objectForKey:@"MediaItemURL"] error:&error];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        self.musicPlayer = audioPlayer;
        [self.musicPlayer prepareToPlay];
        [self configNowPlayingInfoForSong:song];
    }
    return self;
}

- (void)configNowPlayingInfoForSong:(NSDictionary *)song
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSLog(@"setting now playing info");
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        [songInfo setObject:[song objectForKey:@"Song Title"] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[song objectForKey:@"Artist"] forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:[song objectForKey:@"Album Title"] forKey:MPMediaItemPropertyAlbumTitle];
        //        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[song objectForKey:@"Artwork"]];
        //        [songInfo setObject:artwork forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[NSNumber numberWithDouble:1.0f] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [songInfo setObject:[song objectForKey:@"Song Duration"] forKey:MPMediaItemPropertyPlaybackDuration];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

- (void)play
{
    [self.musicPlayer play];

}

- (void)pause
{
    [self.musicPlayer pause];
}

- (void)stop
{
    [self.musicPlayer stop];
}


@end
