//
//  InformationView.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-04-21.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "InformationView.h"

@interface InformationView ()
{
    UIView *_backgroundView;
    UIButton *_dismissButton;
    UIButton *_okayButton;
    UILabel *_description;
}

- (void)setup;
- (void)dismissButtonPressed:(UIButton *)button;

@end

@implementation InformationView

- (id)initLeaderView
{
    self = [super init];
    if (self) {
        [self setupLeaderView];
    }
    return self;
}

- (id)initInfoView
{
    self = [super init];
    if (self) {
        [self setupInfoView];
    }
    return self;
}

- (id)initExitView
{
    self = [super init];
    if (self) {
        [self setupExitView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _backgroundView.frame = self.bounds;
}
#pragma mark -
+ (InformationView *)viewWithChoice:(NSInteger)choice;
{
    InformationView *view;
    switch (choice) {
        case 1:
            view = [[InformationView alloc] initLeaderView];
            view.frame = CGRectMake( 0, 0, 300, 150);
            break;
        case 2:
            view = [[InformationView alloc] initExitView];
            view.frame = CGRectMake( 0, 0, 300, 150);
            break;
        case 3:
            view = [[InformationView alloc] initInfoView];
            view.frame = CGRectMake( 0, 0, 300, 440);
            break;
        default:
            break;
    }
    return view;
}

#pragma mark -
- (void)setupLeaderView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = 2.;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0.0, 1.);
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.shadowRadius = 2.;
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.alpha = 0.8;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_backgroundView];
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dismissButton.frame = CGRectMake(0, 150 - 44, 300, 44);
    _dismissButton.backgroundColor = [UIColor colorWithRed:0.737 green:0.863 blue:0.706 alpha:0.600];
    [_dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [_dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_dismissButton setTitleColor:[UIColor colorWithRed:0.431 green:0.706 blue:0.992 alpha:1.000] forState:UIControlStateHighlighted];
    [self addSubview:_dismissButton];
}

- (void)setupExitView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = 2.;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0.0, 1.);
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.shadowRadius = 2.;
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.alpha = 0.8;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_backgroundView];
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dismissButton.frame = CGRectMake(0, 150 - 44, 150, 44);
    _dismissButton.backgroundColor = [UIColor colorWithRed:0.737 green:0.863 blue:0.706 alpha:0.600];
    [_dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_dismissButton setTitleColor:[UIColor colorWithRed:0.431 green:0.706 blue:0.992 alpha:1.000] forState:UIControlStateHighlighted];
    [self addSubview:_dismissButton];
    
    _okayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okayButton.frame = CGRectMake(150, 150 - 44, 150, 44);
    _okayButton.backgroundColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:18/255.0 alpha:0.600];
    [_okayButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_okayButton setTitle:@"Okay" forState:UIControlStateNormal];
    [_okayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_okayButton setTitleColor:[UIColor colorWithRed:0.431 green:0.706 blue:0.992 alpha:1.000] forState:UIControlStateHighlighted];
    [self addSubview:_okayButton];
}

- (void)setupInfoView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = 2.;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0.0, 1.);
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.shadowRadius = 2.;
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.alpha = 0.8;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_backgroundView];
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dismissButton.frame = CGRectMake(0, 440 - 44, 300, 44);
    _dismissButton.backgroundColor = [UIColor colorWithRed:0.737 green:0.863 blue:0.706 alpha:0.600];
    [_dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [_dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_dismissButton setTitleColor:[UIColor colorWithRed:0.431 green:0.706 blue:0.992 alpha:1.000] forState:UIControlStateHighlighted];
    [self addSubview:_dismissButton];
}


//Actions
- (void)dismissButtonPressed:(UIButton *)button
{
    if (self.dismissHandler) {
        self.dismissHandler(self);
    }
}

- (void)exitButtonPressed:(UIButton *)button
{
    if (self.exitHandler) {
        self.exitHandler(self);
    }
}
@end
