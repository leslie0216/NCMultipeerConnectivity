//
//  NCMCPeripheralService.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCMCSession.h"
#import "NCMCPeerID.h"

@protocol NCMCPeripheralServiceDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface NCMCPeripheralService : NSObject

- (instancetype)initWithSession:(NCMCSession*)session;

- (void)startAdvertisingPeer;
- (void)stopAdvertisingPeer;

@property (weak, NS_NONATOMIC_IOSONLY, nullable) id<NCMCPeripheralServiceDelegate> delegate;


@end

@protocol NCMCPeripheralServiceDelegate <NSObject>

- (void) peripheralService:(NCMCPeripheralService *)peripheralService
         didReceiveInvitationFromPeer:(NCMCPeerID *)peerID
         invitationHandler:(void (^)(BOOL accept, NCMCSession *session))invitationHandler;

@end

NS_ASSUME_NONNULL_END
