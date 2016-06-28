//
//  LoginScene.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "LoginScene.h"
#import "Parameters.h"
#import "MultiplayerController.h"

@implementation LoginScene
{
    CCButton* btnStart;
    CCTextField* tfUserName;
    CCLabelTTF* lbWarninng;
}

-(void)didLoadFromCCB
{
    btnStart.enabled = NO;
    lbWarninng.string = [NSString stringWithFormat:@"The length of user name must be\nbetween %d and %d letters", MIN_USERNAME_LENGTH, MAX_USERNAME_LENGTH];
    lbWarninng.visible = NO;
}

-(void)onBtnStartClicked
{
    CCLOG(@"name = %@", tfUserName.string);

    [[MultiplayerController instance] setLocalName:tfUserName.string];
    
    CCScene *serverClientScene = [CCBReader loadAsScene:@"SettingScene"];
    [[CCDirector sharedDirector] replaceScene:serverClientScene];
}

-(void)onUserNameEntered:(id)sender
{
    if (tfUserName.string.length >= MIN_USERNAME_LENGTH && tfUserName.string.length <= MAX_USERNAME_LENGTH) {
        btnStart.enabled = YES;
        lbWarninng.visible = NO;
    } else {
        btnStart.enabled = NO;
        lbWarninng.visible = YES;
    }
}

@end

