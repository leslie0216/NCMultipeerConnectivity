//
//  ChatRoomScene.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-29.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "ChatRoomScene.h"
#import "MultiplayerController.h"
#import "Parameters.h"

@implementation ChatRoomScene
{
    CCTextField* tfMsg;
    CCButton* btnSendTo1;
    CCButton* btnSendTo2;
    CCButton* btnSendTo3;
    CCLabelTTF* lbPlayer1;
    CCLabelTTF* lbPlayer2;
    CCLabelTTF* lbPlayer3;
    CCLabelTTF* lbChat;
    CCLabelTTF* lbPlayerLocal;
}

-(void)didLoadFromCCB
{
    [self resetUI];
    lbChat.string = @"";
}

-(void)onEnter
{
    [super onEnter];
    [self resetUI];
    lbChat.string = @"";;
    [self setPlayerList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedMessageWithNotification:)
                                                 name:RECEIVED_MESSAGE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatePlayerlistWithNotification:)
                                                 name:UPDATE_PLAYERLIST_NOTIFICATION
                                               object:nil];
}

-(void)onExit
{
    [super onExit];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)resetUI
{
    lbPlayer1.color = [CCColor darkGrayColor];
    lbPlayer1.string = @"--empty--";
    btnSendTo1.enabled = NO;
    lbPlayer2.color = [CCColor darkGrayColor];
    lbPlayer2.string = @"--empty--";
    btnSendTo2.enabled = NO;
    lbPlayer3.color = [CCColor darkGrayColor];
    lbPlayer3.string = @"--empty--";
    btnSendTo3.enabled = NO;
}

-(void)setPlayerList
{
    NSArray* playerData = [[MultiplayerController instance] currentSessionPlayerIDs];
    
    int i = 0;
    NSString* localName = [[MultiplayerController instance]localName];
    for(NCMCPeerID* pd in playerData) {
        if( i < 3 && ![localName isEqualToString:[self stringForMCPeerDisplayName:[pd getDisplayName]]]) {
            if (i == 0) {
                lbPlayer1.string = [self stringForMCPeerDisplayName:[pd getDisplayName]];
                lbPlayer1.color = [CCColor whiteColor];
                btnSendTo1.enabled = YES;
            }
            
            if (i == 1) {
                lbPlayer2.string = [self stringForMCPeerDisplayName:[pd getDisplayName]];
                lbPlayer2.color = [CCColor whiteColor];
                btnSendTo2.enabled = YES;
            }
            
            if (i == 2) {
                lbPlayer3.string = [self stringForMCPeerDisplayName:[pd getDisplayName]];
                lbPlayer3.color = [CCColor whiteColor];
                btnSendTo3.enabled = YES;
            }
            
            i++;
        }
    }
    
    lbPlayerLocal.string = localName;
}

-(void)onMsgEntered:(id)sender
{

}

-(void)onBtnSendTo1
{
    NSString* msg = tfMsg.string;
    if (msg.length > 0) {
        NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [[MultiplayerController instance] sendData:data to:lbPlayer1.string withMode:NCMCSessionSendDataUnreliable];
    }
}

-(void)onBtnSendTo2
{
    NSString* msg = tfMsg.string;
    if (msg.length > 0) {
        NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [[MultiplayerController instance] sendData:data to:lbPlayer2.string withMode:NCMCSessionSendDataUnreliable];
    }
}

-(void)onBtnSendTo3
{
    NSString* msg = tfMsg.string;
    if (msg.length > 0) {
        NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [[MultiplayerController instance] sendData:data to:lbPlayer3.string withMode:NCMCSessionSendDataUnreliable];
    }
}

- (void)handleReceivedMessageWithNotification:(NSNotification *)notification
{
    NSData* msgData = [[notification userInfo] objectForKey:@"message"];
    NSString* msg = [[NSString alloc]initWithData:msgData encoding:NSUTF8StringEncoding];
    NSString* name = [[notification userInfo] objectForKey:@"name"];
    NSString* status = [NSString stringWithFormat:@"\n%@ : %@", name, msg];
    lbChat.string = [lbChat.string stringByAppendingString:status];
}

- (void)handleUpdatePlayerlistWithNotification:(NSNotification *)notification
{
    [self resetUI];
    [self setPlayerList];
}

- (NSString*) stringForMCPeerDisplayName:(NSString*)displayName {
    if([displayName length] > 2) {
        NSString* realDisplayName = [displayName substringFromIndex:2];
        return realDisplayName;
    }
    return @"Unknown Player";
    
}

@end
