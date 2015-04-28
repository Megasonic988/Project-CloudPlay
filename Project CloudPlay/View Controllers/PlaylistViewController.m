//
//  PlaylistViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

@import AVFoundation;
@import QuartzCore;
#import "PlaylistViewController.h"
#import "MusicPlayerViewController.h"
#import "TDAudioStreamer.h"
#import "AMWaveTransition.h"
#import "InformationView.h"
#import "CXCardView.h"



@interface PlaylistViewController () <MPCSessionDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *leaderLabel;

- (IBAction)logoutButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *songsTableView;
@property (weak, nonatomic) IBOutlet UIView *leaderInfoView;

//@property (strong, nonatomic) IBOutlet UICollectionView *songsCollectionView;
//- (IBAction)returnButton:(id)sender;

@property (strong, nonatomic) NSDictionary *currentSong;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) KWMusicPlayer *musicPlayer;

@property (assign, nonatomic) int numberOfPeersWhoHaveStoppedPlayback;
@property (assign, nonatomic) BOOL allPeersHaveStoppedPlayback;

@property (strong, nonatomic) InformationView *infoView;
@property (strong, nonatomic) InformationView *exitInfoView;
@property (weak, nonatomic) IBOutlet UIButton *nowPlayingButton;


@end

@implementation PlaylistViewController

- (NSArray*)visibleCells
{
    NSMutableArray *cells = [@[] mutableCopy];
    [cells addObjectsFromArray:[self.songsTableView visibleCells]];
    return cells;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    self.session.delegate = self;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];

    self.allPeersHaveStoppedPlayback = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];
}

- (void)setupUI
{
    [self.navigationItem setHidesBackButton:YES];
    if (self.session.isLeader) {
        [self.leaderLabel setText:@"I am the leader!"];
    } else {
        [self.leaderLabel setText:@"I am not the leader!"];
    }
    if (self.session.isLeader == NO) self.songsTableView.allowsSelection = NO;
    [self.songsTableView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.leaderInfoView.layer.borderColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1].CGColor;
    self.leaderInfoView.layer.borderWidth = 1.0f;
    self.nowPlayingButton.hidden = YES;
    [self showLeaderContentView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController setDelegate:self];
}

- (void)showLeaderContentView
{
    if (!_infoView) {
        _infoView = [InformationView viewWithChoice:1];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(20, 8, 260, 100);
        descriptionLabel.numberOfLines = 0.;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.0];
        if (self.session.isLeader) {
            NSString *leaderInformation = @"You are the leader!";
            descriptionLabel.text = leaderInformation;
        } else {
            NSString *leaderInformation = @"You are not the leader!";
            descriptionLabel.text = leaderInformation;
        }
        [_infoView addSubview:descriptionLabel];
        
        [_infoView setDismissHandler:^(InformationView *view) {
            NSLog(@"view dismissed");
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_infoView draggable:YES];
}


- (void)updateTimeLeft
{
    //this plays a random new song, checking to see how much time is left on the song
    if (self.musicPlayer) {
        NSTimeInterval timeLeft = self.musicPlayer.musicPlayer.duration - self.musicPlayer.musicPlayer.currentTime;
        NSLog(@"TIME LEFT ON SONG: %f", timeLeft);
        if ((timeLeft > (double)0.1) && (timeLeft < (double)10)) {
            if (self.session.isLeader) {
                [self playNewSong];
            } else {
                [self tellLeaderToPlayANewSong];
            }
        }
    }
}

- (void)dealloc
{
    [self.navigationController setDelegate:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation != UINavigationControllerOperationNone) {
        // Return your preferred transition operation
        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeBounce];
    }
    return nil;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
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

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songsData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Song Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *songTitle = [[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Song Title"];
    NSString *artist = [[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Artist"];
    UIImage *songImage = [[UIImage alloc] init];
    if ([[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Artwork"]) {
        songImage = [[self.songsData objectAtIndex:indexPath.row] valueForKey:@"Artwork"];
    } else {
        songImage = [UIImage imageNamed:@"blankAlbum.png"];
        [self.songsData objectAtIndex:indexPath.row][@"Artwork"] = songImage;
    }
    [cell setPreservesSuperviewLayoutMargins:NO];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    UILabel *songTitleLabel = (UILabel *)[cell viewWithTag:50];
    UILabel *artistLabel = (UILabel *)[cell viewWithTag:51];
    UIImageView *albumImageView = (UIImageView *)[cell viewWithTag:100];
    [songTitleLabel setText:songTitle];
    [artistLabel setText:artist];
    [albumImageView setImage:songImage];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.session.isLeader) {
        self.currentSong = [self.songsData objectAtIndex:indexPath.row];
        [self tellOthersToStopPlayback];
        [self stopPlayback];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)tellLeaderToPlayANewSong
{
    NSMutableDictionary *tellLeaderPlayNewSong = [[NSMutableDictionary alloc] init];
    tellLeaderPlayNewSong[@"Description"] = @"Leader Play New Song";
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[tellLeaderPlayNewSong copy]]];
}

- (void)playNewSong
{
    if (self.session.isLeader) {
        int randomNum = arc4random()%[self.songsData count];
        NSLog(@"RANDOM NUMBER IS %d", randomNum);
        self.currentSong = [self.songsData objectAtIndex:randomNum];
        NSLog(@"THE NEW CURRENT SONG IS %@", self.currentSong);
        [self tellOthersToStopPlayback];
        [self stopPlayback];
    }
}

- (void)stopPlayback
{
    if (self.musicPlayer) [self.musicPlayer stop];
    if (self.inputStream) {
        NSLog(@"STOPPING INPUT STREAM");
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
                NSLog(@"THIS IS THE OUTPUT STREAMER: %@", self.outputStreamer);
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

//the TDAudioStreamer requires all peers receiving streams to stop their stream before the output streamer plays a new song. Else, the streaming will stop functioning. Therefore, a check is implemented to check if all peers have ended their inputStreams before a new song is streamed to them.
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
            if ([[message valueForKey:@"Description"] isEqualToString:@"Leader Play New Song"]) {
                [self playNewSong];
            }
        }
    });
}

- (void)session:(MPCSession *)session lostConnectionToPeer:(MCPeerID *)peer{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"disconnected, peers left:%@", self.session.connectedPeers);
        if ([self.session.connectedPeers count] == 0) {
            NSLog(@"no peers left");
            [self resetToConnectionViewController];
        }
    });
}
- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{
}
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show music player"]) {
        self.nowPlayingButton.hidden = NO;
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
            NSTimeInterval timeLeft = self.musicPlayer.musicPlayer.duration - self.musicPlayer.musicPlayer.currentTime;
            if (timeLeft == 0.0f) {
                NSLog(@"I am streaming");
                musicPlayerVC.isStreaming = YES;
            }
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
    self.navigationController.delegate = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)logoutButton:(id)sender {
    [self showExitInfoView];
}

- (void)showExitInfoView
{
    if (!_exitInfoView) {
        _exitInfoView = [InformationView viewWithChoice:2];
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(20, 8, 260, 100);
        descriptionLabel.numberOfLines = 0.;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.0];
        NSString *information = @"Are you sure you wish to exit? All connections and songs will be reset.";
        descriptionLabel.text = information;
        [_exitInfoView addSubview:descriptionLabel];
        [_exitInfoView setDismissHandler:^(InformationView *view) {
            NSLog(@"view dismissed");
            [CXCardView dismissCurrent];
        }];
        __weak PlaylistViewController *weakSelf = self;
        [_exitInfoView setExitHandler:^(InformationView *view) {
            [CXCardView dismissCurrent];
            [weakSelf resetToConnectionViewController];
        }];
    }
    [CXCardView showWithView:_exitInfoView draggable:NO];
}


//even though the inputStream pointer is passed to the music player, the music player cannot control pause/play. Therefore, the music player will ask this view controller to handle the inputStreamer playback through a selector.
- (void)pauseStream
{
    [self.inputStream pause];
}

- (void)playStream
{
    [self.inputStream resume];
}
@end
