//
//  EventDateTimeViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 09/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "EventDateTimeViewController.h"
#import "EventLocationViewController.h"
#import "EventDetailsViewController.h"
#import "UtilitiesHelper.h"
#import "EventHelper.h"
#import "SelectLocationTypeViewController.h"
#import "HomeViewController.h"
#import "WhoThereViewController.h"

@interface EventDateTimeViewController ()

@end

@implementation EventDateTimeViewController

@synthesize datePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    nextButton.layer.cornerRadius=3;
    skipButton.layer.borderColor=[UIColor purpleColor].CGColor;
    skipButton.layer.borderWidth=1.0f;
    skipButton.layer.cornerRadius=3;
    [self loadDatePickerView];
    [self highlightSelectedButton:startButton];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)loadDatePickerView {
    _currentDateSelection = @"Start";
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self dateChanged:nil];
    
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE dd MMM yyyy hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePicker.date];
    if ([_currentDateSelection isEqualToString:@"Start"]) {
        lblEventStart.text = currentTime;
        _eventStartDate = self.datePicker.date;
    }
    else {
        lblEventEnds.text = currentTime;
        
        _eventEndDate = self.datePicker.date;
    }
}

-(void) highlightSelectedButton:(UIButton *)selectedButton{
   
    selectedButton.layer.borderWidth=1.0f;
    
    selectedButton.layer.borderColor=[UIColor purpleColor].CGColor;


}
- (IBAction)startDateButtonClicked:(id)sender {
     endButton.layer.borderWidth=0.0f;
    [self highlightSelectedButton:(UIButton *)sender];
    _currentDateSelection = @"Start";
    
    [self enterStartDate];
//    if ([_currentDateSelection isEqualToString:@"End"]){
//        BOOL dateCheck = [EventHelper compareStartDate:_eventEndDate endDate:_eventStartDate endDateSelected:TRUE];
//        if (dateCheck == TRUE) {
//            
//        }
//        else {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"HooThere" message:@"Please enter a valid start date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alertView show];
//        }
//        return;
//    }
    [self enterStartDate];
}

- (void)enterStartDate {
    
    _currentDateSelection = @"Start";
    messageLabel.text = @"Please select the start date of your event";
}

- (IBAction)endDateButtonClicked:(id)sender {
    startButton.layer.borderWidth=0.0f;
    [self highlightSelectedButton:(UIButton *)sender];
    
    if (_eventStartDate == nil || [_eventStartDate isEqual:[NSNull null]]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter start date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    _currentDateSelection = @"End";
    messageLabel.text = @"Please select the end date of your event";
    
//    NSDate *today = [NSDate date];
//    
//    BOOL dateCheck = [EventHelper compareStartDate:_eventStartDate endDate:today endDateSelected:FALSE];
//    if (dateCheck == TRUE) {
//        NSLog(@"True");
//        
//    }
//    else {
//        NSLog(@"False");
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"HooThere" message:@"Please enter a valid start date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alertView show];
//    }
    
}

- (IBAction)skipButtonClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"If you don't set the time then we won't be able to let you know when people get to your event. Skip Anyway?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (IBAction)nextButtonClicked:(id)sender {
    NSDate *today = [NSDate date];
    
    BOOL startDateCheck = [EventHelper compareStartDate:_eventStartDate endDate:today endDateSelected:FALSE];
    
    if (!startDateCheck) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter a valid start date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    BOOL endDateCheck = [EventHelper compareStartDate:_eventEndDate endDate:_eventStartDate endDateSelected:TRUE];
    if (!endDateCheck) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter a valid end date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    BOOL dateCheck = [EventHelper compareStartDate:_eventEndDate endDate:_eventStartDate endDateSelected:TRUE];
    if (dateCheck == TRUE) {
        
        NSArray *startDate = [lblEventStart.text componentsSeparatedByString:@" "];
        NSArray *endDate = [lblEventEnds.text componentsSeparatedByString:@" "];

        _thisEvent.name = self.title;
        NSString *startDateStr;
        NSString *endDateStr;
        if (startDate.count == 6) {
            startDateStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",[startDate objectAtIndex:1],[startDate objectAtIndex:2],[startDate objectAtIndex:3],[startDate objectAtIndex:4],[startDate objectAtIndex:5]];
            endDateStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",[endDate objectAtIndex:1],[endDate objectAtIndex:2],[endDate objectAtIndex:3],[endDate objectAtIndex:4],[endDate objectAtIndex:5]];
            
            _thisEvent.startDateTime = [EventHelper createTimeStamp:startDateStr withDateFormat:@"dd MMM yyyy hh:mm a"];
            _thisEvent.endDateTime = [EventHelper createTimeStamp:endDateStr withDateFormat:@"dd MMM yyyy hh:mm a"];
        }
        else {
            startDateStr = [NSString stringWithFormat:@"%@ %@ %@ %@",[startDate objectAtIndex:1],[startDate objectAtIndex:2],[startDate objectAtIndex:3],[startDate objectAtIndex:4]];
            endDateStr = [NSString stringWithFormat:@"%@ %@ %@ %@",[endDate objectAtIndex:1],[endDate objectAtIndex:2],[endDate objectAtIndex:3],[endDate objectAtIndex:4]];
            
            _thisEvent.startDateTime = [EventHelper createTimeStamp:startDateStr withDateFormat:@"dd MMM yyyy hh:mm"];
            _thisEvent.endDateTime = [EventHelper createTimeStamp:endDateStr withDateFormat:@"dd MMM yyyy hh:mm"];
        }
        
        NSLog(@"date %@",startDateStr);
        
        //NSLog(@"%@",endDateStr);
        
        
        [CoreDataInterface saveAll];
        
        SelectLocationTypeViewController *selectLocationTypeView = [self.storyboard instantiateViewControllerWithIdentifier:@"selectLocationTypeView"];
        selectLocationTypeView.title = self.title;
        selectLocationTypeView.thisEvent = _thisEvent;
        [self.navigationController pushViewController:selectLocationTypeView animated:YES];
        
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please enter a valid end date of an event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma Mark Alert View Delegate-------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        _thisEvent.name = self.title;
        _thisEvent.startDateTime = nil;
        _thisEvent.endDateTime = nil;
        
        [CoreDataInterface saveAll];
        
        NSMutableDictionary *eventInfo = [[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:_thisEvent type:nil] mutableCopy];
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
        NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/create",kwebUrl,uid];
        
        [UtilitiesHelper getResponseFor:eventInfo url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             
             if (success) {
                 NSLog(@"Json : %@",jsonDict);
                 [CoreDataInterface saveEventList:[NSArray arrayWithObjects:jsonDict, nil]];
                 EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
                 eventDetailsView.eventId = [jsonDict objectForKey:@"id"];
                 eventDetailsView.statistics=[jsonDict objectForKey:@"statistics"];
                 eventDetailsView.hostName = [[CoreDataInterface getInstanceOfMyInformation] firstName];
                 eventDetailsView.hostId=uid;

                 
                 NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                 NSMutableArray *newArray = [[NSMutableArray alloc] init];
                 
                 for (int i = 0; i < navigationViewsArray.count ; i++) {
                     UIViewController *viewController = [navigationViewsArray objectAtIndex:i];
                     [newArray addObject:viewController];
                     
                     if ([viewController isKindOfClass:[WhoThereViewController class]]) {
                         NSLog(@"yes");
                         break;
                     }
                 }
                 [newArray addObject:eventDetailsView];
                 [self.navigationController setViewControllers:newArray animated:YES];
                 self.tabBarController.tabBar.hidden = NO;

             }
             [CoreDataInterface deleteThisEvent:_thisEvent];
         }];
        
    }
}

@end
