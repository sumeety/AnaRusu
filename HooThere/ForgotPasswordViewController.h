//
//  ForgotPasswordViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 10/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UITextField        *emailIdTextfield;
    IBOutlet UIButton           *submitButton;
}

- (IBAction)submitButtonClicked:(id)sender;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;


@end
