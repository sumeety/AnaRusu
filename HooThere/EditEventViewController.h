//
//  EditEventViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 31/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Events.h"

@interface EditEventViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate> {

    IBOutlet UITextField            *nameTextField;
    IBOutlet UITextView             *descriptionTextView;
    IBOutlet UILabel                *lblEventStart;
    IBOutlet UILabel                *lblEventEnds;
    IBOutlet UILabel                *messageLabel;
    
    IBOutlet UITextField            *venueTextField;
    IBOutlet UITextField            *cityTextField;
    IBOutlet UITextField            *stateTextField;
    IBOutlet UITextField            *countryTextField;
    IBOutlet UITextField            *zipCodeTextField;
    
    IBOutlet UITextView             *streetAddress;
    IBOutlet UISwitch *settingsSwitch;
}
@property (strong, nonatomic) IBOutlet UILabel *datePickerLabel;
@property (strong, nonatomic) IBOutlet UIButton *setGeoFanceButton;

@property (nonatomic, strong) Events *thisEvent;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) NSDate *eventStartDate;
@property (nonatomic, strong) NSDate *eventEndDate;
@property (nonatomic, strong) NSString *currentDateSelection;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *endButton;
@property (strong, nonatomic) IBOutlet UILabel *countyLabel;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *streetAddressLabel;
@property (strong, nonatomic) IBOutlet UITextField *cityLabel;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UILabel *zipLabel;
@property (nonatomic)BOOL isEditable;
@property (strong, nonatomic) IBOutlet UILabel *venueNameLabel;
@property (nonatomic) BOOL  isPublic;

- (IBAction)switchToggled:(UISwitch *)settingSwitch;
- (IBAction)startDateButtonClicked:(id)sender;
- (IBAction)endDateButtonClicked:(id)sender;
- (IBAction)setGeoFenceButtonClicked:(id)sender;
@end
