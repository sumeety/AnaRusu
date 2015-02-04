//
//  ChangeNumberViewController.h
//  HooThere
//
//  Created by Jasmeet Kaur on 21/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryListViewController.h"

@interface ChangeNumberViewController : UIViewController <UITextFieldDelegate ,UIAlertViewDelegate> {
    
    IBOutlet UIButton           *countryCodeButton;
}
@property (strong, nonatomic) IBOutlet UITextField *numberTextField;
@property (strong,nonatomic)NSString *email;
@property (strong,nonatomic)NSString *userId;
- (IBAction)submitButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@end
