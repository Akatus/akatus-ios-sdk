//
//  MainViewController.m
//  iOSAkatusCore
//
//  Created by Fernando Bass on 5/21/14.
//  Copyright (c) 2014 Fernando Bass. All rights reserved.
//

#import "MainViewController.h"
#import "AKCoreUser.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    AKCoreUser *user = [AKCoreUser shared];

    if ([user isValidSession]) {
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)login:(id)sender {
    AKCoreUser *user = [AKCoreUser shared];
    
    if ([user isValidSession]) {
        [user logoutWithCompletion:^{
            [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        }];
    }else{
        [user loginWithEmail:@"apple@akatus.com" andPassword:@"akatusapple10" success:^{
            NSLog(@"Login com sucesso!");
            [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        } failure:^(NSDictionary *error) {
            NSLog(@"Falha %@", error);
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
