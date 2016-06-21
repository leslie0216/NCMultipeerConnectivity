//
//  NCMCBluetoothLEManager.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-21.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "NCMCSession+Core.h"
#import "NCMCCentralService+Core.h"
#import "NCMCPeripheralService+Core.h"


@interface NCMCBluetoothLEManager : NSObject

@property (assign, nonatomic)Boolean isCentral;
@property (strong, nonatomic)NCMCSession* session;

+(NCMCBluetoothLEManager *)instance;

-(void)disconnect;

@end
