//
//  LoginViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField    *emailTextfield;
    IBOutlet UITextField    *passwordTextfield;
    
    IBOutlet UIButton       *loginButton;
}

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;


- (IBAction)loginButtonClicked:(UIButton *)sender;

@end
