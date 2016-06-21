//
//  MultiplayerController.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiplayerController : NSObject

+ (MultiplayerController *) instance;

-(void)setMultiplayerDisplayName:(NSString*)name;

// SETUP FUNCS
- (void) initializeControllerForNewMatch;
- (void) createServerHostedGame;
- (void) joinServerHostedGame;

@end
