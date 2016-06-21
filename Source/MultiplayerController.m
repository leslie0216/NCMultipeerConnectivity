//
//  MultiplayerController.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "MultiplayerController.h"

@implementation MultiplayerController
{
    NSString *displayName;
}

static MultiplayerController *_sharedMultiplayerController = nil;

+ (MultiplayerController *)instance {
    
    @synchronized(self) {
        
        if (_sharedMultiplayerController == nil) {
            _sharedMultiplayerController = [[MultiplayerController alloc] init];
        }
    }
    
    return _sharedMultiplayerController;
}

-(void)setMultiplayerDisplayName:(NSString *)name
{
    displayName = name;
}

-(void)initializeControllerForNewMatch
{
    
}

-(void)joinServerHostedGame
{
    [self initializeControllerForNewMatch];
}

-(void)createServerHostedGame
{
    [self initializeControllerForNewMatch];
}


@end
