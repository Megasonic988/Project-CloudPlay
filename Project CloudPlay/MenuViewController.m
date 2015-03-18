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
@property (strong, nonatomic) MPMediaItem *song;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;

@property (weak, nonatomic) UIImageView *albumImage;
@property (weak, nonatomic) UILabel *songTitle;
@property (weak, nonatomic) UILabel *songArtist;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.session.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.song = mediaItemCollection.items[0];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"title"] = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
    info[@"artist"] = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";
    
    MPMediaItemArtwork *artwork = [self.song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:self.albumImage.frame.size];
    if (image)
        info[@"artwork"] = image;
    
    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = nil;
    
    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];
    
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[info copy]]];
    
    
    [self.outputStreamer stop];
    
    
    NSArray *peers = [self.session connectedPeers];
    
    if (peers.count) {
        for (id object in peers) {
            self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:object]];
            [self.outputStreamer streamAudioFromURL:[self.song valueForProperty:MPMediaItemPropertyAssetURL]];
            
            NSLog(@"%@", self.outputStreamer);
            [self.outputStreamer start];
        }
    }
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

- (void)session:(MPCSession *)session didReceiveData:(NSData *)data{}
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
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{}
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{}
- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{}
@end
