//
//  SongSelectionViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-26.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "SongSelectionViewController.h"
#import "PlaylistViewController.h"
@import MultipeerConnectivity;
@import MediaPlayer;
#import "AMWaveTransition.h"

@interface SongSelectionViewController () <MPCSessionDelegate, MPMediaPickerControllerDelegate, AMWaveTransitioning, UINavigationControllerDelegate>

- (IBAction)randomSongsButton:(id)sender;
- (IBAction)chooseSongsButton:(id)sender;
- (IBAction)skipButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *randomSongsButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseSongsButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (strong, nonatomic) MPCSessionData *sessionData;

@property (assign, nonatomic) NSUInteger songShares;
@property (assign, nonatomic) BOOL hasChosen;

@end

@implementation SongSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.session.delegate = self;
}

//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                  animationControllerForOperation:(UINavigationControllerOperation)operation
//                                               fromViewController:(UIViewController*)fromVC
//                                                 toViewController:(UIViewController*)toVC
//{
//    if (operation != UINavigationControllerOperationNone) {
//        // Return your preferred transition operation
//        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeBounce];
//    }
//    return nil;
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (self.isMovingFromParentViewController) {
        [self sendBackMessage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setDelegate:self];
}

- (void)sendBackMessage
{
    NSDictionary *back = [[NSDictionary alloc] init];
    back = @{@"Description" : @"Back"};
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[back copy]]];
    NSLog(@"sent back");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MPCSessionData *)sessionData
{
    if (!_sessionData) _sessionData = [[MPCSessionData alloc] init];
    return _sessionData;
}

#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.sessionData.mySongs addObjectsFromArray:mediaItemCollection.items];
    [self.sessionData storeSongDataFromSongs:mediaItemCollection.items withMyPeerID:self.session.peerID];
    [self shareSongData];
    self.sessionData.currentPlayingSong = [mediaItemCollection.items firstObject];
    
    [self setHasChosen:YES];
    self.randomSongsButton.enabled = NO;
    self.chooseSongsButton.enabled = NO;
    self.skipButton.enabled = NO;
    if (self.songShares == [self.session.connectedPeers count] && self.hasChosen == YES)
    {
        [self performSegueWithIdentifier:@"show playlist" sender:self];
    }
}

- (void)shareSongData
{
    NSLog(@"shared songs data");
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[self.sessionData.justSelectedSongsData copy]]];
}

#pragma mark - MPCSessionDelegate Methods
- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{}
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{}
- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{}

- (void)session:(MPCSession *)session didReceiveData:(NSData *)data //
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        @try {
            id message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSLog(@"received data: %@", message);
            if ([message isKindOfClass:[NSDictionary class]]) {
                if ([[message valueForKey:@"Description"] isEqualToString:@"Back"]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            } else {
                [self.sessionData storeSongDataFromSongs:message withMyPeerID:self.session.peerID];
                self.songShares++;
                if (self.songShares == [self.session.connectedPeers count] && self.hasChosen == YES)
                {
                    [self performSegueWithIdentifier:@"show playlist" sender:self];
                }
            }

        }
        @catch (NSException *exception) {
            self.songShares++;
            if (self.songShares == [self.session.connectedPeers count] && self.hasChosen == YES)
            {
                [self performSegueWithIdentifier:@"show playlist" sender:self];
            }
            NSLog(@"exception: %@", exception);
        }
        @finally {
            
        }
    });}

- (IBAction)randomSongsButton:(id)sender {
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    NSArray *allSongs = [songsQuery items];
    NSUInteger songCount = [allSongs count];
    NSMutableArray *selectedSongs = [[NSMutableArray alloc] init];
    if (songCount < 10) return;
    while ([selectedSongs count] < 10) {
        NSUInteger randomNum = arc4random() % songCount;
        [selectedSongs addObject:[allSongs objectAtIndex:randomNum]];
    }
    [self.sessionData storeSongDataFromSongs:selectedSongs withMyPeerID:self.session.peerID];
    
    [self shareSongData];
    [self setHasChosen:YES];
    self.randomSongsButton.enabled = NO;
    self.chooseSongsButton.enabled = NO;
    self.skipButton.enabled = NO;
    if (self.songShares == [self.session.connectedPeers count] && self.hasChosen == YES)
    {
        [self performSegueWithIdentifier:@"show playlist" sender:self];
    }

}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseSongsButton:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.allowsPickingMultipleItems = YES;
    picker.showsCloudItems = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)skipButton:(id)sender {
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]]];
    
    [self setHasChosen:YES];
    self.randomSongsButton.enabled = NO;
    self.chooseSongsButton.enabled = NO;
    self.skipButton.enabled = NO;
    if (self.songShares == [self.session.connectedPeers count] && self.hasChosen == YES)
    {
        [self performSegueWithIdentifier:@"show playlist" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show playlist"]) {
        if ([segue.destinationViewController isKindOfClass:[PlaylistViewController class]]) {
            PlaylistViewController *playlistVC = (PlaylistViewController *)segue.destinationViewController;
            NSArray *songsDataArray = [NSArray arrayWithArray:self.sessionData.songsData];
            NSSortDescriptor *randomIDDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Song Title" ascending:YES];
            NSArray *shuffledSongs = [songsDataArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:randomIDDescriptor]];
            playlistVC.songsData = shuffledSongs;
            playlistVC.session = self.session;
            playlistVC.mySongs = self.sessionData.mySongs;
        }
    }
}

@end
