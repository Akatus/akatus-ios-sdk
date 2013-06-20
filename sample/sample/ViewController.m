//
//  ViewController.m
//  sample
//
//  Created by Fernando Bass on 6/7/13.
//  Copyright (c) 2013 Fernando Bass. All rights reserved.
//

#import "ViewController.h"
#import <Akatus/Akatus.h>

@interface ViewController ()
{
    
    AKUser *user;
}
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)isValidSession:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)transaction:(id)sender;
- (IBAction)installments:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    user = [AKUser sharedInstance];
    user.debugMode = YES;
    if ([user isValidSession]) {
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)login:(id)sender {
    if ([user isValidSession]) {
        [user logoutWithCompletion:^{
            [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        }];
    }else{
        [user loginWithEmail:self.email.text andPassword:self.password.text success:^{
            [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        } failure:^(NSDictionary *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"erro" message:[error valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }];
    }
}

- (IBAction)transaction:(id)sender {
    if ([user isValidSession]) {
        AKTransaction *transaction = [[AKTransaction alloc] init];
        transaction.amount = 50.0f;
        transaction.installment = 1;
        transaction.productDescription = @"Compra teste SDK";
        transaction.creditCardNumber = @"4012001038443335";
        transaction.creditCardHolderName = @"AUTORIZAR";
        transaction.creditValidates = @"06/15";
        transaction.cvv = @"123";
        transaction.name = @"";
        transaction.cpf = @"";
        transaction.phone = @"11980717439";

        NSString *signaturePath = [[NSBundle mainBundle] pathForResource:@"assinatura" ofType:@"jpg" inDirectory:nil];

        transaction.signature = [NSData dataWithContentsOfFile:signaturePath];
        
        NSString *productImagePath = [[NSBundle mainBundle] pathForResource:@"produto" ofType:@"jpg" inDirectory:nil];
        transaction.productImage = [NSData dataWithContentsOfFile:productImagePath];
        
        AKTransactionManager *manager = [[AKTransactionManager alloc] init];
        
        [manager submitTransactionWithTransaction:transaction success:^(id transactionInfo) {
            NSLog(@"%@", transactionInfo);
        } failure:^(NSDictionary *error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Erro" message:[[error valueForKey:@"error"] componentsJoinedByString:@""] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Erro" message:@"Você precisa estar logado para efetuar uma transação" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
}

- (IBAction)installments:(id)sender {
    AKTransaction *transaction = [[AKTransaction alloc] init];
    [transaction calculeInstallmentValueWithAmount:10.0f success:^(NSArray *installments) {
        NSLog(@"%@", installments);
    } failure:^(NSDictionary *error) {
        NSLog(@"%@", error);
    }];
    
}

- (IBAction)isValidSession:(id)sender {
    NSLog(@"%@", user.isValidSession ? @"Sessão valida" : @"Sessão invalida");
}

@end
