//
//  ConnectedPeerCVCell.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-16.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "ConnectedPeerCVCell.h"

@implementation ConnectedPeerCVCell

- (UILabel *)peerLabel
{
    if (!_peerLabel) _peerLabel = [[UILabel alloc] init];
    
    return _peerLabel;
}

- (void)setLabel:(UILabel *)peerLabel
{
    _peerLabel = peerLabel;
}

@end
