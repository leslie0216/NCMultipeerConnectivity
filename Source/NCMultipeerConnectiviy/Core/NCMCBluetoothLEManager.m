//
//  NCMCBluetoothLEManager.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-21.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "NCMCBluetoothLEManager.h"
#import "NCMCMessageData.h"

@interface NCMCBluetoothLEManager()
{
    NSMutableArray<NCMCMessageData*> *recMsgArray;
    
    // central
    NSMutableArray<NCMCMessageData*> *centralDataToSend;
    
    // peripheral
    BOOL isConnectedToCentral;
    NSMutableArray<NSData*> *peripheralDataToSend;
    CBCentral *centralDevice;
}

@property (nonatomic, strong) dispatch_queue_t concurrentChatDelegateQueue;
@property (nonatomic, strong) dispatch_queue_t serialDataSendingQueue;


// central properties
@property (strong, nonatomic) CBCentralManager *centralManager;
//@property (strong, nonatomic) NSMutableDictionary<NSString*, PeripheralInfo*> *discoveredPeripherals; // key:UUIDString value:PeripheralInfo

// peripheral properties
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *sendCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *receiveCharacteristic;

@end

@implementation NCMCBluetoothLEManager

@synthesize isCentral, session, concurrentChatDelegateQueue, serialDataSendingQueue, centralManager, peripheralManager, sendCharacteristic, receiveCharacteristic;

static NCMCBluetoothLEManager *_sharedNCMCBluetoothLEManager = nil;

+ (NCMCBluetoothLEManager *)instance {
    
    @synchronized(self) {
        
        if (_sharedNCMCBluetoothLEManager == nil) {
            _sharedNCMCBluetoothLEManager = [[NCMCBluetoothLEManager alloc] init];
        }
    }
    
    return _sharedNCMCBluetoothLEManager;
}

@end
