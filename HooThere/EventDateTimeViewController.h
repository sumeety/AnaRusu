//
//  EventDateTimeViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 09/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"

@interface EventDateTimeViewController : UIViewController <UIAlertViewDelegate> {
    
    
    IBOutlet UIButton *endButton;
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *skipButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UILabel *lblEventStart;
    IBOutlet UILabel *lblEventEnds;
    IBOutlet UILabel *messageLabel;
}


@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) NSDate *eventStartDate;
@property (nonatomic, strong) NSDate *eventEndDate;
@property (nonatomic, strong) NSString *currentDateSelection;
@property (nonatomic, strong) Events *thisEvent;

- (IBAction)startDateButtonClicked:(id)sender;
- (IBAction)endDateButtonClicked:(id)sender;
- (IBAction)skipButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end
