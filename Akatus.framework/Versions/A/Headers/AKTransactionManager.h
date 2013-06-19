//
//  AKTransactionManager.h
//  Akatus
//
//  Created by Fernando Bass on 6/19/13.
//  Copyright (c) 2013 Fernando Bass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKTransaction.h"

@interface AKTransactionManager : NSObject
- (void)submitTransactionWithTransaction:(AKTransaction *)transaction success:(void (^)(id transactionInfo))success failure:(void (^)(NSDictionary *error))failure;
@end
