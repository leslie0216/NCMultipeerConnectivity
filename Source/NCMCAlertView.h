//
//  NCMCAlertView.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-27.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCMCPeerID.h"
#import "NCMCSession.h"

typedef void (^MyInvitationHandler)(BOOL accept, NCMCSession *session, NCMCPeerID *peerID);


@interface NCMCAlertView : UIAlertView
@property(nonatomic, copy) NCMCPeerID* target;
@property(nonatomic, copy) MyInvitationHandler handler;
@end
