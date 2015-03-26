//
//  MusicPlayerViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "MusicPlayerViewController.h"

@interface MusicPlayerViewController ()


@end

@implementation MusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentSong:(NSDictionary *)currentSong
{
    _currentSong = currentSong;
    self.artistLabel = [self.currentSong valueForKey:@"Artist"];
    self.songTitleLabel = [self.currentSong valueForKey:@"Song Title"];
    self.albumImageView = [self.currentSong valueForKey:@"Artwork"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
