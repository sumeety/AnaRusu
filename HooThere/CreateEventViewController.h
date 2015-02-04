//
//  CreateEventViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 24/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateEventViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
    
//    IBOutlet UIButton *cancelButton;
//    IBOutlet UIButton *createButton;
    IBOutlet UITextField            *nameTextField;
    IBOutlet UITextView             *descriptionTextView;
}

@property (nonatomic) BOOL  isPublic;

- (IBAction)createButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)switchToggled:(UISwitch *)settingSwitch;

@end
