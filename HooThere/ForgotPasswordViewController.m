//
//  ForgotPasswordViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 10/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "UtilitiesHelper.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
//    }
//    else {
//        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
//    }
    submitButton.layer.cornerRadius=3;
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    // Do any additional setup after loading the view.
    
    [UtilitiesHelper changeTextFields:emailIdTextfield];
    
    [emailIdTextfield becomeFirstResponder];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    // Do any additional setup after loading the view.
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitButtonClicked:(id)sender {
    [self checkEmailAndDisplayAlert];
}

- (void)checkEmailAndDisplayAlert {
    if(![self validateEmail:[emailIdTextfield text]]) {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        [self sendingForgotPasswordRequest];
    }
}

- (void)sendingForgotPasswordRequest {
    [emailIdTextfield resignFirstResponder];
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
    
    NSLog(@"Device ID**** %@",oldTokenId);
    NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              emailIdTextfield.text, @"email",
                              nil];
    
    
    NSLog(@"Login Detail %@",userData);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/forgotPassword",kwebUrl];
    
    [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         NSLog(@"in success block");
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"A new password is generated and sent to your email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alertView show];
             
             [self.navigationController popViewControllerAnimated:YES];
         }
         
     }];
}

-(BOOL)validateEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self submitButtonClicked:self];
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
