//
//  NCMCSession.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-20.
//  Copyright © 2016 Apportable. All rights reserved.
//

//#import "NCMCSession.h"
#import "Core/NCMCBluetoothLEManager.h"
#import "Core/NCMCSession+Core.h"
#import "Core/NCMCPeerID+Core.h"

typedef enum NCMCSystemMessageType {
    PERIPHERAL_CENTRAL_REFUSE_INVITATION = 0,
    PERIPHERAL_CENTRAL_ACCEPT_INVITATION = 1,
    CENTRA_PERIPHERAL_CONNECTION_REQUEST = 2,
    CENTRA_PERIPHERAL_ASSIGN_IDENTIFIER = 3,
    CENTRA_PERIPHERAL_DEVICE_CONNECTED = 4,
    CENTRA_PERIPHERAL_DEVICE_DISCONNECTED = 5,
} NCMCSystemMessageType;

@implementation NCMCSession

@synthesize serviceID, myPeerID;

-(instancetype)initWithPeer:(NCMCPeerID*)peerID  andServiceID:(NSString*)sid
{
    self = [super init];
    
    if (self) {
        self.serviceID = sid;
        self.myPeerID = peerID;
        self.myUniqueID = 0;
        self.connectedDevices = [[NSMutableDictionary alloc]init];
        [self configBluetoothManger];
    }
    
    return self;
}

-(void)disconnect
{
    [[NCMCBluetoothLEManager instance] disconnect];
    [self.connectedDevices removeAllObjects];
}

-(void)sendData:(NSData *)data toPeers:(NSArray<NCMCPeerID *> *)peerIDs
{
    for (NCMCPeerID* peerID in peerIDs) {
        NSData* msg = [self packUserMessage:data withTargetPeerID:peerID];
        if ([[NCMCBluetoothLEManager instance]isCentral]) {
            [[NCMCBluetoothLEManager instance] sendCentralData:msg toPerihperal:peerID.identifier];
        } else {
            [[NCMCBluetoothLEManager instance] sendPeriheralData:msg toCentral: [self getCentralDeviceIdentifier]];
        }
    }
}

-(void)notifyPeerStateChanged:(NCMCPeerID *)peerID newState:(NCMCSessionState)state
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(session:peer:didChangeState:)]) {
        [self.delegate session:self peer:peerID didChangeState:state];
    }
}

-(void)notifyDidReceiveData:(NSData *)data fromPeer:(NCMCPeerID *)peerID
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(session:didReceiveData:fromPeer:)]) {
        [self.delegate session:self didReceiveData:data fromPeer:peerID];
    }
}

-(void)onPeriphearalDisconnected:(NSString *)identifier
{
    NCMCDeviceInfo *info = self.connectedDevices[identifier];
    if (info != nil) {
        // notify this device
        NCMCPeerID *peerID= [[NCMCPeerID alloc]initWithDisplayName:info.name andIdentifier:identifier];
        [self notifyPeerStateChanged:peerID newState:NCMCSessionStateNotConnected];
        
        // if central notify all periherals
        if ([[NCMCBluetoothLEManager instance] isCentral]) {
            NSData* deviceData = [self encodeDeviceInfo:info];
            NSData* sysData = [self packSystemMessageWithType:CENTRA_PERIPHERAL_DEVICE_DISCONNECTED andMessage:deviceData];
            
            NSEnumerator *enmuerator = [self.connectedDevices objectEnumerator];
            
            for (NCMCDeviceInfo *info in enmuerator) {
                if (info.uniqueID != 0) {
                    [[NCMCBluetoothLEManager instance] sendCentralData:sysData toPerihperal:info.identifier];
                }
            }
        }
    }
    
    [self.connectedDevices removeObjectForKey:identifier];
}

-(void)onCentralDisconnected
{
    NSEnumerator *enmuerator = [self.connectedDevices objectEnumerator];
    
    for (NCMCDeviceInfo *info in enmuerator) {
        if (![info.identifier isEqualToString:self.myPeerID.identifier] ) {
            NCMCPeerID *peerID= [[NCMCPeerID alloc]initWithDisplayName:info.name andIdentifier:info.identifier];
            [self notifyPeerStateChanged:peerID newState:NCMCSessionStateNotConnected];
        }
    }
    
    [self.connectedDevices removeAllObjects];
}

-(void)configBluetoothManger
{
    // clear manager first
    [[NCMCBluetoothLEManager instance] clear];

    // set current session
    [NCMCBluetoothLEManager instance].session = self;
}

-(void)setSelfAsCentral
{
    if (self.connectedDevices != nil) {
        [self.connectedDevices removeAllObjects];
    } else {
        self.connectedDevices = [[NSMutableDictionary alloc]init];
    }
    
    self.myUniqueID = 0;
    
    /*
    NCMCDeviceInfo* centralDevice = [[NCMCDeviceInfo alloc]init];
    centralDevice.identifier = self.myPeerID.identifier;
    centralDevice.uniqueID = 0;
    centralDevice.name = [self.myPeerID displayName];
    
    self.connectedDevices[self.myPeerID.identifier] = centralDevice;*/
}

-(NSData*)packSystemMessageWithType:(char)msgType andMessage:(NSData*)msg
{
    NSUInteger len = [msg length];
    char msgBuffer[len+2];
    char* target = msgBuffer;
    msgBuffer[0] = 1; // system message
    msgBuffer[1] = msgType;
    target++;
    target++;
    
    if(msg == nil) {
        // this message has no content
        return [NSData dataWithBytes:msgBuffer length:2];
    }
    
    memcpy(target, [msg bytes], len);
    
    return [NSData dataWithBytes:msgBuffer length:len+2];
}

-(NSData*)packUserMessage:(NSData*)msg withTargetPeerID:(NCMCPeerID*)peerID
{
    NCMCDeviceInfo* targetDevice = self.connectedDevices[peerID.identifier];
    if (targetDevice != nil) {
        NSUInteger len = [msg length];
        char msgBuffer[len+2];
        char* target = msgBuffer;
        msgBuffer[0] = 0; // user message
        msgBuffer[1] = targetDevice.uniqueID;
        target++;
        target++;
        
        if(msg == nil) {
            // this message has no content
            return [NSData dataWithBytes:msgBuffer length:2];
        }
        
        memcpy(target, [msg bytes], len);
        
        return [NSData dataWithBytes:msgBuffer length:len+2];
    }
    
    return nil;
}

-(NCMCDeviceInfo *)decodeDeviceInfo:(NSData*)data
{
    NCMCDeviceInfo* deviceInfo = [[NCMCDeviceInfo alloc]init];
    
    char* dataPointer = (char*)[data bytes];
    NSUInteger dataLength = [data length];

    NSData* identifierData = [NSData dataWithBytes:dataPointer length:36];
    deviceInfo.identifier = [[NSString alloc]initWithData:identifierData encoding:NSUTF8StringEncoding];
    
    deviceInfo.uniqueID = (char)dataPointer[36];
    
    dataPointer+=37;
    NSData* nameData = [NSData dataWithBytes:dataPointer length:dataLength-37];;
    deviceInfo.name = [[NSString alloc]initWithData:nameData encoding:NSUTF8StringEncoding];
    
    return deviceInfo;
}

-(NSData*)encodeDeviceInfo:(NCMCDeviceInfo *)info
{
    NSUInteger len = [info.identifier length] + [info.name length] + 1;
    char targetBuffer[len];
    char* target = targetBuffer;

    
    memcpy(target, [info.identifier UTF8String], [info.identifier length]);

    target[36] = info.uniqueID;
    target += 37;
    
    memcpy(target, [info.name UTF8String], [info.name length]);
    
    return [NSData dataWithBytes:targetBuffer length:len];
}

-(void)sendCentralConnectionRequestToPeer:(NCMCPeerID *)peerID
{
    //NCMCDeviceInfo* centralDevice = self.connectedDevices[self.myPeerID.identifier];
    NCMCDeviceInfo* centralDevice = [[NCMCDeviceInfo alloc]init];
    centralDevice.identifier = self.myPeerID.identifier;
    centralDevice.uniqueID = 0;
    centralDevice.name = [self.myPeerID displayName];
    
    NSData* centralDeviceData = [self encodeDeviceInfo:centralDevice];
    
    NSData* sysData = [self packSystemMessageWithType:CENTRA_PERIPHERAL_CONNECTION_REQUEST andMessage:centralDeviceData];
    
    [[NCMCBluetoothLEManager instance] sendCentralData:sysData toPerihperal:peerID.identifier];
}

void(^myInvitationHandler)(BOOL, NCMCSession*, NCMCPeerID*) = ^(BOOL accept, NCMCSession* session, NCMCPeerID *peerID) {
    if(accept){
        // send accept to central and wait for assign id
        NCMCDeviceInfo* device = [[NCMCDeviceInfo alloc]init];
        device.identifier = session.myPeerID.identifier;
        device.uniqueID = 0;
        device.name = session.myPeerID.displayName;
        
        NSData* deviceData = [session encodeDeviceInfo:device];
        
        NSData* sysData = [session packSystemMessageWithType:PERIPHERAL_CENTRAL_ACCEPT_INVITATION andMessage:deviceData];
        
        [[NCMCBluetoothLEManager instance] sendPeriheralData:sysData toCentral:peerID.identifier];
        
        // clear and init local connected information
        NCMCDeviceInfo* centralDevice = [[NCMCDeviceInfo alloc]init];
        centralDevice.identifier = peerID.identifier;
        centralDevice.uniqueID = 0;
        centralDevice.name = peerID.displayName;
        
        if ([session connectedDevices] != nil) {
            [[session connectedDevices]removeAllObjects];
            [[session connectedDevices] setObject:centralDevice forKey:peerID.identifier];
        }
        
    } else {
        // send refuse to central
        NSData* sysData = [session packSystemMessageWithType:PERIPHERAL_CENTRAL_REFUSE_INVITATION andMessage:nil];
        
        [[NCMCBluetoothLEManager instance] sendPeriheralData:sysData toCentral:peerID.identifier];
        
        // remove central device from local
        [session.connectedDevices removeObjectForKey:peerID.identifier];
    }
};

-(void)onDataReceived:(NSData *)data from:(NSString *)identifier
{
    char* dataPointer = (char*)[data bytes];
    NSUInteger dataLength = [data length];
    BOOL isSysMsg = (BOOL)dataPointer[0];
    char extraInfo = (char)dataPointer[1];
    dataPointer++;
    dataPointer++;
    
    NSData* dataMsg = [NSData dataWithBytes:dataPointer length:dataLength-2];
    
    if (isSysMsg) {

        switch (extraInfo) {
            case PERIPHERAL_CENTRAL_REFUSE_INVITATION:
            {
                // disconnect to peripheral
                if ([[NCMCBluetoothLEManager instance] isCentral]) {
                    [[NCMCBluetoothLEManager instance] disconnectToPeripheral:identifier];
                    [self.connectedDevices removeObjectForKey:identifier]; // may be we dont need to do this
                }
                break;
            }
            case PERIPHERAL_CENTRAL_ACCEPT_INVITATION:
            {
                // assign peripheral info to peripheral
                NCMCDeviceInfo* peripheralDevice = [self decodeDeviceInfo:dataMsg];
                peripheralDevice.identifier = identifier;
                peripheralDevice.uniqueID = (char)[self.connectedDevices count] + 1; // id 0 is reserved for central
                
                NSData* deviceData = [self encodeDeviceInfo:peripheralDevice];
                
                NSData* sysData = [self packSystemMessageWithType:CENTRA_PERIPHERAL_ASSIGN_IDENTIFIER andMessage:deviceData];
                
                [[NCMCBluetoothLEManager instance] sendCentralData:sysData toPerihperal:identifier];
                
                // update new connected device info to all connected periherals
                NSData* sysBroadcastNewDeviceData = [self packSystemMessageWithType:CENTRA_PERIPHERAL_DEVICE_CONNECTED andMessage:deviceData];
                for (NSString *key in self.connectedDevices) {
                    NCMCDeviceInfo* peripheralDeviceInfo = self.connectedDevices[key];
                    if (peripheralDeviceInfo.uniqueID != 0) {
                        [[NCMCBluetoothLEManager instance] sendCentralData:sysBroadcastNewDeviceData toPerihperal:peripheralDeviceInfo.identifier];
                    }
                }
                
                // update all connected periherals to new connected device
                for (NSString *key in self.connectedDevices) {
                    NCMCDeviceInfo* peripheralDeviceInfo = self.connectedDevices[key];
                    if (peripheralDeviceInfo.uniqueID != 0) {
                        NSData* peripheralDeviceData = [self encodeDeviceInfo:peripheralDeviceInfo];
                        NSData* sysBroadcastData = [self packSystemMessageWithType:CENTRA_PERIPHERAL_DEVICE_CONNECTED andMessage:peripheralDeviceData];
                        [[NCMCBluetoothLEManager instance] sendCentralData:sysBroadcastData toPerihperal:identifier];
                    }
                }
                
                self.connectedDevices[identifier] = peripheralDevice;
                
                // send connection status notification
                NCMCPeerID* peerID = [[NCMCPeerID alloc]initWithDisplayName:peripheralDevice.name andIdentifier:peripheralDevice.identifier];
                
                [self notifyPeerStateChanged:peerID newState:NCMCSessionStateConnected];

                break;
            }
            case CENTRA_PERIPHERAL_CONNECTION_REQUEST:
            {
                if (![[self getCentralDeviceIdentifier] isEqualToString:@""]) {
                    // refuse connection directly when another central is being processed
                    NSData* sysData = [self packSystemMessageWithType:PERIPHERAL_CENTRAL_REFUSE_INVITATION andMessage:nil];
                    
                    [[NCMCBluetoothLEManager instance] sendPeriheralData:sysData toCentral:identifier];
                    
                }
                
                NCMCDeviceInfo* centralDevice = [self decodeDeviceInfo:dataMsg];
                
                if (centralDevice.uniqueID == 0) {
                    centralDevice.identifier = identifier; // set with its real identifier
                }
                
                // save central device
                self.connectedDevices[centralDevice.identifier] = centralDevice;
                
                NCMCPeerID* peerID = [[NCMCPeerID alloc]initWithDisplayName:centralDevice.name andIdentifier:centralDevice.identifier];
                
                // broadcast invitation
                [[[NCMCBluetoothLEManager instance] peripheralService] notifyDidReceiveInvitationFromPeer:peerID invitationHandler:myInvitationHandler];
                
                break;
            }
            case CENTRA_PERIPHERAL_ASSIGN_IDENTIFIER:
            {
                NCMCDeviceInfo* device = [self decodeDeviceInfo:dataMsg];
                if ([device.name isEqualToString:self.myPeerID.displayName]) {
                    self.myPeerID.identifier = device.identifier;
                    self.myUniqueID = device.uniqueID;
                    
                    // add self to connected dict, do we?
                    //self.connectedDevices[device.identifier] = device;
                    
                    // send central connection status notification
                    NCMCDeviceInfo* centralDevice = [self getDeviceInfoByUniqueID:0];
                    NCMCPeerID* peerID = [[NCMCPeerID alloc]initWithDisplayName:centralDevice.name andIdentifier:centralDevice.identifier];
                    
                    [self notifyPeerStateChanged:peerID newState:NCMCSessionStateConnected];
                }
                
                break;
            }
            case CENTRA_PERIPHERAL_DEVICE_CONNECTED:
            {
                NCMCDeviceInfo* device = [self decodeDeviceInfo:dataMsg];
                
                // we've already added central device
                if (device.uniqueID != 0 && ![device.identifier isEqualToString:self.myPeerID.identifier]) {
                    self.connectedDevices[device.identifier] = device;
                    
                    // send connection status notification
                    NCMCPeerID* peerID = [[NCMCPeerID alloc]initWithDisplayName:device.name andIdentifier:device.identifier];
                    
                    [self notifyPeerStateChanged:peerID newState:NCMCSessionStateConnected];
                }
                break;
            }
            case CENTRA_PERIPHERAL_DEVICE_DISCONNECTED:
            {
                NCMCDeviceInfo* device = [self decodeDeviceInfo:dataMsg];
                if (self.connectedDevices[device.identifier] != nil) {
                    
                    [self.connectedDevices removeObjectForKey:device.identifier];
                    
                    // send connection status notification
                    NCMCPeerID* peerID = [[NCMCPeerID alloc]initWithDisplayName:device.name andIdentifier:device.identifier];
                    
                    [self notifyPeerStateChanged:peerID newState:NCMCSessionStateNotConnected];
                }
                break;
            }
        }
    } else {
        if ([[NCMCBluetoothLEManager instance] isCentral]) {
            if (extraInfo == 0) {
                // data from peripheral to central
                NCMCDeviceInfo *deviceInfo = self.connectedDevices[identifier];
                NCMCPeerID *peerID = [[NCMCPeerID alloc]initWithDisplayName:deviceInfo.name andIdentifier:identifier];
                [self notifyDidReceiveData:dataMsg fromPeer:peerID];
            } else {
                // data from peripheral to peripheral
                NCMCDeviceInfo* targetDevice = [self getDeviceInfoByUniqueID:extraInfo];
                if (targetDevice != nil) {
                    [[NCMCBluetoothLEManager instance] sendCentralData:data toPerihperal:targetDevice.identifier];
                }
            }
        } else {
            if (self.myUniqueID == extraInfo) {
                NCMCDeviceInfo *deviceInfo = self.connectedDevices[identifier];
                NCMCPeerID *peerID = [[NCMCPeerID alloc]initWithDisplayName:deviceInfo.name andIdentifier:identifier];
                [self notifyDidReceiveData:dataMsg fromPeer:peerID];
            }
        }
    }
}

-(NCMCDeviceInfo*)getDeviceInfoByUniqueID:(char)uniqueID{
    for (NSString *key in self.connectedDevices) {
        if (self.connectedDevices[key].uniqueID == uniqueID) {
            return self.connectedDevices[key];
            break;
        }
    }
    
    return nil;
}

-(NSString*)getCentralDeviceIdentifier
{
    NCMCDeviceInfo* centralDevice = [self getDeviceInfoByUniqueID:0];
    if (centralDevice != nil) {
        return centralDevice.identifier;
    } else {
        return @"";
    }
}

@end
