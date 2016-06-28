//
//  Parameters.h
//  NetworkTest
//
//  Created by Chengzhao Li on 2016-03-29.
//  Copyright © 2016 Apportable. All rights reserved.
//

#ifndef Parameters_h
#define Parameters_h

#define TRANSFER_SERVICE_UUID           @"ABE00C6E-58F1-44B2-BE41-20E66874B97D"
#define TRANSFER_CHARACTERISTIC_MSG_FROM_PERIPHERAL_UUID    @"446EF5DD-3E31-40DA-897F-22C31065C861"
#define TRANSFER_CHARACTERISTIC_MSG_FROM_CENTRAL_UUID    @"88376596-5F9F-4923-A30C-D17044687B53"

#define TAG_HEAD 0
#define TAG_BODY 1
#define TAG_PING_RESPONSE 3
typedef int64_t HEADER_TYPE;

#define MAX_USERNAME_LENGTH 8
#define MIN_USERNAME_LENGTH 3


#define SCREEN_HEIGHT ([CCDirector sharedDirector].viewSize.height)
#define SCREEN_WIDTH ([CCDirector sharedDirector].viewSize.width)


#endif /* Parameters_h */
