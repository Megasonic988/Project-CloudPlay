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
#import "MenuViewController.h"


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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)displayConnectedPeers:(id)sender {
    NSLog(@"Connected peers: %@", self.session.connectedPeers);
    dispatch_async(dispatch_get_main_queue(), ^{[self.collectionView reloadData];});
}

- (void)setupStartButton
{
    self.startButton.enabled = NO;
}

- (void)startButton:(id)sender
{
    
}

- (void)session:(MPCSession *)session didReceiveAudioStream:(NSInputStream *)stream{}
- (void)session:(MPCSession *)session didReceiveData:(NSData *)data{}

- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer{
    [self updatePlayers];
}
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer{
    [self updatePlayers];
}
- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{
    [self updatePlayers];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self.session stopAdvertising];
    [self.session stopBrowsing];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MenuViewController class]]) {
        MenuViewController *menuVC = (MenuViewController *)segue.destinationViewController;
        menuVC.session = self.session;
    }
}

#pragma mark - 

@end