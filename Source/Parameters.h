//
//  Parameters.h
//  NetworkTest
//
//  Created by Chengzhao Li on 2016-03-29.
//  Copyright © 2016 Apportable. All rights reserved.
//

#ifndef Parameters_h
#define Parameters_h

typedef enum GameStates {
    INGAME = 0,
    WIN = 1,
    LOSE = 2,
    DRAW = 3,
    NONE = 4
} GameStates;

typedef enum T3MessageType {
    MSG_PLAYER_DATA = 0,
    MSG_SERVER_CLIENT_GO_TO_GAME = 1,
    MSG_CLIENT_SERVER_SCENE_LOADED = 2,
    MSG_SERVER_CLIENT_START_NEW_GAME = 3,
    MSG_SERVER_CLIENT_PLAYER_MOVE = 4,
    MSG_CLIENT_SERVER_MOVE_ACTION = 5,
    MSG_SERVER_CLIENT_GAME_FINISHED = 6,
    MSG_SERVER_CLIENT_GAME_DRAW = 7,
    MSG_SERVER_CLIENT_SWITCH_PLAYER = 8,
    
} T3MessageType;

#define SERVER_CLIENT_DID_NOT_START_NOTIFICATION @"NoodlecakeT3_DidNotStartServerClientNotification"
#define SERVER_DID_FOUND_CLIENT_NOTIFICATION @"NoodlecakeT3_DidFoundClientNotification"
#define CLINET_DID_FOUND_SERVER_NOTIFICATION @"NoodlecakeT3_DidFoundServerNotification"
#define SERVER_CLIENT_CONNECTION_DONE_NOTIFICATION @"NoodlecakeT3_DidConnectionDoneNotification"
#define CONNECTION_STATE_CHANGED_NOTIFICATION @"NoodlecakeT3_DidChangeConnectionStateNotification"

#define REMOTE_INFO_UP_TO_DATE @"NoodlecakeT3_DidRemoteInfoUpToDateNotification"

#define RECEIVED_DATA_NOTIFICATION @"NoodlecakeT3_DidReceiveDataNotification"

#define GAMEMANAGER_READY_TO_NEW_GAME @"NoodlecakeT3_GameManagerReadyToNewGame"
#define GAMEMANAGER_START_NEW_GAME @"NoodlecakeT3_GameManagerStartNewGame"
#define GAMEMANAGER_PLAYER_MOVE @"NoodlecakeT3_GameManagerPlayerMove"
#define GAMEMANAGER_GAME_FINISHED @"NoodlecakeT3_GameManagerGameFinished"
#define GAMEMANAGER_GAME_DRAW @"NoodlecakeT3_GameManagerGameDraw"
#define GAMEMANAGER_SWITCH_PLAYER @"NoodlecakeT3_GameManagerSwithPlayer"

#define TRANSFER_SERVICE_UUID           @"7CFA5442-3C3E-4522-902C-B347C1957515"
#define TRANSFER_CHARACTERISTIC_MSG_FROM_PERIPHERAL_UUID    @"446EF5DD-3E31-40DA-897F-22C31065C861"
#define TRANSFER_CHARACTERISTIC_MSG_FROM_CENTRAL_UUID    @"88376596-5F9F-4923-A30C-D17044687B53"

#define TAG_HEAD 0
#define TAG_BODY 1
#define TAG_PING_RESPONSE 3
typedef int64_t HEADER_TYPE;

#define MAX_USERNAME_LENGTH 8
#define MIN_USERNAME_LENGTH 3
#define GRID_SIZE 3
#define X_IMAGE @"T3Assets/x-piece.png"
#define O_IMAGE @"T3Assets/o-piece.png"
#define EMPTY_IMAGE @"T3Assets/blank-piece.png"

#define SCREEN_HEIGHT ([CCDirector sharedDirector].viewSize.height)
#define SCREEN_WIDTH ([CCDirector sharedDirector].viewSize.width)

#define MSG_BUFFER_SIZE 3000
static char msgBuffer[MSG_BUFFER_SIZE];

#endif /* Parameters_h */
