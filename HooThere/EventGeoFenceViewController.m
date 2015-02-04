//
//  EventGeoFenceViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 09/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "EventGeoFenceViewController.h"
#import "EventDetailsViewController.h"
#import "UtilitiesHelper.h"
#import "WhoThereViewController.h"

#define METERS_PER_MILE 1609.344

@interface EventGeoFenceViewController ()

@end

@implementation EventGeoFenceViewController {
    Annotation *_annotation;
    TSCustomCircleView *_circleView;
}

@synthesize placeDictionary;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateMapsWithLatLong];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    self.doneButton.layer.cornerRadius=3;
    self.skipButton.layer.cornerRadius=3;
    self.skipButton.layer.borderWidth=1.0f;
    self.skipButton.layer.borderColor=[UIColor purpleColor].CGColor;
    
}

- (IBAction)skipButtonClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"If you don't set the location then we won't be able to let you know when people get to you event. Skip anyway?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (IBAction)doneButtonClicked:(id)sender {
    [sender setTitle:@"Doing..."];
    [self createEvent];
}

- (IBAction)onSliderChanged:(UISlider *)sender {
    //    [_circleView pauseAnimation];
    _circleView.radius = sender.value;
    
    [_circleView setNeedsDisplay];
}

- (IBAction)onSliderTouchUpInside:(UISlider *)sender {
    //    [_circleView resumeAnimation];
}

- (IBAction)onStartPressed:(id)sender {
    [_circleView startAnimating];
}

- (IBAction)onStopPressed:(id)sender {
    [_circleView stopAnimating];
}

- (IBAction)onPausePressed:(id)sender {
    [_circleView pauseAnimation];
}

- (IBAction)onResumePressed:(id)sender {
    [_circleView resumeAnimation];
}

- (void)_addCircleOnCurrentLocationWithRadius:(CGFloat)radius {
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:_annotation.coordinate radius:radius];
    [self.mapView addOverlay:circle level:MKOverlayLevelAboveRoads];
}

- (void)updateMapsWithLatLong {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _latitudeStr.floatValue;
    coordinate.longitude = _longitudeStr.floatValue;
    
    [self setMapCordinate:coordinate];
}

- (void)setMapCordinate:(CLLocationCoordinate2D)coordinate {
    _annotation = [[Annotation alloc] init];
    [_annotation setCoordinate: coordinate];
    [self.mapView addAnnotation:_annotation];
    [self.mapView setCenterCoordinate:_annotation.coordinate animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_annotation.coordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:YES];
    [self _addCircleOnCurrentLocationWithRadius:_slider.value];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
    view.pinColor = MKPinAnnotationColorPurple;
    view.draggable=YES;
    return view;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    if (!_circleView) {
        //_circleView.hidden=NO;
        _circleView = [[TSCustomCircleView alloc] initWithCircle:overlay];
        _circleView.fillColor = [UIColor redColor];
        _circleView.shouldShowBackgroundViewOnStop = YES;
        if(_isEditing) {
            _circleView.radius = _slider.value;
        }
    }
    return _circleView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    //_circleView.hidden=NO;
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        _circleView.coordinate=droppedAt;
        [_circleView setNeedsDisplay];
        
        
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}






#pragma Mark Alert View Delegate-------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        [self createEvent];
    }
}

- (void)createEvent {
    _thisEvent.radius =[NSString stringWithFormat:@"%f", _circleView.radius] ;
    _thisEvent.latitude=[NSString stringWithFormat:@"%f", _circleView.coordinate.latitude];
    _thisEvent.longitude=[NSString stringWithFormat:@"%f", _circleView.coordinate.longitude];
    
    [CoreDataInterface saveAll];
    NSMutableDictionary *eventInfo = [[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:_thisEvent type:nil] mutableCopy];
    NSLog(@"eventInfo at GeoFance **** %@",eventInfo);
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = @"";
    NSString *requestType = @"";
    if(_isEditing)
    {
        urlString = [NSString stringWithFormat:@"%@/event/edit/%@",kwebUrl,_thisEvent.eventid];
        requestType = @"PUT";
        [eventInfo removeObjectForKey:@"statistics"];
        [eventInfo removeObjectForKey:@"user"];
        [eventInfo setObject:[NSString stringWithFormat:@"%@",uid] forKey:@"modifiedBy"];
    }
    else
    {
        urlString = [NSString stringWithFormat:@"%@/user/%@/event/create",kwebUrl,uid];
        requestType = @"POST";
    }
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    [UtilitiesHelper getResponseFor:eventInfo url:[NSURL URLWithString:urlString] requestType:requestType complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         self.view.userInteractionEnabled = YES;
         if (success) {
             NSLog(@"Json : %@",jsonDict);
             
             [self loadEventDetails:jsonDict];
         }
         [CoreDataInterface deleteThisEvent:_thisEvent];
     }];
}

- (void)loadEventDetails:(NSDictionary *)jsonDict {
    self.tabBarController.tabBar.hidden = NO;

    [CoreDataInterface saveEventList:[NSArray arrayWithObjects:jsonDict, nil]];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];

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

@end
