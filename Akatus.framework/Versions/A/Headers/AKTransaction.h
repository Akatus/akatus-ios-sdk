//
//  AKTransaction.h
//  Akatus
//
//  Created by Fernando Bass on 6/19/13.
//  Copyright (c) 2013 Fernando Bass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKTransaction : NSObject
@property (nonatomic) float amount;
@property (nonatomic) int installment;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardHolderName;
@property (nonatomic, strong) NSString *creditValidates;
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cpf;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSData *signature;
@property (nonatomic, strong) NSData *productImage;
@end
