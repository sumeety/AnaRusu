//
//  EventLocationViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 09/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoreDataInterface.h"

@interface EventLocationViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate> {
    
    IBOutlet UITextField            *venueTextField;
    IBOutlet UITextField            *cityTextField;
    IBOutlet UITextField            *stateTextField;
    IBOutlet UITextField            *countryTextField;
    IBOutlet UITextField            *zipCodeTextField;

    IBOutlet UITextView             *streetAddress;

    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *skipButton;
}


@property (strong, nonatomic)   CLLocationManager   *locationManager;
@property (nonatomic, strong)   NSString            *latitudeStr;
@property (nonatomic, strong)   NSString            *longitudeStr;
@property (nonatomic)   BOOL            selectCurrentLocation;
@property (nonatomic, strong) Events *thisEvent;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic)BOOL isEditing;

- (IBAction)searchButtonClicked:(id)sender;
- (IBAction)currentLocationButtonClicked:(id)sender;
- (IBAction)skipButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end
