//
//  CardInfo.m
//  Akatus
//
//  Created by Fernando Bass on 6/21/13.
//  Copyright (c) 2013 Fernando Bass. All rights reserved.
//

#import "CardInfo.h"

@implementation CardInfo

+ (CardInfo *)sharedInstance
{
    static CardInfo *cardInfo = nil;
    
    @synchronized (self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            cardInfo = [[CardInfo alloc] init];
        });
    }
    
    return cardInfo;
}
@end
