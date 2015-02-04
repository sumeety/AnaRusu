//
//  VerifyViewController.h
//  HooThere
//
//  Created by Jasmeet Kaur on 21/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *verifyTextField;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UIButton *changeNumberButton;
@property (strong,nonatomic)NSString *userId;
@property (strong,nonatomic)NSString *phoneNumber;
@property (strong, nonatomic) IBOutlet UIButton *verifyButton;

- (IBAction)changeNumberClicked:(id)sender;

- (IBAction)notReceivedYet:(id)sender;

- (IBAction)verifyButtonClicked:(id)sender;
@end
