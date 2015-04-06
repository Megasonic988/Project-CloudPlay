//
//  MusicPlayerViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-19.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "KWMusicPlayer.h"
@import AudioToolbox;
@import MediaPlayer;
#import "UIImageEffects.h"

@interface MusicPlayerViewController ()



@end

@implementation MusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.artistLabel setText:[self.currentSong valueForKey:@"Artist"]];
    [self.songTitleLabel setText:[self.currentSong valueForKey:@"Song Title"]];
    [self.albumImageView setImage:[self.currentSong valueForKey:@"Artwork"]];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    UIImage *backgroundImage = [self blurWithImageEffects:[self.currentSong valueForKey:@"Artwork"]];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = backgroundImage;
    [self.view insertSubview:backgroundImageView atIndex:0];
}

- (UIImage *)blurWithImageEffects:(UIImage *)image
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [UIImageEffects imageByApplyingBlurToImage:image withRadius:8 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.inputStreamer = nil;
    [self.musicPlayer stop];
    self.musicPlayer = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self.musicPlayer play];
                [self.inputStreamer resume];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self.musicPlayer pause];
                [self.inputStreamer pause];
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

#pragma mark - PlaylistViewControllerDelegate

- (void)startSongPlayback
{
    NSLog(@"starting playback");
    [self.musicPlayer play];
}

- (void)pauseSongPlayback
{
    [self.musicPlayer pause];
}

- (void)popDelegateViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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
