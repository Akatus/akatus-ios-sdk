//
//  CoreUser.h
//  iOSAkatusCore
//
//  Created by Fernando Bass on 4/29/14.
//  Copyright (c) 2014 Fernando Bass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreUser : NSObject
@property (strong) NSString *token;
@property (nonatomic) BOOL accepts_credit_card;
@property (nonatomic) BOOL is_verified;
@property (nonatomic) BOOL pre_auth;
@property (nonatomic) int assumed_installments;
@property (nonatomic) float average_ticket;
@property (strong) NSString *installment_fee;
@property (strong) NSString *api_key;
@property (strong) NSString *item_photo_id;
@property (strong) NSString *kind;
@property (strong) NSString *owner;
@property (strong) NSString *accountStatus;
+ (CoreUser *)shared;
@end
