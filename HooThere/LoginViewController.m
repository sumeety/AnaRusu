//
//  LoginViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "VerifyViewController.h"
#import "WhoThereViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [CoreDataInterface wipeOutSavedData];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    loginButton.layer.cornerRadius=3;
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
//    self.navigationItem.hidesBackButton = YES;
    
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonClicked)];
//    self.navigationItem.rightBarButtonItem = doneButton;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [UtilitiesHelper changeTextFields:emailTextfield];
    [UtilitiesHelper changeTextFields:passwordTextfield];
    
    // Do any additional setup after loading the view.
}



- (void)viewDidAppear:(BOOL)animated {
    [emailTextfield becomeFirstResponder];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //    self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonClicked {
    [self.navigationController popViewControllerAnimated:NO];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField.tag == 1) {
//        if (string.length > 0 || (emailTextfield.text.length > 0 && passwordTextfield.text.length > 0)) {
//            if (string.length > 0 && passwordTextfield.text.length > 0) {
//                self.navigationItem.rightBarButtonItem.enabled = YES;
//            }
//            else {
//                self.navigationItem.rightBarButtonItem.enabled = NO;
//            }
//        }
//    }
//    else if (textField.tag == 2) {
//        if (string.length > 0 || (emailTextfield.text.length > 0 && passwordTextfield.text.length > 0)) {
//            if (string.length > 0 && emailTextfield.text.length > 0) {
//                self.navigationItem.rightBarButtonItem.enabled = YES;
//            }
//            else {
//                self.navigationItem.rightBarButtonItem.enabled = NO;
//            }
//        }
//    }
//    else {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
//    
//    return YES;
//}

-(BOOL)validateEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)checkEmailAndDisplayAlert {
    if(![self validateEmail:[emailTextfield text]]) {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        [self checkPassword];
    }
}

- (void)checkPassword {
    if (!passwordTextfield.text.length > 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter the password minimum of 8 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self sendingLoginRequest];
    }
}

- (void)sendingLoginRequest {
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
    
    NSLog(@"Device ID**** %@",oldTokenId);
    NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              emailTextfield.text, @"email",
                              passwordTextfield.text, @"password",
                              oldTokenId,@"deviceId",
                              @"ios",@"platform",
                              nil];
    
    
    NSLog(@"Login Detail %@",userData);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/login",kwebUrl];
    
    [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         NSLog(@"in success block");

         if (success) {
            NSString *userId=[[jsonDict objectForKey:@"id"] stringValue];
             if(userId.length > 0) {
                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setBool:YES forKey:@"isloggedin"];
                 [defaults synchronize];
                 
                 if([[jsonDict objectForKey:@"activationStatus"] isEqualToString:@"A"])
                 {
                 NSString *tokenStatusMessage = [jsonDict objectForKey:@"tokenStatusMessage"];
                 
                 
                 if (tokenStatusMessage.length > 0) {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:tokenStatusMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alertView show];
                 }
                 
                 [CoreDataInterface saveUserInformation:jsonDict];
                 [CoreDataInterface saveUserImageForUserId:userId];
                     WhoThereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
//                     [self.navigationController pushViewController:whoThereView animated:NO];

                     NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                     [navigationArray removeObjectAtIndex:1];
                     [navigationArray addObject:whoThereView];
                     [self.navigationController setViewControllers:navigationArray];
//                self.tabBarController.selectedIndex = 0;
                 }
                 
                 else if([[jsonDict objectForKey:@"activationStatus"] isEqualToString:@"P"])
                 {
                     VerifyViewController *verifyView = [self.storyboard instantiateViewControllerWithIdentifier:@"verifyView"];
                     verifyView.userId=[jsonDict objectForKey:@"id"];
                     verifyView.phoneNumber=[jsonDict objectForKey:@"mobile"];
                     [self.navigationController pushViewController:verifyView animated:YES];
                 
                 }
             }
            
         }
         else
              [_activityIndicator stopAnimating];
             
     }];
}
- (IBAction)loginButtonClicked:(UIButton *)sender {
  [self checkEmailAndDisplayAlert];
//    HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
//    [self.navigationController pushViewController:homeView animated:YES];
}

#pragma mark Textfield Delegate -------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == emailTextfield) {
        [passwordTextfield becomeFirstResponder];
    }
    else if (textField == passwordTextfield) {
        [self loginButtonClicked:loginButton];
    }
    
    return YES;
}


@end
