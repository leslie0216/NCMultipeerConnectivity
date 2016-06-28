//
//  MultiplayerController.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "MultiplayerController.h"
#import "NCMCPeerID.h"
#import "NCMCAlertView.h"
#import "Parameters.h"

@implementation MultiplayerController

@synthesize currentSession, currentCentralService, currentPeripheralService, isHost, localName;


static MultiplayerController *_sharedMultiplayerController = nil;

+ (MultiplayerController *)instance {
    
    @synchronized(self) {
        
        if (_sharedMultiplayerController == nil) {
            _sharedMultiplayerController = [[MultiplayerController alloc] init];
        }
    }
    
    return _sharedMultiplayerController;
}

-(void)initializeControllerForNewMatch
{
    NCMCPeerID *peer = [[NCMCPeerID alloc]initWithDisplayName:self.localName];
    self.currentSession = [[NCMCSession alloc]initWithPeer:peer andServiceID:TRANSFER_SERVICE_UUID];
    
    self.currentSession.delegate = self;
    
    if (self.currentPeripheralService != nil) {
        [self.currentPeripheralService stopAdvertisingPeer];
        self.currentPeripheralService.delegate = nil;
        self.currentPeripheralService = nil;
    }
    
    if (self.currentCentralService != nil) {
        [self.currentCentralService stopBrowsingForPeers];
        self.currentCentralService.delegate = nil;
        self.currentCentralService = nil;
    }
    
    if (self.currentSessionPlayerIDs != nil) {
        [self.currentSessionPlayerIDs removeAllObjects];
    } else {
        self.currentSessionPlayerIDs = [[NSMutableArray alloc] init];
    }
    
    [self.currentSessionPlayerIDs addObject:self.currentSession.myPeerID];
}

-(void)joinServerHostedGame
{
    [self initializeControllerForNewMatch];
    self.isHost = NO;
    self.currentPeripheralService = [[NCMCPeripheralService alloc]initWithSession:self.currentSession];
    self.currentPeripheralService.delegate = self;
    //[self.currentPeripheralService startAdvertisingPeer];
}

-(void)createServerHostedGame
{
    [self initializeControllerForNewMatch];
    self.isHost = YES;
    self.currentCentralService = [[NCMCCentralService alloc]initWithSession:self.currentSession];
    self.currentCentralService.delegate = self;
    //[self.currentCentralService startBrowsingForPeers];
}

- (void)disconnect
{
    [self.currentSession disconnect];
    if (self.currentSessionPlayerIDs != nil) {
        [self.currentSessionPlayerIDs removeAllObjects];
    }
}

-(void)startHost
{
    if (self.isHost) {
        [self.currentCentralService startBrowsingForPeers];
    }
}

-(void)startClient
{
    if (!self.isHost) {
        [self.currentPeripheralService startAdvertisingPeer];
    }
}

// session delegate
-(void)session:(NCMCSession *)session peer:(NCMCPeerID *)peerID didChangeState:(NCMCSessionState)state
{
    CCLOG(@"MCSession session peer didChangeState : %@, state : %d", [peerID getDisplayName], state);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
                
            case NCMCSessionStateConnected: {
                
                [self.currentSessionPlayerIDs addObject:peerID];
                
                if (!self.isHost) {
                    if (self.currentPeripheralService) {
                        [self.currentPeripheralService stopAdvertisingPeer];
                        self.currentPeripheralService.delegate = nil;
                        self.currentPeripheralService = nil;
                    }
                    
                    if (self.currentCentralService) {
                        [self.currentCentralService stopBrowsingForPeers];
                        self.currentCentralService.delegate = nil;
                        self.currentCentralService = nil;
                    }
                }
                break;
            }
            case NCMCSessionStateNotConnected: {
                for (NCMCPeerID *pid in self.currentSessionPlayerIDs) {
                    if ([[pid getDisplayName] isEqualToString:[peerID getDisplayName]]) {
                        [self.currentSessionPlayerIDs removeObject:pid];
                        break;
                    }
                }
                
                break;
            }
        };
    });
}

-(void)session:(NCMCSession *)session didReceiveData:(NSData *)data fromPeer:(NCMCPeerID *)peerID
{
    
}

-(void)centralService:(NCMCCentralService *)centralService foundPeer:(NCMCPeerID *)peerID
{
     dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isHost) {
                NSString* msg = [NSString stringWithFormat:@"\"%@\" would like to join your game, do you accept?", [peerID getDisplayName]];
                
                NCMCAlertView *alert = [[NCMCAlertView alloc] initWithTitle:@"Player Request" message:msg delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
                
                alert.target = peerID;
                alert.tag = 1;
                
                [alert show];
            }
         });
}

-(void)centralService:(NCMCCentralService *)centralService lostPeer:(NCMCPeerID *)peerID
{
    
}

-(void)centralService:(NCMCCentralService *)centralService didNotStartBrowsingForPeers:(NSError *)error
{
    
}

-(void)peripheralService:(NCMCPeripheralService *)peripheralService didReceiveInvitationFromPeer:(NCMCPeerID *)peerID invitationHandler:(void (^)(BOOL, NCMCSession * _Nonnull, NCMCPeerID * _Nonnull))invitationHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isHost) {
            NSString* msg = [NSString stringWithFormat:@"The game \"%@\" was found,. Would you like to connect?", [peerID getDisplayName]];
            
            NCMCAlertView *alert = [[NCMCAlertView alloc] initWithTitle:@"Game Found" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
            
            alert.target = peerID;
            alert.handler = invitationHandler;
            alert.tag = 2;
            
            [alert show];
        }
    });

}

-(void)peripheralService:(NCMCPeripheralService *)peripheralService didNotStartAdvertising:(NSError *)error
{
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Accept"]) {
            NCMCAlertView* alertV = (NCMCAlertView*)alertView;
            [self.currentCentralService invitePeer:alertV.target];
        }
    } else if (alertView.tag == 2) {
        NCMCAlertView* alertV = (NCMCAlertView*)alertView;
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
            alertV.handler(NO, self.currentSession, alertV.target);
        } else {
            alertV.handler(YES, self.currentSession, alertV.target);
        }
    }
}
@end
