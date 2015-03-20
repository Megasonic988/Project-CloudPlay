//
//  MenuViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-17.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "MenuViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TDAudioStreamer.h"

@interface MenuViewController () <MPCSessionDelegate, MPMediaPickerControllerDelegate>

- (IBAction)chooseMusicButton:(id)sender;
@property (strong, nonatomic) NSMutableArray *mySongs; //of MPMediaItems
@property (strong, nonatomic) NSMutableArray *songsData;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.session.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.session.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (self.isMovingFromParentViewController) {
        [self sendBackMessage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendBackMessage
{
    NSDictionary *back = [[NSDictionary alloc] init];
    back = @{@"Description" : @"Back"};
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[back copy]]];
    NSLog(@"sent back");
}

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

#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mySongs addObjectsFromArray:mediaItemCollection.items];
    [self storeSongDataFromSongs:mediaItemCollection.items];
}

static const CGSize ALBUM_SIZE = {200, 200};

- (void)storeSongDataFromSongs:(NSArray *)songs
{
    NSMutableArray *songsData = [[NSMutableArray alloc] init];
    if ([[songs firstObject] isKindOfClass:[MPMediaItem class]]) {
        for (MPMediaItem *song in songs) {
            NSMutableDictionary *songData = [[NSMutableDictionary alloc] init];
            songData[@"Song Title"] = [song valueForProperty:MPMediaItemPropertyTitle] ? [song valueForProperty:MPMediaItemPropertyTitle] : @"";
            songData[@"Artist"] = [song valueForProperty:MPMediaItemPropertyArtist] ? [song valueForProperty:MPMediaItemPropertyArtist] : @"";
            songData[@"Album Title"] = [song valueForProperty:MPMediaItemPropertyAlbumTitle] ? [song valueForProperty:MPMediaItemPropertyAlbumTitle] : @"";
            MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *image = [artwork imageWithSize:ALBUM_SIZE];
            if (image) {
                songData[@"Artwork"] = image;
            } else {
                songData[@"Artwork"] = nil;
            }
            [songsData addObject:songData];
        }
    } else {
        for (NSMutableDictionary *song in songs) {
            [songsData addObject:song];
        }
    }
    [self.songsData addObject:songsData];
    NSLog(@"%@", self.songsData);
}

- (void)shareSongData
{
    
}

- (void)session:(MPCSession *)session didReceiveAudioStream:(NSInputStream *)stream
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"received audio stream");
        if (!self.inputStream) {
            self.inputStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
            usleep(75000);
            [self.inputStream start];
        }});
}

- (void)session:(MPCSession *)session didReceiveData:(NSData *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([message isKindOfClass:[NSDictionary class]]) {
            if ([[message valueForKey:@"Description"] isEqualToString:@"Back"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    });}

- (void)session:(MPCSession *)session lostConnectionToPeer:(MCPeerID *)peer{}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)chooseMusicButton:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.allowsPickingMultipleItems = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{}
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{}
- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{}
@end
