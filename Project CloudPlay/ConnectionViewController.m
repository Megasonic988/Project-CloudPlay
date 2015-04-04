//
//  ViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-14.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "ConnectionViewController.h"
#import "MPCSession.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "ConnectedPeerCVCell.h"
#import "SongSelectionViewController.h"
#import "BOZPongRefreshControl.h"
@import QuartzCore;

@interface ConnectionViewController () <MPCSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

- (IBAction)displayConnectedPeers:(id)sender;
- (IBAction)startButton:(id)sender;

@property (weak, nonatomic) BOZPongRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) MPCSession *session;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;
- (IBAction)restartConnectionButton:(id)sender;

@end

@implementation ConnectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = [[MPCSession alloc] initWithPeerDisplayName:[UIDevice currentDevice].name];
    self.session.delegate = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"PeerCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"peerCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.view.bounds.size.width, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView.alwaysBounceVertical = YES;
    [flowLayout setMinimumInteritemSpacing:20];
    
    [self.navigationController.view setBackgroundColor:[UIColor colorWithRed:197/247.0 green:239/247.0 blue:247/247.0 alpha:1.000]];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupStartButton];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setTitle:@"Cloudplay"];
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.collectionView.contentOffset = CGPointMake(0, -70);
    } completion:^(BOOL finished){
        if (finished) {
            [self.refreshControl beginLoading];
        }
    }];
}

- (void)viewDidLayoutSubviews
{
    self.refreshControl = [BOZPongRefreshControl attachToTableView:self.collectionView withRefreshTarget:self andRefreshAction:@selector(refreshTriggered)];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:137/255.0 green:196/255.0 blue:244/255.0f alpha:0.6];
    self.refreshControl.foregroundColor = [UIColor colorWithRed:211/255.0 green:84/255.0 blue:0/255.0f alpha:1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_current_queue(), ^{
    [self.refreshControl scrollViewDidScroll];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    dispatch_async(dispatch_get_current_queue(), ^{
        [self.refreshControl scrollViewDidEndDragging];
    });
}

- (void)refreshTriggered
{
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue", NULL);
    dispatch_async(myQueue, ^{
        [self.session stopAdvertising];
        [self.session stopBrowsing];
        self.session = nil;
        self.session = [[MPCSession alloc] initWithPeerDisplayName:[UIDevice currentDevice].name];
        self.session.delegate = self;
        [self.session startAdvertising];
        [self.session startBrowsing];
        [self.session setIsLeader:YES];
    }
                   );
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(stopRefreshing) userInfo:nil repeats:NO];
   
}

- (void)stopRefreshing
{
    [self.refreshControl finishedLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.session.delegate = self;
    [self.session startAdvertising];
    [self.session startBrowsing];
    [self setupStartButton];
    [self updatePlayers];
    self.session.isLeader = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self.session stopAdvertising];
    [self.session stopBrowsing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Start Control

- (void)setupStartButton
{
    self.startButton.enabled = NO;
}

- (void)startButton:(id)sender
{
    [self sendStartMessage];
    [self performSegueWithIdentifier:@"show menu" sender:self];
}

#pragma mark - MPCSessionDelegate
- (void)session:(MPCSession *)session didReceiveAudioStream:(NSInputStream *)stream{}

- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{
    [self updatePlayers];
}
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{
    [self updatePlayers];
}
- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{
    [self updatePlayers];
}

- (void)session:(MPCSession *)session didReceiveData:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([message isKindOfClass:[NSDictionary class]]) {
            if ([[message valueForKey:@"Description"] isEqualToString:@"Start"]) {
                NSLog(@"other player has started");
                [self performSegueWithIdentifier:@"show menu" sender:self];
            }
        }
    });
}

- (void)sendStartMessage
{
    NSDictionary *start = [[NSDictionary alloc] init];
    start = @{@"Description" : @"Start"};
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[start copy]]];
    NSLog(@"sent start");
}

- (void)updatePlayers;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        self.startButton.enabled = ([self.session.connectedPeers count] > 0);
        [self.refreshControl finishedLoading];
    });
}

- (void)session:(MPCSession *)session lostConnectionToPeer:(MCPeerID *)peer
{
    [self updatePlayers];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.session.connectedPeers count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"peerCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    [titleLabel setText:[self.session.connectedPeers[indexPath.row] displayName]];
    [titleLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:28]];
    
    return cell;
    
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SongSelectionViewController class]]) {
        SongSelectionViewController *songselVC = (SongSelectionViewController *)segue.destinationViewController;
        songselVC.session = self.session;
    }
}


- (IBAction)restartConnectionButton:(id)sender {
    [self.session stopAdvertising];
    [self.session stopBrowsing];
    self.session = nil;
    self.session = [[MPCSession alloc] initWithPeerDisplayName:[UIDevice currentDevice].name];
    self.session.delegate = self;
    [self.session startAdvertising];
    [self.session startBrowsing];
    [self.session setIsLeader:YES];
}
@end
