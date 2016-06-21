//
//  NCMCPeripheralService.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "NCMCPeripheralService.h"
#import "Core/NCMCPeripheralService+Core.h"
#import "Core/NCMCBluetoothLEManager.h"

@implementation NCMCPeripheralService

@synthesize session;

-(instancetype)initWithSession:(NCMCSession *)ncmcsession
{
    self = [super init];
    
    if (self) {
        self.session = ncmcsession;
    }
    
    return self;
}

-(void)startAdvertisingPeer
{
    
}

-(void)stopAdvertisingPeer
{
    
}

-(void)notifyDidReceiveInvitationFromPeer:(NCMCPeerID *)peerID invitationHandler:(void (^)(BOOL, NCMCSession *))invitationHandler
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(peripheralService:didReceiveInvitationFromPeer:invitationHandler:)]) {
        [self.delegate peripheralService:self didReceiveInvitationFromPeer:peerID invitationHandler:invitationHandler];
    }
}

@end
