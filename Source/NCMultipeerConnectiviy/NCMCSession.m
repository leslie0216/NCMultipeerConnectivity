//
//  NCMCSession.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "NCMCSession.h"
#import "Core/NCMCBluetoothLEManager.h"
#import "Core/NCMCSession+Core.h"

@implementation NCMCSession

@synthesize serviceID, myPeerID;

-(instancetype)initWithPeer:(NCMCPeerID*)peerID  andServiceID:(NSString*)sid
{
    self = [super init];
    
    if (self) {
        self.serviceID = sid;
        self.myPeerID = peerID;
    }
    
    return self;
}

-(void)disconnect
{
    [[NCMCBluetoothLEManager instance] disconnect];
}

-(void)sendData:(NSData *)data toPeers:(NSArray<NCMCPeerID *> *)peerIDs
{
    // call manager to send data
}

-(void)notifyPeerStateChanged:(NCMCPeerID *)peerID newState:(NCMCSessionState)state
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(session:peer:didChangeState:)]) {
        [self.delegate session:self peer:peerID didChangeState:state];
    }
}

-(void)notifyDidReceiveData:(NSData *)data fromPeer:(NCMCPeerID *)peerID
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(session:didReceiveData:fromPeer:)]) {
        [self.delegate session:self didReceiveData:data fromPeer:peerID];
    }
}

@end
