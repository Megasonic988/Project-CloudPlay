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
#import "KWMusicPlayer.h"
#import "PlaylistViewController.h"
#import "ConnectedPeersViewController.h"
#import "MusicPlayerViewController.h"
#import "MPCSessionData.h"

@interface MenuViewController () <MPCSessionDelegate, MPMediaPickerControllerDelegate>

- (IBAction)chooseMusicButton:(id)sender;
- (IBAction)viewConnectedPeers:(id)sender;
- (IBAction)viewPlaylist:(id)sender;
- (IBAction)displayMusicPlayer:(id)sender;

@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;
@property (strong, nonatomic) KWMusicPlayer *musicPlayer;
@property (strong, nonatomic) MPCSessionData *sessionData;

@end

@implementation MenuViewController

- (void)viewDidLoad { //
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.session.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated //
{
    [super viewWillAppear:YES];
    self.session.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated //
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

- (MPCSessionData *)sessionData //
{
    if (!_sessionData) _sessionData = [[MPCSessionData alloc] init];
    return _sessionData;
}

- (KWMusicPlayer *)musicPlayer
{
    if (!_musicPlayer) _musicPlayer = [[KWMusicPlayer alloc] init];
    return _musicPlayer;
}

#pragma mark - Media Picker delegate //

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.sessionData.mySongs addObjectsFromArray:mediaItemCollection.items];
    [self.sessionData storeSongDataFromSongs:mediaItemCollection.items withMyPeerID:self.session.peerID];
    [self shareSongData];
    self.sessionData.currentPlayingSong = [mediaItemCollection.items firstObject];
}

- (void)streamSongToOtherPeers
{
    if (self.session.connectedPeers.count) {
        for (id peer in self.session.connectedPeers) {
            self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:peer]];
            [self.outputStreamer streamAudioFromURL:[self.sessionData.songToStream valueForProperty:MPMediaItemPropertyAssetURL]];
            
            NSLog(@"%@", self.outputStreamer);
            [self.outputStreamer start];
        }
    }
}

- (void)sendStopStreamMessage
{
    NSDictionary *stopStreamMessage = @{@"Description" : @"Stopped Sending Stream"};
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[stopStreamMessage copy]]];
    NSLog(@"sent stop stream message");
}

- (void)sendDidStopInputStreamMessage
{
    NSDictionary *didstopinputstreammsg = @{@"Description" : @"Did Stop Input Stream"};
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[didstopinputstreammsg copy]]];
    NSLog(@"sent did stop input stream message");
}


- (void)shareSongData//
{
    NSLog(@"shared songs data");
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[self.sessionData.justSelectedSongsData copy]]];
}

#pragma mark - MPCSessionDelegate Methods //
- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{} //
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{} //
- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{} //

- (void)session:(MPCSession *)session didReceiveAudioStream:(NSInputStream *)stream
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendReceivedStreamMessagetoPeer:self.session.connectedPeers.firstObject];
        NSLog(@"received audio stream");
        if (!self.inputStream) {
            self.inputStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
            usleep(75000);
            [self.inputStream start];
        }});
}

- (void)sendReceivedStreamMessagetoPeer:(MCPeerID *)peer
{
    NSDictionary *nowPlayingMessage = @{@"Description" : @"Received Stream"};
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[nowPlayingMessage copy]] toPeer:peer];
    NSLog(@"sent received stream message");
}


- (void)session:(MPCSession *)session didReceiveData:(NSData *)data //
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         NSLog(@"received data: %@", message);
        if ([message isKindOfClass:[NSDictionary class]]) {
            if ([[message valueForKey:@"Description"] isEqualToString:@"Back"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else if ([[message valueForKey:@"Description"] isEqualToString:@"Received Stream"]) {
                NSLog(@"starting playback of song");
//                [self.musicPlayer playSong:[self.sessionData.mySongs firstObject]];
            } else if ([[message valueForKey:@"Description"] isEqualToString:@"Stopped Sending Stream"]) {
                [self.inputStream stop];
                self.inputStream = nil;
                [self sendDidStopInputStreamMessage];
            } else if ([[message valueForKey:@"Description"] isEqualToString:@"Did Stop Input Stream"]) {
                [self streamSongToOtherPeers];
            }
        } else {
            [self.sessionData storeSongDataFromSongs:message withMyPeerID:self.session.peerID];
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

- (IBAction)chooseMusicButton:(id)sender { //
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.allowsPickingMultipleItems = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions
- (IBAction)viewConnectedPeers:(id)sender {
}

- (IBAction)viewPlaylist:(id)sender {
}

- (IBAction)displayMusicPlayer:(id)sender {
}

- (void)sendBackMessage
{
    NSDictionary *back = [[NSDictionary alloc] init];
    back = @{@"Description" : @"Back"};
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[back copy]]];
    NSLog(@"sent back");
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show playlist"]) {
        if ([segue.destinationViewController isKindOfClass:[PlaylistViewController class]]) {
            PlaylistViewController *playlistVC = (PlaylistViewController *)segue.destinationViewController;
            NSArray *songsDataArray = [NSArray arrayWithArray:self.sessionData.songsData];
            playlistVC.songsData = songsDataArray;
        }
    } else if ([segue.identifier isEqualToString:@"show connected peers"]) {
        if ([segue.destinationViewController isKindOfClass:[ConnectedPeersViewController class]]) {
            ConnectedPeersViewController *connectedpeersVC = (ConnectedPeersViewController *)segue.destinationViewController;
            connectedpeersVC.connectedPeers = self.session.connectedPeers;
        }
    } else if ([segue.identifier isEqualToString:@"show music player"]) {
        if ([segue.destinationViewController isKindOfClass:[MusicPlayerViewController class]]) {
            MusicPlayerViewController *musicPlayerVC = (MusicPlayerViewController *)segue.destinationViewController;
            musicPlayerVC.currentSong = self.sessionData.currentPlayingSong;
        }
    }
}

@end
