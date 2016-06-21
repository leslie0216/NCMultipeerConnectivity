//
//  NCMCPeerID.h
//  NCMultipeerConnectivity
//
//  Created by Chengzhao Li on 2016-06-21.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMCPeerID : NSObject
- (instancetype)initWithDisplayName:(NSString *)myDisplayName;

- (NSString *)displayName;
- (NSString*)identifier;
@end
