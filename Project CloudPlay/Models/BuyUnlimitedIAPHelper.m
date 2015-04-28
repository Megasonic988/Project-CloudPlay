//
//  BuyUnlimitedIAPHelper.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-04-28.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "BuyUnlimitedIAPHelper.h"

@implementation BuyUnlimitedIAPHelper

+ (BuyUnlimitedIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static BuyUnlimitedIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.cloudplayers.cloudplay.unlimitedsongs",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
