//
//  CreateEventViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 24/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "CreateEventViewController.h"
#import "EventDateTimeViewController.h"
#import "CoreDataInterface.h"

@interface CreateEventViewController ()

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kcreateEventButtonClicked" object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createEvent) name:@"kcreateEventButtonClicked" object:nil];

    nameTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    descriptionTextView.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
//    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createButtonClicked:)];
    self.navigationItem.rightBarButtonItem = createButton;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [self customiseTextFields:nameTextField];
    descriptionTextView.layer.masksToBounds = YES;
    descriptionTextView.layer.cornerRadius = 3.0;
    descriptionTextView.layer.borderWidth = 0.0f;
    
    _isPublic = FALSE;
    // Do any additional setup after loading the view.
    
//    cancelButton.layer.borderColor=[UIColor purpleColor].CGColor;
//    cancelButton.layer.borderWidth=1.0f;
//    cancelButton.layer.cornerRadius=3;
//    createButton.layer.cornerRadius=3;
    
    [self loadDetails];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)loadDetails {
//    [nameTextField becomeFirstResponder];
    
    nameTextField.text = @"";
    descriptionTextView.text = @"Description";
    descriptionTextView.textColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customiseTextFields:(UITextField *)textField {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 3.0;
    textField.layer.borderWidth = 0.0f;
}


#pragma Mark Text View Delegate-------------------

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == descriptionTextView && [descriptionTextView.text isEqualToString:@"Description"]) {
        descriptionTextView.text = @"";
        descriptionTextView.textColor = [UIColor darkGrayColor];
        return;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == descriptionTextView && descriptionTextView.text.length == 0) {
        descriptionTextView.text = @"Description";
        descriptionTextView.textColor = [UIColor lightGrayColor];
        return;
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
   // [textField resignFirstResponder];
    if (textField == nameTextField) {
        [descriptionTextView becomeFirstResponder];
    }
    return YES;
}



- (IBAction)createButtonClicked:(id)sender {
    if (nameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter event name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self createEvent];
    self.tabBarController.tabBar.hidden = YES;
    [self.view endEditing:YES];
    [self setDateAndTimeForAnEvent];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCancelButtonClicked" object:nil userInfo:nil];
    
//    nameTextField.text = nil;
//    descriptionTextView.text = nil;
}

- (IBAction)switchToggled:(UISwitch *)settingSwitch {
    if (settingSwitch.on) {
        _isPublic = TRUE;
    }
    else {
        _isPublic = FALSE;
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCancelButtonClicked" object:nil userInfo:nil];
    [self.view endEditing:YES];
}

- (void)createEvent {
    NSString *eventType = @"";
    
    if (_isPublic) {
        eventType = @"PUB";
    }
    else {
        eventType = @"PVT";
    }
    
    NSDictionary *eventInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                               descriptionTextView.text,@"eventDescription",
                               @"0",@"eventid",
                               nameTextField.text,@"name",
                               eventType,@"eventType",
                               nil];
    
    [CoreDataInterface saveEventList:[NSArray arrayWithObjects:eventInfo, nil]];
    [CoreDataInterface saveAll];
}

- (void)setDateAndTimeForAnEvent {
    
    EventDateTimeViewController *eventDateTimeView = [self .storyboard instantiateViewControllerWithIdentifier:@"eventDateTimeView"];
    eventDateTimeView.title = nameTextField.text;
    
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == 0)"];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    Events*eventInfo;
    
    if (retData.count > 0) {
        eventInfo = [retData objectAtIndex:0];
        NSString *descriptionString = descriptionTextView.text;
        
        if ([descriptionString isEqualToString:@"Description"]) {
            descriptionString = @"";
        }
        eventInfo.eventDescription = descriptionString;
        eventDateTimeView.thisEvent = eventInfo;
    }
    [self.navigationController pushViewController:eventDateTimeView animated:YES];
}


@end
