//
//  Session.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-14.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "MPCSession.h"

@interface MPCSession () <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *number;

@end

@implementation MPCSession

- (instancetype)initWithPeerDisplayName:(NSString *)name
{
    self = [super init];
    if (!self) return nil;
    
    self.peerID = [[MCPeerID alloc] initWithDisplayName:name];
    
    _date = [NSDate date];
    
    _session = [[MCSession alloc] initWithPeer:self.peerID];
    _session.delegate = self;
    
    int num = arc4random()%5000;
    NSString *numstr = [NSString stringWithFormat:@"%i", num];
    self.number = [[NSString alloc] initWithString:numstr];
    NSDictionary *info = @{@"Number" : self.number};
    NSLog(@"%@", self.number);
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:info serviceType:@"cloudplay"];
    _advertiser.delegate = self;
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"cloudplay"];
    _browser.delegate = self;
    
    [self.advertiser startAdvertisingPeer];
    [self.browser startBrowsingForPeers];
    
    return self;
}

- (void)dealloc
{
    [self.browser stopBrowsingForPeers];
    [self.advertiser stopAdvertisingPeer];
    [self.session disconnect];
}

#pragma mark - MCSessionDelegate methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnecting) {
        NSLog(@"Connecting to %@", peerID.displayName);
        [self.delegate session:self didStartConnectingtoPeer:peerID];
    } else if (state == MCSessionStateConnected) {
        NSLog(@"Connected to %@", peerID.displayName);
        [self.delegate session:self didStartConnectingtoPeer:peerID];
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"Disconnected from %@", peerID.displayName);
        [self.delegate session:self didStartConnectingtoPeer:peerID];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    [self.delegate session:self didReceiveData:data];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    if ([streamName isEqualToString:@"music stream"]) {
        [self.delegate session:self didReceiveAudioStream:stream];
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

- (NSOutputStream *)outputStreamForPeer:(MCPeerID *)peer
{
    NSError *error;
    NSOutputStream *stream = [self.session startStreamWithName:@"music stream" toPeer:peer error:&error];
    
    if (error) {
        NSLog(@"Error (stream): %@", [error userInfo].description);
    }
    
    return stream;
}

- (NSArray *)connectedPeers
{
    return [self.session connectedPeers];
}

- (void)sendData:(NSData *)data
{
    NSError *error;
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    
    if (error) {
        NSLog(@"Error (data): %@", [error userInfo].description);
    }
    
}

#pragma mark - Advertising Methods

- (void)stopAdvertising
{
    [self.advertiser stopAdvertisingPeer];
}

- (void)startAdvertising
{
    [self.advertiser startAdvertisingPeer];
}


#pragma mark - Browsing Methods

- (void)startBrowsing
{
    [self.browser startBrowsingForPeers];
}

- (void)stopBrowsing
{
    [self.browser stopBrowsingForPeers];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSLog(@" did receive invitation from peer: %@", peerID.displayName);
    
//    BOOL accept = NO;
//    
//    if (context.length == 8) {
//        NSTimeInterval runningTime = -[self.date timeIntervalSinceNow];
//        NSTimeInterval otherPeerRunningTime;
//        [context getBytes:&otherPeerRunningTime length:8];
//        
//        accept = otherPeerRunningTime > runningTime;
//    }
//    
//    invitationHandler(accept, self.session);
    invitationHandler(YES, self.session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"did not start advertising peer: %@", error);
}


#pragma mark - MCNearbyServiceBrowserDelegate Methods

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"did not start browsing for peers: %@", error);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"found peer: %@", peerID.displayName);
    if (![self.session.connectedPeers containsObject:peerID]) {
        
//        NSTimeInterval runningTime = -[self.date timeIntervalSinceNow];
//        NSLog(@"%f", runningTime);
//        NSData *context = [[NSData alloc] initWithBytes:&runningTime length:sizeof(NSTimeInterval)];
//        [self.browser invitePeer:peerID toSession:self.session withContext:context timeout:30];
        if ([info valueForKey:@"Number"] > self.number) {
            [self.browser invitePeer:peerID toSession:self.session withContext:nil timeout:30];
        }
    }
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.delegate session:self lostConnectionToPeer:peerID];
}



@end
