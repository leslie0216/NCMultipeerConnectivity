//
//  Parameters.h
//  NetworkTest
//
//  Created by Chengzhao Li on 2016-03-29.
//  Copyright © 2016 Apportable. All rights reserved.
//

#ifndef Parameters_h
#define Parameters_h

typedef enum ChatAppMessageType {
    MSG_SERVER_CLIENT_GO_TO_CHAT = 0,
    MSG_CHAT_MSG = 1,
} ChatAppMessageType;

#define TRANSFER_SERVICE_UUID           @"ABE00C6E-58F1-44B2-BE41-20E66874B97D"
#define TRANSFER_CHARACTERISTIC_MSG_FROM_PERIPHERAL_UUID    @"446EF5DD-3E31-40DA-897F-22C31065C861"
#define TRANSFER_CHARACTERISTIC_MSG_FROM_CENTRAL_UUID    @"88376596-5F9F-4923-A30C-D17044687B53"

#define TAG_HEAD 0
#define TAG_BODY 1
#define TAG_PING_RESPONSE 3
typedef int64_t HEADER_TYPE;

#define MAX_USERNAME_LENGTH 8
#define MIN_USERNAME_LENGTH 3

#define MaxPingCount 1
#define MessageSizeForPackageRate 90

#define SCREEN_HEIGHT ([CCDirector sharedDirector].viewSize.height)
#define SCREEN_WIDTH ([CCDirector sharedDirector].viewSize.width)

#define MSG_BUFFER_SIZE 3000
static char msgBuffer[MSG_BUFFER_SIZE];

#define RECEIVED_MESSAGE_NOTIFICATION @"NoodlecakeNCMC_DidReceiveMessageNotification"
#define UPDATE_PLAYERLIST_NOTIFICATION @"NoodlecakeNCMC_DidUpdatePlayerlistNotification"

#endif /* Parameters_h */
