//
//  SignUpViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CountryListViewController.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate, countryListDelegate>{
    
    IBOutlet UITextField        *numberTextField;
    IBOutlet UITextField        *firstNameTextField;
    IBOutlet UITextField        *emailTextField;
    IBOutlet UITextField        *passwordTextField;
    IBOutlet UITextField        *confirmPasswordTextField;
    IBOutlet UIButton           *countryCodeButton;

    FBLoginView                 *loginview;

    IBOutlet UIButton *signUpButton;
}

- (IBAction)signUpButtonClicked:(UIButton *)sender;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, strong) id<FBGraphUser>  user;
@property(nonatomic,strong)UIImage *image;

@property (nonatomic)         BOOL      facebookInformationLoaded;

@end
