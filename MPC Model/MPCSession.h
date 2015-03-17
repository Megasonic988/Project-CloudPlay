//
//  Session.h
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-03-14.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@class MPCSession;

@protocol MPCSessionDelegate <NSObject>

@optional
- (void)session:(MPCSession *)session didReceiveAudioStream:(NSInputStream *)stream;
- (void)session:(MPCSession *)session didReceiveData:(NSData *)data;
- (void)session:(MPCSession *)session lostConnectionToPeer:(MCPeerID *)peer;

@required
- (void)session:(MPCSession *)session didStartConnectingtoPeer:(MCPeerID *)peer;
- (void)session:(MPCSession *)session didFinishConnetingtoPeer:(MCPeerID *)peer;
- (void)session:(MPCSession *)session didDisconnectFromPeer:(MCPeerID *)peer;

@end

@interface MPCSession : NSObject

@property (strong, nonatomic) MCPeerID *peerID;

@property (weak, nonatomic) id <MPCSessionDelegate> delegate;

- (instancetype)initWithPeerDisplayName:(NSString *)name;

- (void)startAdvertising;
- (void)stopAdvertising;
- (void)startBrowsing;
- (void)stopBrowsing;

- (NSArray *)connectedPeers;

- (NSOutputStream *)outputStreamForPeer:(MCPeerID *)peer;
- (void)sendData:(NSData *)data;



@end
