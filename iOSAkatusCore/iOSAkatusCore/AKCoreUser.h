//
//  CoreUser.h
//  iOSAkatusCore
//
//  Created by Fernando Bass on 4/29/14.
//  Copyright (c) 2014 Fernando Bass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKCoreUser : NSObject
@property (nonatomic) BOOL accepts_credit_card;
@property (strong) NSString *api_key;
@property (strong) NSString *email;
@property (nonatomic) int assumed_installments;
@property (strong) NSString *average_ticket;
@property (strong) NSString *installment_fee;
@property (strong) NSString *token;
@property (nonatomic) BOOL is_verified;
@property (nonatomic) BOOL pre_auth;
@property (strong) NSString *kind;
@property (strong) NSString *owner;
@property (strong) NSString *account_status;

@property (nonatomic) BOOL isValidSession;

+ (AKCoreUser *)shared;

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password success:(void(^)())success
               failure:(void (^)(NSDictionary *error))failure;
- (void)logoutWithCompletion:(void(^)())completion; /* clear user session */
+ (AKCoreUser*)userInfo;
@end
