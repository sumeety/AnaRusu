//
//  SignUpViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "SignUpViewController.h"
#import "HomeViewController.h"
#import "UtilitiesHelper.h"
#import "FacebookSignUpViewController.h"
#import "CoreDataInterface.h"
#import "VerifyViewController.h"
#import "ChangeNumberViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "WhoThereViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CoreDataInterface wipeOutSavedData];
    
//    [self getCountryCode];
    
    // Do any additional setup after loading the view.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    
    CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = network_Info.subscriberCellularProvider;
    
    NSLog(@"country code is: %@", carrier.mobileCountryCode);
   
    signUpButton.layer.cornerRadius=3;
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    [self loadSignInWithFacebook];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [UtilitiesHelper changeTextFields:emailTextField];
    [UtilitiesHelper changeTextFields:passwordTextField];
    [UtilitiesHelper changeTextFields:confirmPasswordTextField];
    [UtilitiesHelper changeTextFields:numberTextField];
    [UtilitiesHelper changeTextFields:firstNameTextField];
    firstNameTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;

}

//- (NSString *)getCountryCode {
//    CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
//    CTCarrier *carrier = network_Info.subscriberCellularProvider;
//    
//    NSLog(@"country code is: %@", carrier.mobileCountryCode);
//    
//    NSString *code = code
//}



- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];

    _facebookInformationLoaded = FALSE;
    
    CGRect newFrame;;
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    if (iOSDeviceScreenSize.height > 500)
    {
        newFrame = CGRectMake(20, 380, 280, 43);
    }
    else {
        newFrame = CGRectMake(20, 350, 280, 43);
    }
    loginview.frame = newFrame;
    
    CGRect newButtonFrame = CGRectMake(0, 0, 280, 43);
    [[loginview.subviews objectAtIndex:0] setFrame:newButtonFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark Facebook Methods--------------



- (void)loadSignInWithFacebook {
    loginview = [UtilitiesHelper loadFacbookButton:CGRectMake(20, 380, 280, 43)];
    loginview.delegate = self;
    [self.view addSubview:loginview];
    
    NSLog(@"Array : %@",loginview.subviews);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
//    self.profilePictureView.profileID = [user objectForKey:@"id"];
//    NSLog(@"Profile View : %@",self.profilePictureView.subviews);
//
//    UIImage *image = [[self.profilePictureView.subviews objectAtIndex:0] image];

    if (!_facebookInformationLoaded) {
        [self signUpUsingFacebookAccount:user image:nil];
    }
}

- (void)signUpUsingFacebookAccount:(id<FBGraphUser>)user image:(UIImage *)image {
    _facebookInformationLoaded = TRUE;
    FacebookSignUpViewController *facebookSignUpView = [self.storyboard instantiateViewControllerWithIdentifier:@"facebookSignUpView"];
    facebookSignUpView.userInformation = user;
    facebookSignUpView.userImage = image;
    double delayInSeconds = 0.5;
    NSLog(@"User data from facebook %@",user);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self.navigationController pushViewController:facebookSignUpView animated:NO];
         });
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"You're logged in");
    
       [[loginview.subviews objectAtIndex:2] setText:@"Sign Out From Facebook"];
   
   
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"You're logged out");
    [[loginview.subviews objectAtIndex:2] setText:@"Sign Up With Facebook"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signUpButtonClicked:(UIButton *)sender {
    if (!firstNameTextField.text.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter your first name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self checkEmailAndDisplayAlert];
}

- (void)checkEmailAndDisplayAlert {
    if(![self validateEmail:[emailTextField text]]) {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        if (numberTextField.text.length > 0) {
            if ([self validatePhoneNumber:numberTextField.text]) {
                [self checkPassword];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

- (void)checkPassword {
    if (!passwordTextField.text.length > 0 || !confirmPasswordTextField.text.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password cannot be blank." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if (![passwordTextField.text isEqualToString:confirmPasswordTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password mismatch" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
 
    
    else {
        [_activityIndicator startAnimating];
        [self.view endEditing:YES];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
            NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      firstNameTextField.text,@"firstName",
                                      emailTextField.text, @"email",
                                      passwordTextField.text, @"password",
                                      numberTextField.text, @"mobile",
                                      @"hoothere",@"signupType",
                                      oldTokenId,@"deviceId",
                                      @"ios",@"platform",
                                      nil];
            
            NSString *urlString = [NSString stringWithFormat:@"%@/user/register",kwebUrl];
            
            [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
             {
                 [_activityIndicator stopAnimating];
                 if (success) {
                     NSString *userId=[jsonDict objectForKey:@"id"];
                     if(userId) {
                         [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                         
                         if([[jsonDict objectForKey:@"activationStatus"] isEqualToString:@"A"])
                         {
                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                             [defaults setBool:YES forKey:@"isloggedin"];
                             [defaults synchronize];

                             
                         [CoreDataInterface saveUserInformation:jsonDict];

                             WhoThereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
//                             [self.navigationController pushViewController:whoThereView animated:NO];
//                             self.tabBarController.selectedIndex = 0;
                             NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                             [navigationArray removeObjectAtIndex:1];
                             [navigationArray addObject:whoThereView];
                             [self.navigationController setViewControllers:navigationArray];
                         }
                         else if ([[jsonDict objectForKey:@"activationStatus"] isEqualToString:@"P"])
                             
                         {
                             
                         
                             VerifyViewController *verifyView = [self.storyboard instantiateViewControllerWithIdentifier:@"verifyView"];
                             verifyView.userId=[jsonDict objectForKey:@"id"];
                              verifyView.phoneNumber=[jsonDict objectForKey:@"mobile"];
                             [self.navigationController pushViewController:verifyView animated:YES];
                            
                         
                         }
                     }

                 }
                 
             }];
    }
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

- (BOOL)validatePhoneNumber:(NSString *)phoneNumber {
    BOOL valid;
    if (phoneNumber.length < 10 || phoneNumber.length > 15) {
        return NO;
    }
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:phoneNumber];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    if (!valid) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark Textfield Delegate -------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField==firstNameTextField)
        [emailTextField becomeFirstResponder];
    else if (textField == emailTextField) {
        [numberTextField becomeFirstResponder];
    }
    else if (textField == numberTextField) {
        [passwordTextField becomeFirstResponder];
    }
    else if (textField == passwordTextField) {
        [confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == confirmPasswordTextField) {
        [self signUpButtonClicked:signUpButton];
    }
    return YES;
}

#pragma mark Country Code Delegate --------


-(IBAction)actionMethodSelectCountry:(id)sender{
    CountryListViewController *pupulateCountryList = [[CountryListViewController alloc]initWithNibName:@"CountryListViewController" bundle:nil];
    //pupulateCountryList.parentScreen = self;
    pupulateCountryList.delegate = self;
    
    [self.navigationController pushViewController:pupulateCountryList animated:NO];
}

-(void) countryListReturnedValues:(NSString *)countryName andCode:(NSString *)countryCode{
    [countryCodeButton setTitle:[NSString stringWithFormat:@"+%@", countryCode] forState:UIControlStateNormal];
}

@end
