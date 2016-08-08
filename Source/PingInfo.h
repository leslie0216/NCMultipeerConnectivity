//
//  PingInfo.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-08-08.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PingInfo : NSObject
@property(assign, nonatomic)int token;
@property(assign, nonatomic)CFTimeInterval startTime;
@property(strong, nonatomic)NSMutableArray *timeIntervals;
@property(assign, nonatomic)unsigned long totalCount;
@property(assign, nonatomic)unsigned long currentCount;
@property(assign, nonatomic)unsigned long number;

@end

