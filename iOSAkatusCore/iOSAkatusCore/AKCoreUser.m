//
//  CoreUser.m
//  iOSAkatusCore
//
//  Created by Fernando Bass on 4/29/14.
//  Copyright (c) 2014 Fernando Bass. All rights reserved.
//

#import "AKCoreUser.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "DCKeyValueObjectMapping.h"
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "UIDevice-Hardware.h"

@interface AKCoreUser () <CLLocationManagerDelegate>
@property (strong) NSDictionary *geolocation;
@property (strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL hasLocation;
@end

@implementation AKCoreUser

+ (AKCoreUser *)shared
{
    static AKCoreUser *user = nil;
    
    @synchronized (self){
        
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            user = [[AKCoreUser alloc] initWithLocation];
        });
    }
    
    return user;
}

- (id)initWithLocation
{
    if (self = [super init]){
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    
    return self;
}

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password success:(void(^)())success
               failure:(void (^)(NSDictionary *error))failure
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    
    NSString *deviceInfo = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] modelName], [[UIDevice currentDevice] systemVersion]];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    self.geolocation = @{@"latitude" : latitude, @"longitude" : longitude};
    
    NSString *url = [NSString stringWithFormat:@"%@api/mobile/v2/auth",kBASE_URL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSDictionary *parameters = @{@"email": email, @"password" : password, @"device" : deviceInfo, @"app_version" : @"2.3"};
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if ([responseObject valueForKey:@"return_code"] > 0) {
            NSDictionary *info = @{@"return_code" : [responseObject valueForKey:@"return_code"], @"message" : [responseObject valueForKey:@"message"]};
            [userDefaults setBool:NO forKey:kIsValidSession];
            [userDefaults synchronize];
            failure(info);
        }else{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
            [dic setValue:email forKey:@"email"];
            [userDefaults setObject:dic forKey:kUserInfo];
            [userDefaults setBool:YES forKey:kIsValidSession];
            [userDefaults synchronize];
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [userDefaults setBool:NO forKey:kIsValidSession];
        [userDefaults synchronize];
        NSLog(@"Login Error: %@", error);
    }];
}

- (AKCoreUser*)userInfo
{
    DCKeyValueObjectMapping *mapping = [DCKeyValueObjectMapping mapperForClass:[self class]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    AKCoreUser *user = [mapping parseDictionary:[userDefaults objectForKey:kUserInfo]];
    
    return user;
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    //    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)logoutWithCompletion:(void(^)())completion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kUserInfo];
    [userDefaults setBool:NO forKey:kIsValidSession];
    [userDefaults synchronize];
    
    if (completion) {
        completion();
    }
}

- (BOOL)isValidSession
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kIsValidSession];
}

@end
