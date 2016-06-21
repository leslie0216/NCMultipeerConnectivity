//
//  NCMCSession+Core.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-21.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCMCSession.h"

@interface NCMCSession()

@property (strong, nonatomic)NCMCPeerID* myPeerID;
@property (strong, nonatomic)NSString* serviceID;

-(void)notifyPeerStateChanged:(NCMCPeerID *)peerID newState:(NCMCSessionState)state;
-(void)notifyDidReceiveData:(NSData *)data fromPeer:(NCMCPeerID *)peerID;

@end
