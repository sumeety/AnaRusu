//
//  EventLocationViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 09/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "EventLocationViewController.h"
#import "UtilitiesHelper.h"
#import "EventGeoFenceViewController.h"
#import "EventDetailsViewController.h"
#import "SearchLocationViewController.h"
#import "LocationHandler.h"
#import "WhoThereViewController.h"

@interface EventLocationViewController ()

@end

@implementation EventLocationViewController

@synthesize locationManager, latitudeStr, longitudeStr;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNextPage) name:@"kLocationSelected" object:nil];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];

    _selectCurrentLocation = FALSE;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self captalizeTextField];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    if (_isEditing) {
        skipButton.hidden = YES;
        nextButton.hidden = YES;
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonClicked:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [self loadEventAddressDetails];
    }
    else {
        skipButton.layer.borderWidth = 1.0;
        skipButton.layer.borderColor = [UIColor purpleColor].CGColor;
        skipButton.layer.cornerRadius=3;
        nextButton.layer.cornerRadius=3;
    }
    
    
    
    [self.locationManager startUpdatingLocation];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)loadEventAddressDetails {
    venueTextField.text = _thisEvent.venueName;
    streetAddress.text = _thisEvent.streetName;
    cityTextField.text = _thisEvent.city;
    stateTextField.text = _thisEvent.state;
    countryTextField.text = _thisEvent.country;
    zipCodeTextField.text = _thisEvent.zipcode;
    
    if (![streetAddress.text isEqualToString:@"Street Address"]) {
        streetAddress.textColor = [UIColor blackColor];
    }
}

- (void)loadNextPage {
//    [self performSelector:@selector(locationSelected) withObject:nil afterDelay:0.1];
}

- (void)locationSelected {
    if (_isEditing) {
        NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [navigationViewsArray removeLastObject];
        [navigationViewsArray removeLastObject];
        [self.navigationController setViewControllers:navigationViewsArray animated:NO];
    }
    else {
        EventGeoFenceViewController *eventGeoFenceView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventGeoFenceView"];
        eventGeoFenceView.isEditing=NO;
        if (_selectCurrentLocation) {
            eventGeoFenceView.longitudeStr = self.longitudeStr;
            eventGeoFenceView.latitudeStr = self.latitudeStr;
        }
        eventGeoFenceView.title = self.title;
        eventGeoFenceView.thisEvent = _thisEvent;
        [self .navigationController pushViewController:eventGeoFenceView animated:YES];
    }
}

-(void) captalizeTextField{
    venueTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    cityTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    streetAddress.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    stateTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    countryTextField .autocapitalizationType=UITextAutocapitalizationTypeSentences;
    zipCodeTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.latitudeStr = [NSString stringWithFormat:@"%0.8f",currentLocation.coordinate.latitude];
        self.longitudeStr = [NSString stringWithFormat:@"%0.8f",currentLocation.coordinate.longitude];
    }
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)getCurrentLocation {
    [_activityIndicator startAnimating];
    [LocationHandler locationLatitude:[self.latitudeStr floatValue] Longitude:[self.longitudeStr floatValue]
                     complettionBlock:^(BOOL success,NSString *locationName)
     {
         [_activityIndicator stopAnimating];
         NSLog(@"Location Name : %@",locationName);
         
         NSArray *locationArray1 = [locationName componentsSeparatedByString:@","];
         
         NSMutableArray *locationArray = [[NSMutableArray alloc] initWithArray:locationArray1];
         
         if (locationArray.count == 4 || locationArray.count > 4) {
             NSMutableArray *stateZipArray = [[[locationArray objectAtIndex:locationArray.count-2] componentsSeparatedByString:@" "] mutableCopy];
             
             
             cityTextField.text = [locationArray objectAtIndex:locationArray.count-3];
             if (stateZipArray.count > 2) {
                 zipCodeTextField.text = [stateZipArray lastObject];
                 [stateZipArray removeLastObject];
                 
                 NSString *state =@"";
                 
                 for (int j = 0; j < stateZipArray.count; j++) {
                     state = [NSString stringWithFormat:@"%@ %@",state,[stateZipArray objectAtIndex:j]];
                 }
                 stateTextField.text = state;
                 
             }
             countryTextField.text = [locationArray objectAtIndex:locationArray.count-1];
             
             [locationArray removeLastObject];
             [locationArray removeLastObject];
             [locationArray removeLastObject];
             
             NSString *location =@"";
             
             for (int j = 0; j < locationArray.count; j++) {
                 location = [NSString stringWithFormat:@"%@ %@",location,[locationArray objectAtIndex:j]];
             }
             streetAddress.text = location;
             streetAddress.textColor = [UIColor darkGrayColor];
         }
     }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)searchButtonClicked:(id)sender {
    
}

- (IBAction)currentLocationButtonClicked:(id)sender {
    _selectCurrentLocation = TRUE;
    [self performSelector:@selector(getCurrentLocation) withObject:nil afterDelay:0.001];
    [self.locationManager stopUpdatingLocation];
}


- (IBAction)skipButtonClicked:(id)sender {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"If you don't set the location then we won't be able to let you know when people get to you event. Skip anyway?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}
- (IBAction)nextButtonClicked:(id)sender {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (venueTextField.text.length == 0 || streetAddress.text.length == 0 || cityTextField.text.length == 0 || stateTextField.text.length == 0 || zipCodeTextField.text.length == 0 || countryTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please fill all details about venue." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    _thisEvent.venueName = venueTextField.text;
    _thisEvent.streetName = streetAddress.text;
    _thisEvent.city = cityTextField.text;
    _thisEvent.country = countryTextField.text;
    _thisEvent.state = stateTextField.text;
    _thisEvent.zipcode = zipCodeTextField.text;
    _thisEvent.latitude = self.latitudeStr;
    _thisEvent.longitude = self.longitudeStr;
    _thisEvent.address = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",streetAddress.text,cityTextField.text,stateTextField.text,zipCodeTextField.text,countryTextField.text];
    [CoreDataInterface saveAll];
    
    [self getManualEnteredLocationCoordinates];
}

- (void)getManualEnteredLocationCoordinates {
    [_activityIndicator startAnimating];
    [LocationHandler getLocationCoordinates:_thisEvent.address complettionBlock:^(BOOL success,NSDictionary *placeInfo)
     {
         [_activityIndicator stopAnimating];
         if (success) {
             self.latitudeStr = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] stringValue];
             self.longitudeStr = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] stringValue];
             
             _selectCurrentLocation = TRUE;
         }
         [self locationSelected];
     }];
}

#pragma Mark Alert View Delegate-------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == 0)"];
        
        NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
        
        if (retData.count > 0) {
            NSDictionary *eventInfo = [UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:[retData objectAtIndex:0] type:nil];
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
                 }
                 [CoreDataInterface deleteThisEvent:[retData objectAtIndex:0]];
                 self.tabBarController.tabBar.hidden = NO;

             }];
        }
        
        
    }
}

#pragma Mark Text View Delegate-------------------

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == streetAddress && [streetAddress.text isEqualToString:@"Street Address"]) {
        streetAddress.text = @"";
        streetAddress.textColor = [UIColor darkGrayColor];
        return;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == streetAddress && streetAddress.text.length == 0) {
        streetAddress.text = @"Street Address";
        streetAddress.textColor = [UIColor lightGrayColor];
        return;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField==venueTextField)
    [streetAddress becomeFirstResponder];
    else if (textField == cityTextField) {
        [stateTextField becomeFirstResponder];
    }
    else if (textField == stateTextField) {
        [countryTextField becomeFirstResponder];
    }
    else if (textField == countryTextField) {
        [zipCodeTextField becomeFirstResponder];
    }
    else if(textField==zipCodeTextField)
    [self hideKeyboard];
    
    return YES;
}


@end
