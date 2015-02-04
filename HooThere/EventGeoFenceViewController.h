//
//  EventGeoFenceViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 09/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "TSCustomCircleView.h"
#import "CoreDataInterface.h"

@interface EventGeoFenceViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) NSMutableDictionary  *placeDictionary;
@property (strong,nonatomic)NSString *longitudeStr;
@property (strong,nonatomic)NSString *latitudeStr;
@property (nonatomic)BOOL isEditing;
@property(nonatomic )NSInteger radius;
@property (strong,nonatomic)Events *thisEvent;

- (IBAction)onSliderChanged:(UISlider *)sender;
- (IBAction)onSliderTouchUpInside:(UISlider *)sender;

- (IBAction)onStartPressed:(id)sender;
- (IBAction)onStopPressed:(id)sender;
- (IBAction)onPausePressed:(id)sender;
- (IBAction)onResumePressed:(id)sender;

- (IBAction)skipButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;

@end
