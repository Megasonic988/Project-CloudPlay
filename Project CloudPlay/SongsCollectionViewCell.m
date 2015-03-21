//
//  SongsCollectionViewCell.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-20.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "SongsCollectionViewCell.h"

@implementation SongsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:self options:nil];
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        if (![[arrayOfViews firstObject] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews firstObject];
    }
    return self;
}


@end
