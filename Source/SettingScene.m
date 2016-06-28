//
//  SettingScene.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "SettingScene.h"
#import "MultiplayerController.h"

@implementation SettingScene

-(void)onHost
{
    CCLOG(@"onHost");
    
    [[MultiplayerController instance] createServerHostedGame];
    
    CCScene *lobbyScene = [CCBReader loadAsScene:@"LobbyScene"];
    [[CCDirector sharedDirector] replaceScene:lobbyScene];
}

-(void)onJoin
{
    CCLOG(@"onJoin");
    
    [[MultiplayerController instance]joinServerHostedGame];
    
    CCScene *lobbyScene = [CCBReader loadAsScene:@"LobbyScene"];
    [[CCDirector sharedDirector] replaceScene:lobbyScene];
}

-(void)onBack
{
    CCLOG(@"onBack");
    
    CCScene *loginScene = [CCBReader loadAsScene:@"LoginScene"];
    [[CCDirector sharedDirector] replaceScene:loginScene];
}

@end
