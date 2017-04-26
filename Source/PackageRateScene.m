//
//  PackageRateScene.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-08-05.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "PackageRateScene.h"
#import "MultiplayerController.h"
#import "Parameters.h"
#import "NetworkLogger.h"
#import "Messages.pbobjc.h"
#import "PingInfo.h"


@implementation PackageRateScene
{
    CCButton* btnPRStart;
    CCLabelTTF* lbprNetworkStatus;
    CCLabelTTF* lbprIsHost;
    CCLabelTTF* lbprPackageSize;
    CCLabelTTF* lbprCurrentPing;
    CCLabelTTF* lbprReceviedCount;
    CCLabelTTF* lbprTotalCount;
    CCLabelTTF* lbprPackageRate;
    CCLabelTTF* lbprBandwidth;
    CCLabelTTF* lbprToken;
    
    BOOL isPing;
    BOOL isPingEnabled;
    NetworkLogger *myLog;
    NSMutableDictionary *pingDict;
    unsigned int totalCount;
    BOOL isLogEnabled;
    int messageSize;
    double lastServerBroadcastTime;
    int packageRate;
    unsigned int receivedCount;
}

-(void)onEnter
{
    [super onEnter];
    
    NSUInteger peerCount = [[[[MultiplayerController instance] currentSession] getConnectedPeers] count];
    
    lbprNetworkStatus.string = [NSString stringWithFormat:@"%lu", (unsigned long)peerCount];
    
    lbprIsHost.string = [[MultiplayerController instance]isHost] ? @"YES" : @"NO";
    
    isPing = NO;
    isPingEnabled = NO;
    btnPRStart.title = @"Start";
    messageSize = MessageSizeForPackageRate;
    isLogEnabled = YES;
    packageRate = 0;
    
    lbprPackageSize.string = [NSString stringWithFormat:@"%d", [self getPackageSize]];
    lbprPackageRate.string = [NSString stringWithFormat:@"%d", packageRate];
    lbprBandwidth.string = [NSString stringWithFormat:@"%f", [self getBandwidth]];
    
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
    
    lbprNetworkStatus.string = [NSString stringWithFormat:@"%lu", (unsigned long)peerCount];
}

- (void)handleReceivedMessageWithNotification:(NSNotification *)notification
{
    NSData* msgData = [[notification userInfo] objectForKey:@"data"];
    NSString* name = [[notification userInfo] objectForKey:@"name"];
    
    
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
        
        if (true) {
            lbprPackageSize.string = [NSString stringWithFormat:@"%d", [self getPackageSize]];
            lbprCurrentPing.string = [NSString stringWithFormat:@"%f", timeInterval];
            lbprReceviedCount.string = [NSString stringWithFormat:@"%d", receivedCount];
            lbprTotalCount.string = [NSString stringWithFormat:@"%d", totalCount];
            lbprPackageRate.string = [NSString stringWithFormat:@"%d", packageRate];
            lbprBandwidth.string = [NSString stringWithFormat:@"%f", [self getBandwidth]];
            
            if (info.totalCount == info.currentCount) {
                lbprToken.string = [NSString stringWithFormat:@"%d", info.token];
                /*if (totalCount >= MaxPingCount && receivedCount >= MaxPingCount) {
                    isPingEnabled = NO;
                    [self calculateResult];
                }*/
                [self calculateResultWithToken:info.token];
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
        
        //[[MultiplayerController instance] sendData:sendData toAllwithMode:mode];
        [[MultiplayerController instance] sendData:sendData to:name withMode:mode];
        
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

-(BOOL)shouldBroadcast
{
    BOOL ret = NO;
    
    double currentTime = CACurrentMediaTime();
    if(lastServerBroadcastTime == 0) {
        // first time broadcast.
        lastServerBroadcastTime = currentTime;
    }
    
    float broadcastInterval = 1.0f/packageRate;
    float broadcastTimeElapsed = (currentTime - lastServerBroadcastTime);
    
    //
    
    if(broadcastTimeElapsed > broadcastInterval) {
        lastServerBroadcastTime = currentTime;
        ret = YES;
    }
    
    return ret;
}

-(float)getBandwidth
{
    int packageSize = [self getPackageSize];
    return packageRate * packageSize;
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

-(void)onBtnPRStart
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
    btnPRStart.title = @"Stop";
    
    if (pingDict == nil) {
        pingDict = [[NSMutableDictionary alloc]init];
    } else {
        [pingDict removeAllObjects ];
    }
    
    totalCount = 0;
    receivedCount = 0;
    messageSize = MessageSizeForPackageRate;
    
    if (isLogEnabled) {
        [self startLog];
    }
    
    lastServerBroadcastTime = 0;
    packageRate = 30;
    isPingEnabled = YES;
}

-(void)stopPing
{
    isPing = NO;
    isPingEnabled = NO;
    btnPRStart.title = @"Start";
}

-(void)update:(CCTime)delta
{
    //CCLOG(@"update time %f", delta);
    
    if (isPing && isPingEnabled && [self shouldBroadcast]) {
        [self doPing];
    }
}

-(void)doPing
{
    PingMessage* bufMsg = [[PingMessage alloc] init];
    
    NSMutableString *message = [[NSMutableString alloc]initWithCapacity:messageSize];
    for (int i=0; i<messageSize; ++i) {
        [message appendString:@"a"];
    }
    
    int token = ++totalCount;// + 1;
    
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
    //info.number = totalCount + 1;
    //totalCount += info.totalCount;
    info.timeIntervals = [[NSMutableArray alloc]initWithCapacity:info.totalCount];
    
    NSString *t = [NSString stringWithFormat:@"%d", token];
    [pingDict setValue:info forKey:t];
    
    /*
    if (totalCount >= MaxPingCount) {
        isPingEnabled = NO;
    }*/
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
    NSString* token;
    for (id key in pingDict) {
        PingInfo *info = pingDict[key];
        token = key;
        
        for(NSNumber *num in info.timeIntervals) {
            [allTimes addObject:num];
        }
    }
    
    NSNumber *average = [allTimes valueForKeyPath:@"@avg.self"];
    NSNumber *std = [self standardDeviationOf:allTimes mean:[average doubleValue]];
    
    
    if (isLogEnabled) {
        // log (packSize, packageRate, bandwidth, client count, avgPing, sd)
        NSUInteger peerCount = [[[[MultiplayerController instance] currentSession] getConnectedPeers] count];
        int realsize = [self getPackageSize];
        
        // NSString *log = [[NSString alloc]initWithFormat:@"%d, %d, %.8f, %lu, %.8f, %.8f\n", realsize, packageRate, [self getBandwidth], (unsigned long)peerCount, [average doubleValue], [std doubleValue]];
        NSString *log = [[NSString alloc]initWithFormat:@"%@, %d, %d, %.8f, %lu, %.8f, %.8f\n", token, realsize, packageRate, [self getBandwidth], (unsigned long)peerCount, [average doubleValue], [std doubleValue]];
        
        [self writeLog:log];
    }
    
    if (isPing) {
        [pingDict removeAllObjects];
        receivedCount = 0;
        totalCount = 0;
        //packageRate += 1;
        isPingEnabled = YES;
    }
}

- (void)calculateResultWithToken:(int) token
{
    NSMutableArray *allTimes = [[NSMutableArray alloc]init];
    NSString *t = [NSString stringWithFormat:@"%d", token];
    PingInfo *info = pingDict[t];
        
    for(NSNumber *num in info.timeIntervals) {
        [allTimes addObject:num];
    }
    
    NSNumber *average = [allTimes valueForKeyPath:@"@avg.self"];
    NSNumber *std = [self standardDeviationOf:allTimes mean:[average doubleValue]];
    
    
    if (isLogEnabled) {
        // log (packSize, packageRate, bandwidth, client count, avgPing, sd)
        NSUInteger peerCount = [[[[MultiplayerController instance] currentSession] getConnectedPeers] count];
        int realsize = [self getPackageSize];
        
        // NSString *log = [[NSString alloc]initWithFormat:@"%d, %d, %.8f, %lu, %.8f, %.8f\n", realsize, packageRate, [self getBandwidth], (unsigned long)peerCount, [average doubleValue], [std doubleValue]];
        NSString *log = [[NSString alloc]initWithFormat:@"%d, %d, %d, %.8f, %lu, %.8f, %.8f\n", token, realsize, packageRate, [self getBandwidth], (unsigned long)peerCount, [average doubleValue], [std doubleValue]];
        
        [self writeLog:log];
    }
}
@end
