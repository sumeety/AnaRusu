//
//  FacebookSignUpViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 19/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CountryListViewController.h"

@interface FacebookSignUpViewController : UIViewController {
    IBOutlet UILabel        *userNameLabel;
    IBOutlet UILabel        *userEmailLabel;
    IBOutlet UILabel        *userDOBLabel;
    IBOutlet UITextField    *firstNameTextField;
    IBOutlet UITextField    *userNumberTextfield;
    IBOutlet UITextField    *userEmailfield;
    IBOutlet UIImageView    *userImageView;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *confirmPasswordTextField;
    IBOutlet UIButton *proceedButton;
    IBOutlet UIButton           *countryCodeButton;

}

@property (nonatomic, strong) id<FBGraphUser>  userInformation;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) UIImage        *userImage;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;

- (IBAction)signUpButtonClicked:(UIButton *)sender;

@end
