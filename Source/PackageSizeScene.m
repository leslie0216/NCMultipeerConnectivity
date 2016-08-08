//
//  PackageSizeScene.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-08-05.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "PackageSizeScene.h"
#import "MultiplayerController.h"
#import "Parameters.h"
#import "NetworkLogger.h"
#import "Messages.pbobjc.h"
#import "PingInfo.h"



@implementation PackageSizeScene
{
    CCButton* btnPSStart;
    CCLabelTTF* lbpsNetworkStatus;
    CCLabelTTF* lbpsIsHost;
    CCLabelTTF* lbpsPackageSize;
    CCLabelTTF* lbpsCurrentPing;
    CCLabelTTF* lbpsReceviedCount;
    CCLabelTTF* lbpsTotalCount;
    
    BOOL isPing;
    NetworkLogger *myLog;
    NSMutableDictionary *pingDict;
    unsigned int totalCount;
    BOOL isLogEnabled;
    int messageSize;
    unsigned int receivedCount;
}

-(void)onEnter
{
    [super onEnter];
    
    NSUInteger peerCount = [[[[MultiplayerController instance] currentSession] getConnectedPeers] count];
    
    lbpsNetworkStatus.string = [NSString stringWithFormat:@"%lu", (unsigned long)peerCount];
    
    lbpsIsHost.string = [[MultiplayerController instance]isHost] ? @"YES" : @"NO";
    
    isPing = NO;
    btnPSStart.title = @"Start";
    messageSize = 0;
    isLogEnabled = NO;
    
    lbpsPackageSize.string = [NSString stringWithFormat:@"%d", [self getPackageSize]];
    
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

- (void)handleUpdatePlayerlistWithNotification:(NSNotification *)notification
{
    NSUInteger peerCount = [[[[MultiplayerController instance] currentSession] getConnectedPeers] count];
    
    lbpsNetworkStatus.string = [NSString stringWithFormat:@"%lu", (unsigned long)peerCount];
}

- (void)handleReceivedMessageWithNotification:(NSNotification *)notification
{
    NSData* msgData = [[notification userInfo] objectForKey:@"data"];
    //NSString* name = [[notification userInfo] objectForKey:@"name"];
    
    
    PingMessage *message = [[PingMessage alloc] initWithData:msgData error:nil];
    if (message == nil) {
        CCLOG(@"Invalid data received!!!");
        return;
    }
    
    if (message.messageType == PingMessage_MsgType_Response) {
        NSString *token = [NSString stringWithFormat:@"%u", (message.token)];
        
        PingInfo *info = pingDict[token];
        if (info == nil) {
            CCLOG(@"Invalid ping token received!!!");
            return;
        } else if(info.totalCount == info.currentCount) {
            CCLOG(@"Token over received!!!");
            return;
        }
        
        CFTimeInterval receiveTime = [[[notification userInfo] objectForKey:@"time"] doubleValue];
        CFTimeInterval timeInterval = receiveTime - info.startTime - message.responseTime;
        NSNumber *numTime = [[NSNumber alloc] initWithDouble:timeInterval];

        [info.timeIntervals addObject:numTime];
        info.currentCount += 1;
        receivedCount += 1;
        
        if (isPing) {
            lbpsPackageSize.string = [NSString stringWithFormat:@"%d", [self getPackageSize]];
            lbpsCurrentPing.string = [NSString stringWithFormat:@"%f", timeInterval];
            lbpsReceviedCount.string = [NSString stringWithFormat:@"%d", receivedCount];
            lbpsTotalCount.string = [NSString stringWithFormat:@"%d", totalCount];
            
            if (info.totalCount == info.currentCount) {
                if (totalCount >= MaxPingCount && receivedCount >= MaxPingCount) {
                    [self calculateResult];
                } else {
                    [self doPing];
                }
            }
        }
    } else if (message.messageType == PingMessage_MsgType_Ping){
        PingMessage *packet = [[PingMessage alloc]init];
        packet.messageType = PingMessage_MsgType_Response;
        packet.token = message.token;
        packet.isReliable = message.isReliable;
        packet.message = @"";
        
        CFTimeInterval receiveTime = [[[notification userInfo] objectForKey:@"time"] doubleValue];
        NSTimeInterval t2 = CACurrentMediaTime() * 1000; // s to ms
        packet.responseTime = t2 - receiveTime;
        
        NSData *sendData = [packet data];
        
        NCMCSessionSendDataMode mode = message.isReliable ? NCMCSessionSendDataReliable : NCMCSessionSendDataUnreliable;
        
        [[MultiplayerController instance] sendData:sendData toAllwithMode:mode];
        
        CCLOG(@"send response to %@ with token : %u, length : %lu and local response time : %f", [[notification userInfo] objectForKey:@"peerName"], message.token, (unsigned long)sendData.length, packet.responseTime);
    }
}

-(int)getPackageSize
{
    int size = messageSize + 10;
    
    if (messageSize >= 128) {
        size += 1;
    }
    
    if (messageSize >= 502) {
        size += 2;
    }
    
    return size;
}


-(void)startLog
{
    if (myLog == nil) {
        myLog = [[NetworkLogger alloc]init];
    }
    
    [myLog newLogFile];
}

-(void)writeLog:(NSString *)log
{
    if (myLog != nil) {
        [myLog write:log];
    }
}

-(void)onBtnPSStart
{
    if (isPing) {
        [self stopPing];
    } else {
        [self startPing];
    }
}

-(void)startPing
{
    isPing = YES;
    btnPSStart.title = @"Stop";
    
    if (pingDict == nil) {
        pingDict = [[NSMutableDictionary alloc]init];
    } else {
        [pingDict removeAllObjects ];
    }
    
    totalCount = 0;
    receivedCount = 0;
    messageSize = 1;
    
    if (isLogEnabled) {
        [self startLog];
    }
    
    [self doPing];
}

-(void)stopPing
{
    isPing = NO;
    btnPSStart.title = @"Start";
}

-(void)doPing
{
    PingMessage* bufMsg = [[PingMessage alloc] init];
    
    NSMutableString *message = [[NSMutableString alloc]initWithCapacity:messageSize];
    for (int i=0; i<messageSize; ++i) {
        [message appendString:@"a"];
    }
    
    int token = totalCount + 1;
    
    bufMsg.message = message;
    bufMsg.token = token;
    bufMsg.messageType = PingMessage_MsgType_Ping;
    bufMsg.responseTime = 0.0;
    bufMsg.isReliable = NO;
    NSData* msg = [bufMsg data];
    CFTimeInterval startTime = CACurrentMediaTime() * 1000;
    CCLOG(@"DoPing : messageSize: %d, totalSize: %lu, packageSize: %d", messageSize, (unsigned long)[msg length], [self getPackageSize]);
    [[MultiplayerController instance] sendData:msg toAllwithMode:NCMCSessionSendDataReliable];
    
    PingInfo *info = [[PingInfo alloc]init];
    info.startTime = startTime;
    info.token = token;
    info.totalCount = [[[[MultiplayerController instance] currentSession] getConnectedPeers] count];
    info.currentCount = 0;
    info.number = totalCount + 1;
    totalCount += info.totalCount;
    info.timeIntervals = [[NSMutableArray alloc]initWithCapacity:info.totalCount];
    
    NSString *t = [NSString stringWithFormat:@"%d", token];
    [pingDict setValue:info forKey:t];
}

- (NSNumber *)standardDeviationOf:(NSArray *)array mean:(double)mean
{
    if(![array count]) return nil;
    
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in array)
    {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / [array count])];
}

- (void)calculateResult
{
    NSMutableArray *allTimes = [[NSMutableArray alloc]init];
    for (id key in pingDict) {
        PingInfo *info = pingDict[key];
        
        for(NSNumber *num in info.timeIntervals) {
            [allTimes addObject:num];
        }
    }
    
    NSNumber *average = [allTimes valueForKeyPath:@"@avg.self"];
    NSNumber *std = [self standardDeviationOf:allTimes mean:[average doubleValue]];

    
    if (isLogEnabled) {
        // log (packSize, avgPing, sd)
        int realsize = [self getPackageSize];
        
        NSString *log = [[NSString alloc]initWithFormat:@"%d, %.8f, %.8f\n", realsize, [average doubleValue], [std doubleValue]];
        
        [self writeLog:log];
    }
    
    if (isPing) {
        [pingDict removeAllObjects];
        receivedCount = 0;
        totalCount = 0;
        messageSize += 1;
        [self doPing];
    }
}

@end
