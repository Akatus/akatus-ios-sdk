//
//  AKUser.h
//  Akatus
//
//  Created by Fernando Bass on 6/7/13.
//  Copyright (c) 2013 Fernando Bass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKUser : NSObject
+ (AKUser *)sharedInstance;
- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password success:(void(^)())success
               failure:(void (^)(NSDictionary *error))failure;
- (void)logoutWithCompletion:(void(^)())completion; /* clear user session */
- (BOOL)isValidSession; /* return a valid session */
@property (nonatomic) BOOL debugMode; /* Default is NO */
@end
