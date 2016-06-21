//
//  NCMCPeerID.m
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-21.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "NCMCPeerID.h"

@interface NCMCPeerID()

@property (strong, nonatomic)NSString *displayName;
@property (strong, nonatomic)NSString *identifier;

@end

@implementation NCMCPeerID

@synthesize displayName, identifier;

-(instancetype)initWithDisplayName:(NSString *)myDisplayName
{
    self = [super init];
    
    if (self) {
        self.displayName = myDisplayName;
        self.identifier = [[[NSUUID alloc]init] UUIDString];
    }
    
    return self;
}

-(NSString*)displayName
{
    return self.displayName;
}

-(NSString*)identifier
{
    return self.identifier;
}

@end
