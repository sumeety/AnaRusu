//
//  ChangePasswordViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 14/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilitiesHelper.h"

@interface ChangePasswordViewController : UIViewController <UITextViewDelegate> {
    
    IBOutlet    UITextField         *currentPasswordTextfield;
    IBOutlet    UITextField         *newPasswordTextfield;
    IBOutlet    UITextField         *confirmPasswordTextfield;
    IBOutlet UIButton *savePassword;
}
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)okButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
