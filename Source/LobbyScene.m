#import "LobbyScene.h"
#import "MultiplayerController.h"
#import "NCMultipeerConnectiviy/NCMCPeerID.h"
#import "Parameters.h"

@implementation LobbyScene
{
    CCLabelTTF* lbMsg;
    CCLabelTTF* lbPlayer1;
    CCLabelTTF* lbPlayer2;
    CCLabelTTF* lbPlayer3;
    CCLabelTTF* lbPlayer4;
    CCButton* btnStart;
    CCButton* btnBack;
}

-(void)didLoadFromCCB
{
    [self resetUI];
}

-(void) onEnter {
    [super onEnter];
    if ([[MultiplayerController instance] isHost]) {
        [[MultiplayerController instance] startHost];

    } else {
        [[MultiplayerController instance]startClient];

    }
    [self schedule: @selector(tickMe:) interval:1.0/1.0];
}

-(void) onExit {
    [super onExit];
    [self unschedule:@selector(tickMe:)];
}

-(void)onBack
{
    CCLOG(@"onBtnBackClicked");
    
    [self disconnectAndBack];
}

-(void)onStart
{
    CCLOG(@"onBtnStartClicked");
    [[MultiplayerController instance] gotoChatRoom];
}

-(void)disconnectAndBack
{    
    [[MultiplayerController instance] disconnect];
    
    CCScene *serverClientScene = [CCBReader loadAsScene:@"SettingScene"];
    [[CCDirector sharedDirector] replaceScene:serverClientScene];
}

-(void)resetUI
{
    if ([[MultiplayerController instance] isHost]) {
        lbMsg.string = @"Waiting for player...";
        lbPlayer1.color = [CCColor whiteColor];
        lbPlayer1.string = [[MultiplayerController instance] localName];
        lbPlayer2.color = [CCColor darkGrayColor];
        lbPlayer2.string = @"--empty--";
        lbPlayer3.color = [CCColor darkGrayColor];
        lbPlayer3.string = @"--empty--";
        lbPlayer4.color = [CCColor darkGrayColor];
        lbPlayer4.string = @"--empty--";
        btnStart.enabled = NO;
        btnBack.enabled = YES;
        
    } else {
        lbMsg.string = @"Searching for game...";
        lbPlayer1.color = [CCColor darkGrayColor];
        lbPlayer1.string = @"--empty--";
        lbPlayer2.color = [CCColor darkGrayColor];
        lbPlayer2.string = @"--empty--";
        lbPlayer3.color = [CCColor darkGrayColor];
        lbPlayer3.string = @"--empty--";
        lbPlayer4.color = [CCColor darkGrayColor];
        lbPlayer4.string = @"--empty--";
        btnStart.enabled = NO;
        btnStart.visible = NO;
        btnBack.position = ccp(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.195);
    }
}

-(void) tickMe: (CCTime) dt
{
    [self resetUI];
    
    NSArray* playerData = [[MultiplayerController instance] currentSessionPlayerIDs];
    
    int i = 0;
    for(NCMCPeerID* pd in playerData) {
        if( i < 4) {
            if (i == 0) {
                lbPlayer1.string = [pd getDisplayName];
                lbPlayer1.color = [CCColor whiteColor];
            }
            
            if (i == 1) {
                lbPlayer2.string = [pd getDisplayName];
                lbPlayer2.color = [CCColor whiteColor];
            }
            
            if (i == 2) {
                lbPlayer3.string = [pd getDisplayName];
                lbPlayer3.color = [CCColor whiteColor];
            }
            
            if (i == 3) {
                lbPlayer4.string = [pd getDisplayName];
                lbPlayer4.color = [CCColor whiteColor];
            }
        }
        i++;
    }
    if(i >= 2) {
        lbMsg.string = @"Ready to game";
        if ([[MultiplayerController instance] isHost]) {
            btnStart.enabled = YES;
        }
    }
    else if(i < 2) {
        if ([[MultiplayerController instance] isHost]) {
            btnStart.enabled = NO;
        }
    }
    
}

@end
