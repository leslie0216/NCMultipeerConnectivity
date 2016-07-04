//
//  MultiplayerController.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCMultipeerConnectiviy/NCMCSession.h"
#import "NCMultipeerConnectiviy/NCMCCentralService.h"
#import "NCMultipeerConnectiviy/NCMCPeripheralService.h"

@interface MultiplayerController : NSObject<NCMCSessionDelegate, NCMCCentralServiceDelegate, NCMCPeripheralServiceDelegate, UIAlertViewDelegate>

@property(strong, nonatomic) NCMCSession* currentSession;
@property(strong, nonatomic) NCMCCentralService* currentCentralService;
@property(strong, nonatomic) NCMCPeripheralService* currentPeripheralService;
@property(strong, nonatomic) NSMutableArray* currentSessionPlayerIDs;

@property(assign, nonatomic) Boolean isHost;
@property(strong, nonatomic) NSString *localName;

+ (MultiplayerController *) instance;

- (void) initializeControllerForNewMatch;
- (void) createServerHostedGame;
- (void) joinServerHostedGame;
- (void) disconnect;
-(void) startHost;
-(void) startClient;

-(void)sendData:(NSData*)data to:(NSString*)name  withMode:(NCMCSessionSendDataMode)mode;
-(void)gotoChatRoom;

@end
