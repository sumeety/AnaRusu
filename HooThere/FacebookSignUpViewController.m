//
//  FacebookSignUpViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 19/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "FacebookSignUpViewController.h"
#import "UtilitiesHelper.h"
#import "HomeViewController.h"
#import "CoreDataInterface.h"
#import "VerifyViewController.h"
#import "WhoThereViewController.h"

@interface FacebookSignUpViewController ()

@end

@implementation FacebookSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    proceedButton.layer.cornerRadius=3;
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    // Do any additional setup after loading the view.
    NSLog(@"In Facebook  Sign Up view Controller");
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [self loadUSerInformationFromFacebook];
    [UtilitiesHelper changeTextFields:userEmailfield];
    [UtilitiesHelper changeTextFields:userNumberTextfield];
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)loadUSerInformationFromFacebook {
    self.profilePictureView.profileID = _userInformation.objectID;
    [self provideRoundCornerFor:self.profilePictureView cornerRadius:34];
    userImageView.image = _userImage;
    
    userNameLabel.text = [_userInformation objectForKey:@"name"];
    userEmailLabel.text = [_userInformation objectForKey:@"email"];
    userDOBLabel.text = [_userInformation objectForKey:@"birthday"];
    userEmailfield.text = [_userInformation objectForKey:@"email"];
    NSLog(@"userinfo in facebook %@",[_userInformation objectForKey:@"id"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)provideRoundCornerFor:(FBProfilePictureView *)profileImageView cornerRadius:(CGFloat)cornerRadius {
    
    profileImageView.layer.cornerRadius = 34;
    profileImageView.layer.masksToBounds = YES;
}

- (IBAction)signUpButtonClicked:(UIButton *)sender {
    
    [self checkEmailAndDisplayAlert];
}

- (void)checkEmailAndDisplayAlert {
    if(![self validateEmail:[userEmailfield text]]) {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self checkPassword];
}
-(void) checkPassword{
//    if (!passwordTextField.text.length > 0 || !confirmPasswordTextField.text.length > 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password cannot be blank." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//    }
//    else if (![passwordTextField.text isEqualToString:confirmPasswordTextField.text]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password mismatch" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//    }
//    else {
        if (userNumberTextfield.text.length > 0) {
            if ([self validatePhoneNumber:userNumberTextfield.text]) {
                [_activityIndicator startAnimating];
                [self.view endEditing:YES];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
                
                NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          userEmailfield.text, @"email",
//                                          passwordTextField.text, @"password",
                                          userNumberTextfield.text, @"mobile",
                                          @"F",@"signupType",
                                          ([_userInformation objectForKey:@"id"])?[_userInformation objectForKey:@"id"]:@" ",@"facebookId",
                                          ([_userInformation objectForKey:@"first_name"])?[_userInformation objectForKey:@"first_name"]:@" ",@"firstName",
                                          
                                          ([_userInformation objectForKey:@"last_name"])?[_userInformation objectForKey:@"last_name"]:@" ",@"lastName",
                                          ([_userInformation objectForKey:@"birthday"])?[_userInformation objectForKey:@"birthday"]:@" ",@"dateOfBirth",
                                         oldTokenId,@"deviceId",
                                          @"ios",@"platform",
                                          nil];
                
                NSLog(@"userData %@",userData);
                NSString *urlString = [NSString stringWithFormat:@"%@/user/register",kwebUrl];
                
                [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
                 {
                     [_activityIndicator stopAnimating];
                     if (success) {
                         NSString *userId=[jsonDict objectForKey:@"id"];
                         if(userId) {
                             
                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Your password has been emailed on this id" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                             [alertView show];
                             
                             [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                             if([[jsonDict objectForKey:@"activationStatus"] isEqualToString:@"A"])
                                {
                                 
                                 
                             [UtilitiesHelper uploadImage:UIImagePNGRepresentation(userImageView.image)];
                             [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(userImageView.image) forKey:@"UserImage"];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                             [defaults setBool:YES forKey:@"isloggedin"];
                             [defaults synchronize];
                             [CoreDataInterface saveUserInformation:jsonDict];

                                    WhoThereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
//                                    [self.navigationController pushViewController:whoThereView animated:NO];
                                    NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                                    [navigationArray removeObjectAtIndex:1];
                                    [navigationArray removeObjectAtIndex:1];
                                    [navigationArray addObject:whoThereView];
                                    [self.navigationController setViewControllers:navigationArray];
//                                    self.tabBarController.selectedIndex = 0;

                                }
                             else if([[jsonDict objectForKey:@"activationStatus"] isEqualToString:@"P"]){
                             
                                 
                                 VerifyViewController *verifyView = [self.storyboard instantiateViewControllerWithIdentifier:@"verifyView"];
                                 verifyView.userId=[jsonDict objectForKey:@"id"];
                                 verifyView.phoneNumber=[jsonDict objectForKey:@"mobile"];
//                                 [self.navigationController pushViewController:verifyView animated:YES];
                                 NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                                 [navigationArray removeObjectAtIndex:1];
                                 [navigationArray addObject:verifyView];
                                 [self.navigationController setViewControllers:navigationArray];
                             
                             
                             }
                         }

                     }
                     
                 }];
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
        
//    }
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
