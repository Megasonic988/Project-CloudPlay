//
//  SongsCollectionViewCell.h
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-20.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongsCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UIImageView *songImage;

@end
