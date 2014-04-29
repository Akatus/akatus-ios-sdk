//
//  CoreUser.m
//  iOSAkatusCore
//
//  Created by Fernando Bass on 4/29/14.
//  Copyright (c) 2014 Fernando Bass. All rights reserved.
//

#import "CoreUser.h"

@implementation CoreUser

+ (CoreUser *)shared
{
    static CoreUser *user = nil;
    
    @synchronized (self){
        
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            user = [[CoreUser alloc] init];
        });
    }
    
    return user;
}

@end
