//
//  CoreUser.m
//  iOSAkatusCore
//
//  Created by Fernando Bass on 4/29/14.
//  Copyright (c) 2014 Fernando Bass. All rights reserved.
//

#import "CoreUser.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "DCKeyValueObjectMapping.h"
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "UIDevice-Hardware.h"

@interface CoreUser () <CLLocationManagerDelegate>
@property (strong) NSDictionary *geolocation;
@property (strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL hasLocation;
@end

@implementation CoreUser

+ (CoreUser *)shared
{
    static CoreUser *user = nil;
    
    @synchronized (self){
        
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            user = [[CoreUser alloc] initWithLocation];
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
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    self.geolocation = @{@"latitude" : latitude, @"longitude" : longitude};
    
    NSString *url = [NSString stringWithFormat:@"%@api/mobile/v2/auth",kBASE_URL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"email": email, @"password" : password, @"device" : deviceInfo, @"app_version" : majorVersion};
    
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
        NSLog(@"Error: %@", error);
    }];
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
