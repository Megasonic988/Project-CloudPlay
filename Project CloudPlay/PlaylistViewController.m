//
//  PlaylistViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "PlaylistViewController.h"
#import "SongsCollectionViewCell.h"


@interface PlaylistViewController () <MPCSessionDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *songsCollectionView;
- (IBAction)returnButton:(id)sender;

@end

@implementation PlaylistViewController

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MPCSessionDelegate

- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer{
    if ([self.session.connectedPeers count] == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)returnButton:(id)sender {
    [self performSegueWithIdentifier:@"restart" sender:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
