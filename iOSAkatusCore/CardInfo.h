//
//  CardInfo.h
//  Akatus
//
//  Created by Fernando Bass on 6/21/13.
//  Copyright (c) 2013 Fernando Bass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardInfo : NSObject
+ (CardInfo *)sharedInstance;

@property (strong) NSString *cardMagStrip;
@end
