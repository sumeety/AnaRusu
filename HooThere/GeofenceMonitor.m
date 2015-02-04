//
//  GeofenceMonitor.m
//  Geofening
//
//  Created by Amit Gupta on 10/8/13.
//  Copyright (c) 2014 MobileStorm. All rights reserved.
//

#import "GeofenceMonitor.h"
#import "CoreDataInterface.h"
#import "UtilitiesHelper.h"
#import "WhoThereViewController.h"

@implementation GeofenceMonitor
@synthesize locationManager, speed;

static GeofenceMonitor * shared =nil;

+(GeofenceMonitor *) sharedObj
{
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        shared = [[GeofenceMonitor alloc] init];
//        _fe
        //NSLog(@"init done");
    });
    return shared;
}

- (CLRegion*)dictToRegion:(NSDictionary*)dictionary
{
    NSString *identifier = [dictionary valueForKey:@"identifier"];
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
   // regionRadius=300.0f;
    if(regionRadius > locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = locationManager.maximumRegionMonitoringDistance;
    }

    NSString *version = [[UIDevice currentDevice] systemVersion];
    CLRegion * region =nil;
    
    if([version floatValue] >= 7.0f) //for iOS7
    {
        region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                   radius:regionRadius
                                               identifier:identifier];
    }
    else // iOS 7 below
    {
        region = [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                       radius:regionRadius
                                                   identifier:identifier];
    }
    return  region;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self setupObservers];
        if (self.checkLocationManager)
            [self.locationManager startUpdatingLocation];
    }
    return self;
}

- (void)setupObservers
{
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self
            selector:@selector(applicationDidEnterForeground:)
                name:UIApplicationDidBecomeActiveNotification
              object:[UIApplication sharedApplication]];
    [def addObserver:self
            selector:@selector(applicationDidEnterBackground:)
                name:UIApplicationWillResignActiveNotification
              object:[UIApplication sharedApplication]];
}

- (void)applicationDidEnterForeground:(NSNotification *)notification
{
    if (self.checkLocationManager)
        [self.locationManager stopMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (self.checkLocationManager)
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
}

-(void) showMessage:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:Nil, nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    [alertView show];
}
-(BOOL) checkLocationManager
{
    if(![CLLocationManager locationServicesEnabled])
    {
        [self showMessage:@"You need to enable Location Services"];
        return  FALSE;
    }
    if(![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]])
    {
        [self showMessage:@"Region monitoring is not available for this Class"];
                return  FALSE;
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        [self showMessage:@"You need to authorize Location Services for the APP"];
        return  FALSE;
    }
    return TRUE;
}
-(void) addGeofence:(NSDictionary*) dict
{
    
    CLRegion * region = [self dictToRegion:dict];
    
   // NSLog(@"region...%@",region);
    [locationManager startMonitoringForRegion:region ];
}
-(void) findCurrentFence
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    //NSLog(@"finding current fence");
    
    if([version floatValue] >= 7.0f) //for iOS7
    {
        NSArray * monitoredRegions = [locationManager.monitoredRegions allObjects];
        for(CLRegion *region in monitoredRegions)
         {
             [locationManager requestStateForRegion:region];
         }
    }
    else
    {
        [locationManager startUpdatingLocation];
    }

}

-(void) removeGeofence:(NSDictionary*) dict
{
    CLRegion * region = [self dictToRegion:dict];
    [locationManager stopMonitoringForRegion:region];

}

+(void)stopMonitoringGeofencesForAllEvents {
    [shared clearGeofences];
    shared = nil;
}


-(void) clearGeofences
{
    NSArray * monitoredRegions = [self.locationManager.monitoredRegions allObjects];
    for(CLRegion *region in monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

/*
    Delegate Methods
 */

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside)
    {
        [self locationManager:locationManager didEnterRegion:region];
    }
    else if(state == CLRegionStateOutside)
    {
        [self locationManager:locationManager didExitRegion:region];
    }
    else{
        NSLog(@"##Unknown state  Region - %@", region.identifier);
    }
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Started monitoring %@ region", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLCircularRegion *)region
{
    // Send Post request to mobileStorm server for entry callback
    float lat = manager.location.coordinate.latitude;
    float longi = manager.location.coordinate.longitude;
    NSString *latitude = [NSString stringWithFormat:@"%f", lat];
    NSString *longitude = [NSString stringWithFormat:@"%f", longi];
    NSLog(@"Lat and Long at Fence Exit = %@ , %@", latitude, longitude);
    
    CLLocationCoordinate2D centerCoords =region.center;
    NSLog(@"center coords %f, %f", region.center.latitude, region.center.longitude );
    CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(lat,longi);
    NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
    NSLog(@"Distance : %@", currentLocationDistance);
    CLLocationDistance radius = region.radius;
    NSLog(@"Radius : %f", radius);
    NSString *log = [NSString stringWithFormat:@"Fence Entry %@ User's Lat/Long = %f / %f | Region Center Lat/Long = %f / %f | Radius of Region in meters = %f | user's current location distance from region center = %@", region.identifier, currentCoords.latitude, currentCoords.longitude, centerCoords.latitude, centerCoords.longitude, radius, currentLocationDistance ];
    [self localizationLogger:log];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/checkin",kwebUrl,region.identifier];
    
    if (!region.radius > 0 || !region.identifier > 0) {
        return;
    }
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              uid ,@"id",
                              @"AUTO",@"checkInType",
                              nil];
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",region.identifier];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    //NSLog(@"retData %@",retData);
    if(retData.count>0){
        NSLog(@"status of guest ...%@",[[retData objectAtIndex:0] guestStatus] );
    
    if(![[[retData objectAtIndex:0] guestStatus] isEqualToString:@"HT"])
    {
        NSString *status = [[retData objectAtIndex:0] guestStatus];
        [[retData objectAtIndex:0] setGuestStatus:@"HT"];
        
        [UtilitiesHelper getResponseFor:postDict url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             [self.locationManager stopMonitoringForRegion:region];
             
             if (success) {
                 [self.locationManager stopMonitoringForRegion:region];
                 
                 if (retData.count > 0) {
                     Events *eventInfo = [retData objectAtIndex:0];
                     eventInfo.guestStatus=@"HT";
                     
                     NSMutableDictionary *statistics= [[UtilitiesHelper stringToDictionary:[eventInfo statistics]] mutableCopy];
                     NSInteger goingThereCount = [[statistics objectForKey:@"hoothereCount"] integerValue]+1;
                     
                     [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"hoothereCount"];
                     eventInfo.statistics = [NSString stringWithFormat:@"%@",statistics];
                    [CoreDataInterface saveAll];
                     NSString *message = [NSString stringWithFormat:@"You have reached %@",eventInfo.name];
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"kAutoCheckInCheckOutHappened" object:nil];
                 }
             }
             else {
                 [[retData objectAtIndex:0] setGuestStatus:status];
             }
         }];
    }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLCircularRegion *)region
{
    // Send Post request to mobileStorm server for exit callback
    float lat = manager.location.coordinate.latitude;
    float longi = manager.location.coordinate.longitude;
    NSString *latitude = [NSString stringWithFormat:@"%f", lat];
    NSString *longitude = [NSString stringWithFormat:@"%f", longi];
    NSLog(@"Lat and Long at Fence Exit = %@ , %@", latitude, longitude);
    
    CLLocationCoordinate2D centerCoords =region.center;
    NSLog(@"Exit center coords %f, %f", region.center.latitude, region.center.longitude );
    CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(lat,longi);
    NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
    NSLog(@"Exit Distance : %@", currentLocationDistance);
    CLLocationDistance radius = region.radius;
    NSLog(@"Exit Radius : %f", radius);
    NSString *log = [NSString stringWithFormat:@"Fence Exit %@ User's Lat/Long = %f / %f | Region Center Lat/Long = %f / %f | Radius of Region in meters = %f | user's current location distance from region center = %@", region.identifier, currentCoords.latitude, currentCoords.longitude, centerCoords.latitude, centerCoords.longitude, radius, currentLocationDistance ];
    [self localizationLogger:log];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/checkout",kwebUrl,region.identifier];
    
    if (!region.radius > 0 || !region.identifier > 0) {
        return;
    }
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              uid ,@"id",
                              nil];
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",region.identifier];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    //NSLog(@"retData %@",retData);
    if(retData.count>0){
        NSLog(@"status of guest ...%@",[[retData objectAtIndex:0] guestStatus] );
        
        if([[[retData objectAtIndex:0] guestStatus] isEqualToString:@"HT"])
        {
            [[retData objectAtIndex:0] setGuestStatus:@"WT"];
            [UtilitiesHelper getResponseFor:postDict url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
             {
                 [self.locationManager stopMonitoringForRegion:region];
                 
                 if (success) {
                     [self.locationManager stopMonitoringForRegion:region];
                     
                     if (retData.count > 0) {
                         Events *eventInfo = [retData objectAtIndex:0];
                         eventInfo.guestStatus=@"WT";
                         
                         NSMutableDictionary *statistics= [[UtilitiesHelper stringToDictionary:[eventInfo statistics]] mutableCopy];
                         NSInteger goingThereCount = [[statistics objectForKey:@"hoothereCount"] integerValue]-1;
                         
                         [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"hoothereCount"];
                         eventInfo.statistics = [NSString stringWithFormat:@"%@",statistics];
                         [CoreDataInterface saveAll];
                         NSString *message = [NSString stringWithFormat:@"You have left %@",eventInfo.name];
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                         [alertView show];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"kAutoCheckInCheckOutHappened" object:nil];
                     }
                 }
                 else {
                     [[retData objectAtIndex:0] setGuestStatus:@"HT"];
                 }
             }];
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"error for region monitoring :: %@", [error localizedDescription]);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    speed =  [[NSNumber alloc] initWithFloat:location.speed];
//    NSLog(@"SPEED of USER : %@", speed);
//    NSLog(@"Users location : %+.9f / %+.9f", location.coordinate.latitude, location.coordinate.longitude);
    NSDate* eventDate = [NSDate date];
    BOOL isRecent;
    NSDate *lastEvent = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastEvent"];
    NSTimeInterval howRecent = [eventDate timeIntervalSinceDate:lastEvent];
    NSString *log = [NSString stringWithFormat:@"User's latest location : %f, %f and speed = %@", location.coordinate.latitude, location.coordinate.longitude, speed ];
    [self localizationLogger:log];
    
    double seconds = 1;
    NSInteger timeBetweenDates = howRecent / seconds;
    
    if (isnan(howRecent)) {
        isRecent = TRUE;
    }
    else {
        if(timeBetweenDates < 60){
            isRecent = FALSE;
        }
        else{
            isRecent = TRUE;
        }
    }
    

    BOOL searchGeofence = FALSE;
    
  // WhoThereViewController *wooThereView=[[WhoThereViewController alloc]init];
    
    if(isRecent){
        [shared clearGeofences];
        
        [[NSUserDefaults standardUserDefaults] setValue:eventDate forKey:@"lastEvent"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSMutableArray *listOfGeofence = [self getEventsOfCurrentDate];
       
        for (int i = 0; i < listOfGeofence.count; i++) {
            
            Events *geofenceInfo = [listOfGeofence objectAtIndex:i];
            NSMutableDictionary * fence = [NSMutableDictionary new];
            
            [fence setValue:[NSString stringWithFormat:@"%@",geofenceInfo.eventid] forKey:@"identifier"];
            [fence setValue:geofenceInfo.latitude forKey:@"latitude"];
            [fence setValue:geofenceInfo.longitude forKey:@"longitude"];
            [fence setValue:geofenceInfo.radius forKey:@"radius"];
            
            //NSLog(@"in if condition");
            //    [regions addObject:fence];
            if(![geofenceInfo.eventid isEqualToString:@"0"])
            {
                NSArray * monitoredRegions = [locationManager.monitoredRegions allObjects];
                NSLog(@"motiored Regions %@",monitoredRegions);
                    if([self checkLocationManager])
                        {
                            if(![monitoredRegions containsObject:fence ])
                            {   [shared addGeofence:fence];
                                searchGeofence = TRUE;
                            }
                        }
            }
        }
        if (searchGeofence) {
            [shared findCurrentFence];
        }
    }
}

- (NSMutableArray *)getEventsOfCurrentDate {
    NSMutableArray *listOfEvents = [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:nil andSortkey:@"startDateTime" isSortAscending:YES];
    NSMutableArray *geofenceList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < listOfEvents.count; i++) {
        Events *geofenceInfo = [listOfEvents objectAtIndex:i];
        
        BOOL validateDate = [self validateEventDate:geofenceInfo.startDateTime end:geofenceInfo.endDateTime];
        
        if (validateDate) {
            [geofenceList addObject:geofenceInfo];
        }
    }
    
    NSLog(@"list of Events %@",listOfEvents);
    return geofenceList;
}

//- (BOOL)validateEventDate:(NSString *)timestamp {
//    //    endPublishDate = "November 27, 2014";
//    NSDate *startDateTime = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/1000.0];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"dd MM yyyy"];
//    NSString *dateString = [formatter stringFromDate:startDateTime];
//    NSDate *today = [NSDate date];
//    
//    
//    //Other Date say date2 is of type NSDate again
//    NSString *date2String = [formatter stringFromDate:today];
//    
//    //Comparison of Two dates by its conversion into string as below
//    if([date2String isEqualToString:dateString])
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}

- (BOOL)validateEventDate:(NSString *)timeStamp end:endtimeStamp{
 double todayTimeStamp=[[NSDate date] timeIntervalSince1970];
     
    double eventTimeStamp=[timeStamp doubleValue]/1000.0;
    double eventEndTimeStamp=[endtimeStamp doubleValue]/1000.0;
    
    NSLog(@"todayTimeStamp %f, eventTimeStamp %f eventEndTimeStamp %f",todayTimeStamp,eventTimeStamp,eventEndTimeStamp);
    if(todayTimeStamp>=eventTimeStamp && todayTimeStamp<=eventEndTimeStamp)
    {
        NSLog(@"monitored");
        return YES;
        
    }
    else
    {NSLog(@"not monitored");
        return NO;
    }
 }

//Helper Functions.
- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
}


// this is when beacon is found
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    // do domething when beacon is found
}

-(void)localizationLogger:(NSString *)log
{
    NSString *content = [NSString stringWithFormat:@"\n %@ : %@", [NSDate date], log];
    //Get the file path
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"Localization.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    //append text to file (you'll probably want to add a newline every write)
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}



@end
