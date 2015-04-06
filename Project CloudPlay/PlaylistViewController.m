//
//  PlaylistViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "PlaylistViewController.h"
#import "SongsCollectionViewCell.h"
#import "MusicPlayerViewController.h"
@import AVFoundation;
#import "TDAudioStreamer.h"


@interface PlaylistViewController () <MPCSessionDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *leaderLabel;

- (IBAction)logoutButton:(id)sender;

@property (strong, nonatomic) IBOutlet UICollectionView *songsCollectionView;
- (IBAction)returnButton:(id)sender;

@property (strong, nonatomic) NSDictionary *currentSong;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) KWMusicPlayer *musicPlayer;

@property (assign, nonatomic) int numberOfPeersWhoHaveStoppedPlayback;
@property (assign, nonatomic) BOOL allPeersHaveStoppedPlayback;

@end

@implementation PlaylistViewController

//- (NSArray*)visibleCells
//{
//    NSMutableArray *cells = [@[] mutableCopy];
//    [cells addObjectsFromArray:[self.songsCollectionView visibleCells]];
//    
//    return cells;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.songsCollectionView registerClass:[SongsCollectionViewCell class] forCellWithReuseIdentifier:@"song cell"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(368, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.songsCollectionView setCollectionViewLayout:flowLayout];
    [self.navigationItem setHidesBackButton:YES];
    self.session.delegate = self;
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    NSLog(@"AM I THE LEADER???? %d", self.session.isLeader);
    if (self.session.isLeader) {
        [self.leaderLabel setText:@"I am the leader!"];
    } else {
        [self.leaderLabel setText:@"I am not the leader!"];
    }
    self.allPeersHaveStoppedPlayback = YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    [self.navigationController setDelegate:self];
}

//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                  animationControllerForOperation:(UINavigationControllerOperation)operation
//                                               fromViewController:(UIViewController*)fromVC
//                                                 toViewController:(UIViewController*)toVC
//{
//    if (operation != UINavigationControllerOperationNone) {
//        // Return your preferred transition operation
//        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous];
//    }
//    return nil;
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
//    [self.navigationController setDelegate:nil];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self.musicPlayer play];
                [self.inputStream resume];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self.musicPlayer pause];
                [self.inputStream pause];
                break;
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.songsData count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"song cell";
    SongsCollectionViewCell *cell = (SongsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *songTitle = [[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Song Title"];
    NSString *artist = [[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Artist"];
    
    UIImage *songImage = [[UIImage alloc] init];
    if ([[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Artwork"]) {
        songImage = [[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Artwork"];
    } else {
        songImage = [UIImage imageNamed:@"blankAlbum.png"];
        [self.songsData objectAtIndex:indexPath.row][@"Artwork"] = songImage;
    }
    
    [cell.songImage setImage:songImage];
    [cell.titleLabel setText:songTitle];
    [cell.artistLabel setText:artist];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.session.isLeader) {
        self.currentSong = [self.songsData objectAtIndex:indexPath.row];
        
        [self tellOthersToStopPlayback];
        [self stopPlayback];
    }
}

#pragma mark - Song Playback/Changing Methods

- (void)changeToSelfCurrentSong
{
    if (self.allPeersHaveStoppedPlayback && self.session.isLeader) {
        [self tellEveryoneThisIsTheNewCurrentSong:self.currentSong]; //if someone else has song, they will play it now
        [self playSong:self.currentSong]; //if the song is mine, I will stream it now
        
        [self performSegueWithIdentifier:@"show music player" sender:self];
    }
}

- (void)tellEveryoneThisIsTheNewCurrentSong:(NSDictionary *)song
{
    NSMutableDictionary *newCurrentSongMsg = [[NSMutableDictionary alloc] init];
    NSString *songTitle = [NSString stringWithFormat:@"%@", [song objectForKey:@"Song Title"]];
    newCurrentSongMsg[@"Description"] = @"New Current Song";
    newCurrentSongMsg[@"Song Title"] = songTitle;
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[newCurrentSongMsg copy]]];
}

- (void)tellOthersToStopPlayback
{
    NSMutableDictionary *stopAllStreamsAndPlaybackMsg = [[NSMutableDictionary alloc] init];
    stopAllStreamsAndPlaybackMsg[@"Description"] = @"Stop Playback";
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[stopAllStreamsAndPlaybackMsg copy]]];
}

- (void)stopPlayback
{
    if (self.musicPlayer) [self.musicPlayer stop];
    if (self.inputStream) {
        [self.inputStream stop];
        self.inputStream = nil;
    }
    if (self.outputStreamer) {
        if (self.allPeersHaveStoppedPlayback) {
            NSLog(@"stopping output streamer");
            [self.outputStreamer stop];
            self.outputStreamer = nil;
        }
    }
    if (self.session) {
        NSMutableDictionary *didStopPlaybackMsg = [[NSMutableDictionary alloc] init];
        didStopPlaybackMsg[@"Description"] = @"Did Stop Playback";
        [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[didStopPlaybackMsg copy]]];
    }
}

- (void)playSong:(NSDictionary *)song
{
    if([song valueForKey:@"Song Owner"] == self.session.peerID) {
        NSArray *peers = [self.session connectedPeers];
        if (peers.count) {
            for (MCPeerID *peer in peers) {
                self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:peer]];
                [self.outputStreamer streamAudioFromURL:[self.currentSong valueForKey:@"MediaItemURL"]];
                NSLog(@"%@", self.outputStreamer);
                [self.outputStreamer start];
                NSLog(@"starting output streamer");
            }
        }
        self.musicPlayer = [[KWMusicPlayer alloc] initWithSong:self.currentSong];
        [self.musicPlayer play];
        self.allPeersHaveStoppedPlayback = NO;
        self.numberOfPeersWhoHaveStoppedPlayback = 0;
    }
    // if it is not my song, the owner will automatically stream it to everyone else (in the changeCurrentSong method below)
}

- (void)checkIfAllPeersHaveStoppedPlayback
{
    if (self.numberOfPeersWhoHaveStoppedPlayback == [self.session.connectedPeers count]) {
        self.allPeersHaveStoppedPlayback = YES;
        NSLog(@"All peers have now stopped playback");
    }
    [self changeToSelfCurrentSong];
}

- (void)changeCurrentSong:(NSString *)songTitle
{
    for (NSDictionary *song in self.songsData) {
        if ([songTitle isEqualToString:[song valueForKey:@"Song Title"]]) {
            self.currentSong = song;
            NSLog(@"%@", song);
            break;
        }
    }
    if (self.allPeersHaveStoppedPlayback) {    //song playback occurs here
        [self playSong:self.currentSong];
        if ([self.currentSong valueForKey:@"Song Owner"] == self.session.peerID) {
            if (!self.musicPlayer) {
                self.musicPlayer = [[KWMusicPlayer alloc] initWithSong:self.currentSong];
                [self.musicPlayer play];
            }
        } else {
            self.musicPlayer = [[KWMusicPlayer alloc] init];
            [self.musicPlayer configNowPlayingInfoForSong:self.currentSong];
        }
        [self performSegueWithIdentifier:@"show music player" sender:self];
        
    }
}

#pragma mark - MPCSessionDelegate

- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"disconnected, peers left:%@", self.session.connectedPeers);
    if ([self.session.connectedPeers count] == 0) {
        NSLog(@"no peers left");
        [self resetToConnectionViewController];
    }
    });
}

- (void)session:(MPCSession *)session didReceiveAudioStream:(NSInputStream *)stream{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"received audio stream");
        self.allPeersHaveStoppedPlayback = NO;
        self.numberOfPeersWhoHaveStoppedPlayback = 0;
        if (!self.inputStream) {
            self.inputStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
            [self.inputStream start];
            NSLog(@"started audio stream");
        }});

}

- (void)session:(MPCSession *)session didReceiveData:(NSData *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"received data: %@ %i", message, self.numberOfPeersWhoHaveStoppedPlayback);
        if ([message isKindOfClass:[NSDictionary class]]) {
            if ([[message valueForKey:@"Description"] isEqualToString:@"New Current Song"]) {
                NSString *songTitle = [message valueForKey:@"Song Title"];
                [self changeCurrentSong:songTitle];
            }
            if ([[message valueForKey:@"Description"] isEqualToString:@"Stop Playback"]) {
                [self stopPlayback];
            }
            if ([[message valueForKey:@"Description"] isEqualToString:@"Did Stop Playback"]) {
                self.numberOfPeersWhoHaveStoppedPlayback++;
                NSLog(@"Number of peers who have stopped playback: %i", self.numberOfPeersWhoHaveStoppedPlayback);
                [self checkIfAllPeersHaveStoppedPlayback];
            }
        }
    });
}

- (void)session:(MPCSession *)session lostConnectionToPeer:(MCPeerID *)peer{
}


- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{}
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{}

- (IBAction)returnButton:(id)sender {
//    self.session.delegate = nil;
//    self.session = nil;
//    [self.navigationController popToRootViewControllerAnimated:NO];
    [self stopPlayback];
    [self tellOthersToStopPlayback];
    
}
- (IBAction)adjustButton:(id)sender {
    [self.musicPlayer pause];
    [self.inputStream pause];
    usleep(15000);
    [self.musicPlayer play];
    [self.inputStream resume];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show music player"]) {
        if ([segue.destinationViewController isKindOfClass:[MusicPlayerViewController class]]) {
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[MusicPlayerViewController class]]) {
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:NO];
                }
            }
            [self.musicPlayer configNowPlayingInfoForSong:self.currentSong];
            MusicPlayerViewController *musicPlayerVC = (MusicPlayerViewController *)segue.destinationViewController;
            musicPlayerVC.currentSong = self.currentSong;
            musicPlayerVC.isLeader = self.session.isLeader;
            musicPlayerVC.musicPlayer = self.musicPlayer;
            musicPlayerVC.inputStreamer = self.inputStream;
        }
    }
    
}

- (void)resetToConnectionViewController
{
    NSLog(@"going back to connection view controller");
    [self stopPlayback];
    self.session.delegate = nil;
    self.session = nil;
    self.musicPlayer = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)logoutButton:(id)sender {
    [self resetToConnectionViewController];
}
@end
