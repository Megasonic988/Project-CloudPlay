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

@interface ConnectionViewController () <MPCSessionDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

- (IBAction)displayConnectedPeers:(id)sender;
- (IBAction)startButton:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) MPCSession *session;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation ConnectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = [[MPCSession alloc] initWithPeerDisplayName:[UIDevice currentDevice].name];
    self.session.delegate = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(368, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupStartButton];
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
    
    static NSString *cellIdentifier = @"cvCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    
    [titleLabel setText:[self.session.connectedPeers[indexPath.row] displayName]];
    
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


@end
