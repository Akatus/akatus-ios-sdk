//
//  AKTransactionManager.m
//  Akatus
//
//  Created by Fernando Bass on 6/19/13.
//  Copyright (c) 2013 Fernando Bass. All rights reserved.
//

#import "AKTransactionManager.h"
#import "Constants.h"
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "AKCoreUser.h"
#import "DCKeyValueObjectMapping.h"
#import "CardInfo.h"
#import "UIDevice-Hardware.h"

@interface AKTransactionManager() <CLLocationManagerDelegate>
{
    NSURL *url;
}
- (void)uploadProductImageWithData:(NSData *)productImage success:(void (^) (NSString *productURL))success failure:(void (^)(NSDictionary  *error))failure;
- (void)uploadSignatureImageWithData:(NSData *)data success:(void (^) (NSString *signatureURL))success failure:(void (^)(NSDictionary  *error))failure;
@property (strong) NSDictionary *geolocation;
@property (strong) CLLocationManager *locationManager;
@property (strong) AKCoreUser* user;
@property (strong) CardInfo* cardInfo;
@property (strong) NSString *productImageURL;
@property (strong) NSString *signatureURL;
@property (strong) NSDictionary *deviceInfo;
@end

@implementation AKTransactionManager

- (void)submitTransactionWithTransaction:(AKTransactionManager *)transaction success:(void (^)(id transactionInfo))success failure:(void (^)(NSDictionary *error))failure
{
    self.cardInfo = [CardInfo sharedInstance];
    
    url = [NSURL URLWithString:kBASE_URL];

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults boolForKey:kIsValidSession]){
        if ([[self hasError:transaction] count] > 0) {
            failure(@{@"error": [self hasError:transaction]});
        }else{
            [self appInfo];
            DCKeyValueObjectMapping *mapping = [DCKeyValueObjectMapping mapperForClass:[AKCoreUser class]];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            self.user = [mapping parseDictionary:[userDefaults objectForKey:kUserInfo]];
            
            self.locationManager = [[CLLocationManager alloc] init];
            
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            self.productImageURL = @"";
            self.signatureURL = @"";
            
            [self uploadProductImageWithData:transaction.productImage success:^(NSString *productURL) {
                self.productImageURL = productURL;
                [self uploadSignatureImageWithData:transaction.signature success:^(NSString *signatureURL) {
                    self.signatureURL = signatureURL;
                    [self sendTransaction:transaction success:^(id transactionInfo) {
                        success(transactionInfo);
                    } failure:^(NSDictionary *error) {
                        failure(error);
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    }];
                } failure:^(NSDictionary *error) {
                    failure(error);
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }];
            } failure:^(NSDictionary *error) {
                failure(error);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
        }
    }else{
        failure(@{@"Erro" : @"Você precisa estar logado para efetuar uma transação"});
    }
}


- (void)uploadProductImageWithData:(NSData *)data success:(void (^) (NSString *productURL))success failure:(void (^)(NSDictionary  *error))failure
{
    if (data == nil) {
        success(@"");
    }else{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *postUrl = [NSString stringWithFormat:@"%@/api/mobile/v2/transaction/item_photo", kBASE_URL];
        
        [manager POST:postUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success([responseObject objectForKey:@"item_photo_id"]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(@{@"erro" : @"image upload"});
        }];
        
    }
}

- (void)uploadSignatureImageWithData:(NSData *)data success:(void (^) (NSString *signatureURL))success failure:(void (^)(NSDictionary  *error))failure
{
    if (data == nil) {
        failure(@{@"Erro" : @"Assinatura não pode ser vazia"});
    }else{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *postUrl = [NSString stringWithFormat:@"%@/api/mobile/v2/transaction/signature", kBASE_URL];
        
        [manager POST:postUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success([responseObject objectForKey:@"signature_id"]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(@{@"erro" : @"image upload"});
        }];
        
    }
}

- (void)sendTransaction:(AKTransactionManager *)transaction success:(void (^) (id transactionInfo))success failure:(void (^) (NSDictionary *error))failure
{
    
    NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    
    NSDictionary *geolocation = @{@"latitude" : latitude, @"longitude" : longitude};
    
    int type = 0;
    
    if ([self stringIsNilOrEmpty:self.cardInfo.cardMagStrip]) {
        type = 0;
    }else{
        type = 1;
    }
    
    NSMutableDictionary *parameters = [@{@"token" : self.user.token, @"type" : [NSString stringWithFormat:@"%d", type] , @"amount" : [NSString stringWithFormat:@"%.2f", transaction.amount], @"installments" : [NSString stringWithFormat:@"%d", transaction.installment], @"cvv" : transaction.cvv, @"signature" : self.signature, @"holder_name" : transaction.creditCardHolderName, @"card_number" : transaction.creditCardNumber, @"expiration" : transaction.creditValidates, @"description" : transaction.productDescription, @"track1" : self.cardInfo.cardMagStrip, @"geolocation" : geolocation, @"item_photo_id" : self.productImage, @"cart_item_photo_id" : @""} mutableCopy];
    
    if ([transaction.name length] > 0) {
        NSString *phone = [[[[transaction.phone stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *cpf = [[transaction.cpf stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSDictionary *payer = @{@"name" : transaction.name, @"phone" : phone , @"cpf" : cpf};
        [parameters setObject:payer forKey:@"payer"];
    }
    
    [parameters setObject:self.deviceInfo forKey:@"device_info"];
    
    NSString *postURL = [NSString stringWithFormat:@"%@/api/mobile/v2/transaction",kBASE_URL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:postURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.cardInfo.cardMagStrip = nil;
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.cardInfo.cardMagStrip = nil;
        failure(@{@"Error" : error.description});
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)appInfo
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    self.deviceInfo = @{@"platform" : @"iOS", @"model" : [[UIDevice currentDevice] modelName], @"os_version" : [[UIDevice currentDevice] systemVersion], @"app_version" : [NSString stringWithFormat:@"%@ (%@)", majorVersion, minorVersion], @"app_name" : appDisplayName};
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    
}

#pragma mark - Util

-(BOOL)stringIsNilOrEmpty:(NSString*)aString {
    return !(aString && aString.length);
}

#pragma mark - Validators

- (NSArray *)hasError:(AKTransactionManager *)transaction
{
    NSMutableArray *error = [NSMutableArray array];
    if ([self stringIsNilOrEmpty:transaction.name]) {
        [error addObject:@"- Nome deve ser preenchido\n"];
    }
    
    if ([self stringIsNilOrEmpty:transaction.cpf]) {
        [error addObject:@"- CPF deve ser preenchido\n"];
    }else{
        if (![self validateCPFWithNSString:transaction.cpf]) {
            [error addObject:@"- CPF inválido\n"];
        }
    }
    
    if ([self stringIsNilOrEmpty:transaction.phone]) {
        [error addObject:@"- Telefone deve ser preenchido\n"];
    }
    
    if ([self stringIsNilOrEmpty:self.cardInfo.cardMagStrip]) {
        
        self.cardInfo.cardMagStrip = @"";
        
        if ([self stringIsNilOrEmpty:transaction.creditCardHolderName]) {
            [error addObject:@"- Nome do cartão deve ser preenchido\n"];
        }
        
        if ([self stringIsNilOrEmpty:transaction.creditCardNumber]) {
            [error addObject:@"- Numero do cartão deve ser preenchido\n"];
        }else{
            if (![self checkCreditCardNumber:transaction.creditCardNumber]) {
                [error addObject:@"- Numero do cartão invalido\n"];
            }
        }
        
        if ([self stringIsNilOrEmpty:transaction.creditValidates]){
            [error addObject:@"- Data de validaded deve ser preenchido\n"];
        }
    }else{
        transaction.creditCardNumber = @"";
        transaction.creditCardHolderName = @"";
        transaction.creditValidates = @"";
    }
    
    if ([self stringIsNilOrEmpty:transaction.cvv]){
        [error addObject:@"- CVV deve ser preenchido\n"];
    }
    
    
    return error;
}

- (BOOL)validateCPFWithNSString:(NSString *)cpf {
    
    cpf = [[cpf stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSUInteger i, firstSum, secondSum, firstDigit, secondDigit, firstDigitCheck, secondDigitCheck;
    if(cpf == nil) return NO;
    
    if ([cpf length] != 11) return NO;
    if (([cpf isEqual:@"00000000000"]) || ([cpf isEqual:@"11111111111"]) || ([cpf isEqual:@"22222222222"])|| ([cpf isEqual:@"33333333333"])|| ([cpf isEqual:@"44444444444"])|| ([cpf isEqual:@"55555555555"])|| ([cpf isEqual:@"66666666666"])|| ([cpf isEqual:@"77777777777"])|| ([cpf isEqual:@"88888888888"])|| ([cpf isEqual:@"99999999999"])) return NO;
    
    firstSum = 0;
    for (i = 0; i <= 8; i++) {
        firstSum += [[cpf substringWithRange:NSMakeRange(i, 1)] intValue] * (10 - i);
    }
    
    if (firstSum % 11 < 2)
        firstDigit = 0;
    else
        firstDigit = 11 - (firstSum % 11);
    
    secondSum = 0;
    for (i = 0; i <= 9; i++) {
        secondSum = secondSum + [[cpf substringWithRange:NSMakeRange(i, 1)] intValue] * (11 - i);
    }
    
    if (secondSum % 11 < 2)
        secondDigit = 0;
    else
        secondDigit = 11 - (secondSum % 11);
    
    firstDigitCheck = [[cpf substringWithRange:NSMakeRange(9, 1)] intValue];
    secondDigitCheck = [[cpf substringWithRange:NSMakeRange(10, 1)] intValue];
    
    if ((firstDigit == firstDigitCheck) && (secondDigit == secondDigitCheck))
        return YES;
    return NO;
}

- (BOOL)checkCreditCardNumber:(NSString *)cardNumber
{
    NSInteger len = [cardNumber length];
    NSInteger oddDigits = 0;
    NSInteger evenDigits = 0;
    BOOL isOdd = YES;
    
    for (NSInteger i = len - 1; i >= 0; i--) {
        
        NSInteger number = [cardNumber substringWithRange:NSMakeRange(i, 1)].integerValue;
        if (isOdd) {
            oddDigits += number;
        }else{
            number = number * 2;
            if (number > 9) {
                number = number - 9;
            }
            evenDigits += number;
        }
        isOdd = !isOdd;
    }
    
    return ((oddDigits + evenDigits) % 10 == 0);
}

- (void)calculeInstallmentValueWithAmount:(float)amount success:(void (^)(NSArray *installments))success failure:(void (^)(NSDictionary *error))failure
{
    
    DCKeyValueObjectMapping *mapping = [DCKeyValueObjectMapping mapperForClass:[AKCoreUser class]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AKCoreUser *user = [mapping parseDictionary:[userDefaults objectForKey:kUserInfo]];

    NSString *postURL = [NSString stringWithFormat:@"%@api/v1/parcelamento/simulacao.json?email=%@&amount=%f&payment_method=cartao_visa&api_key=%@",kBASE_URL, user.email, amount, user.api_key];
    
    __block NSString *installment_info;
    __block NSMutableArray *installments;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:postURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        installment_info = [[responseObject valueForKey:@"resposta"] valueForKey:@"descricao"];
        NSArray *_installments = [[responseObject valueForKey:@"resposta"] valueForKey:@"parcelas"];
        installments = [NSMutableArray array];
        for (int i = 0; i < [_installments count]; i++) {
            if ([[[_installments objectAtIndex:i] valueForKey:@"valor"] floatValue] >= 5.0f) {
                [installments addObject:[_installments objectAtIndex:i]];
            }
        }
        
        success(installments);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(@{@"Error": error.description});
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}


@end
