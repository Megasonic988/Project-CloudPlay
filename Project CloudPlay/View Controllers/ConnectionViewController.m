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
#import "AMPopTip.h"
#import "InformationView.h"
#import "CXCardView.h"

@interface ConnectionViewController () <MPCSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *redPopTipButton;
- (IBAction)popTipButton:(UIButton *)sender;


@property (nonatomic, strong) AMPopTip *popTip;

@property (weak, nonatomic) BOZPongRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) MPCSession *session;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
- (IBAction)infoButton:(UIButton *)sender;

@property (strong, nonatomic) InformationView *infoView;

@end

@implementation ConnectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
    [self.navigationController.view setBackgroundColor:[UIColor colorWithRed:197/247.0 green:239/247.0 blue:247/247.0 alpha:1.000]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
// this code refreshed on startup by animating a drag
//    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        self.collectionView.contentOffset = CGPointMake(0, -70);
//    } completion:^(BOOL finished){
//        if (finished) {
//            [self.refreshControl beginLoadingAnimated:YES];
//        }
//    }];
    
    [self setupPopTip];
}

- (void)setupCollectionView
{
    UINib *cellNib = [UINib nibWithNibName:@"PeerCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"peerCell"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.view.bounds.size.width, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView.alwaysBounceVertical = YES;
    [flowLayout setMinimumInteritemSpacing:20];
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)setupPopTip
{
    [[AMPopTip appearance] setFont:[UIFont fontWithName:@"Avenir-Medium" size:15]];
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 2;
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.popTip.tapHandler = ^{
        NSLog(@"Tap!");
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
    self.popTip.popoverColor = [UIColor colorWithRed:0.31 green:0.57 blue:0.87 alpha:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.popTip showText:@"Welcome to Cloudplay! Pull down to refresh connections." direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:self.redPopTipButton.frame duration:0];
    [self.navigationController.view setBackgroundColor:[UIColor colorWithRed:197/247.0 green:239/247.0 blue:247/247.0 alpha:1.000]];
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // this code starts an MPC session that is passed on to each new view controller
    self.session = nil;
    self.session = [[MPCSession alloc] initWithPeerDisplayName:[UIDevice currentDevice].name];
    self.session.delegate = self;
    [self.session startAdvertising];
    [self.session startBrowsing];
    [self setupStartButton];
    [self updatePlayers];
    //
    
    [self setupStartButton];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setTitle:@"Cloudplay"];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.view setBackgroundColor:[UIColor colorWithRed:197/247.0 green:239/247.0 blue:247/247.0 alpha:1.000]];
}

- (void)viewDidLayoutSubviews
{
    self.refreshControl = [BOZPongRefreshControl attachToTableView:self.collectionView withRefreshTarget:self andRefreshAction:@selector(refreshTriggered)];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:137/255.0 green:196/255.0 blue:244/255.0f alpha:0.6];
    self.refreshControl.foregroundColor = [UIColor colorWithRed:211/255.0 green:84/255.0 blue:0/255.0f alpha:1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.refreshControl scrollViewDidScroll];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl scrollViewDidEndDragging];
    });
}

- (void)refreshTriggered
{
    // a refresh ends the current session and restarts a new one
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
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(stopRefreshing) userInfo:nil repeats:NO];
}

- (void)stopRefreshing
{
    [self.refreshControl finishedLoading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    //connection broadcasting ends when this view is off screen
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
    [self.startButton setTitle:@"Waiting..." forState:UIControlStateDisabled];
    [self.startButton.layer setShadowOffset:CGSizeMake(2, 2)];
    [self.startButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.startButton.layer setShadowOpacity:0.5];
    [self.startButton.layer setShadowRadius:3.0];
}

- (void)startButton:(id)sender
{   //starting on one device also causes all other devices to start
    [self sendStartMessage];
}

#pragma mark - MPCSessionDelegate Methods
- (void)session:(MPCSession *)session didReceiveAudioStream:(NSInputStream *)stream{}

//UI update is called whenever connection status is changed
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
        [self stopRefreshing];
    });
}

- (void)session:(MPCSession *)session lostConnectionToPeer:(MCPeerID *)peer
{
    [self updatePlayers];
}

#pragma mark - UICollectionView DataSource Methods

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

- (IBAction)popTipButton:(UIButton *)sender {
    [self.popTip hide];
    [self stopRefreshing];
    if ([self.popTip isVisible]) {
        return;
    }
    self.popTip.popoverColor = [UIColor colorWithRed:0.31 green:0.57 blue:0.87 alpha:1];
    static int direction = 0;
    [self.popTip showText:@"Welcome to Cloudplay! Pull down to refresh connections." direction:direction maxWidth:200 inView:self.view fromFrame:sender.frame duration:0];
    direction = (direction + 1) % 4;
}

- (IBAction)infoButton:(UIButton *)sender {
    [self showInfoContentView];
}

- (void)showInfoContentView
{
    if (!_infoView) {
        _infoView = [InformationView viewWithChoice:3];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(20, 8, 260, 380);
        descriptionLabel.numberOfLines = 0.;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.0];
        NSString *info = @"Cloudplay is a local music sharing app. Create playlists on the fly, share them with your friends, and listen simultaneously.\n\nBegin by connecting to your friends. Cloudplay will automatically link you to others who are using the app.\n\nNext, choose the songs you would like to share.\n\nFinally, turn up the volume and play your shared music! One person will be designated the leader and have the ability to choose the music.";
        descriptionLabel.text = info;
        [_infoView addSubview:descriptionLabel];
        
        [_infoView setDismissHandler:^(InformationView *view) {
            NSLog(@"view dismissed");
            [CXCardView dismissCurrent];
        }];
    }
    [CXCardView showWithView:_infoView draggable:YES];
}
@end
