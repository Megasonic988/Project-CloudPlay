//
//  MPCSessionData.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-24.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "MPCSessionData.h"

@implementation MPCSessionData

- (NSMutableArray *)mySongs
{
    if (!_mySongs) _mySongs = [[NSMutableArray alloc] init];
    return _mySongs;
}

- (NSMutableArray *)songsData
{
    if (!_songsData) _songsData = [[NSMutableArray alloc] init];
    return _songsData;
}

- (NSMutableArray *)justSelectedSongsData
{
    if (!_justSelectedSongsData) _justSelectedSongsData = [[NSMutableArray alloc] init];
    return _justSelectedSongsData;
}

static const CGSize ALBUM_IMAGE_SIZE = {50,50};

- (void)storeSongDataFromSongs:(NSArray *)songs withMyPeerID:(MCPeerID *)peerID;
{
    //songs are sorted into an array, organized alphabetically by song name
    NSMutableArray *songsData = [[NSMutableArray alloc] init];
    if ([[songs firstObject] isKindOfClass:[MPMediaItem class]]) {
        for (MPMediaItem *song in songs) {
            NSMutableDictionary *songData = [[NSMutableDictionary alloc] init];
            songData[@"Song Title"] = [song valueForProperty:MPMediaItemPropertyTitle] ? [song valueForProperty:MPMediaItemPropertyTitle] : @"";
            songData[@"Artist"] = [song valueForProperty:MPMediaItemPropertyArtist] ? [song valueForProperty:MPMediaItemPropertyArtist] : @"Unknown Artist";
            songData[@"Album Title"] = [song valueForProperty:MPMediaItemPropertyAlbumTitle] ? [song valueForProperty:MPMediaItemPropertyAlbumTitle] : @"Unknown Album";
            songData[@"Song Duration"] = [song valueForProperty:MPMediaItemPropertyPlaybackDuration] ? [song valueForProperty:MPMediaItemPropertyPlaybackDuration] : @"";
            songData[@"Song Owner"] = peerID;
            songData[@"isSelected"] = @"NO";
            NSNumber *randomNum = [[NSNumber alloc] initWithInt:arc4random()%100000];
            songData[@"RandomID"] = randomNum;
            if ([song valueForProperty:MPMediaItemPropertyAssetURL]) {
                songData[@"MediaItemURL"] = [song valueForProperty:MPMediaItemPropertyAssetURL];
            } else { continue; };
            MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *image = [artwork imageWithSize:ALBUM_IMAGE_SIZE];
            if (image) {
                songData[@"Artwork"] = image;
            }
            [songsData addObject:songData];
        }
    } else {
        for (NSMutableDictionary *song in songs) {
            [songsData addObject:song];
        }
    }
    for (NSMutableDictionary *song in songsData) {
        [self.songsData addObject:song];
    }
    self.justSelectedSongsData = songsData;
    NSLog(@"%@", self.songsData);
    NSLog(@"Songs count: %lu", (unsigned long)self.songsData.count);
}


@end
