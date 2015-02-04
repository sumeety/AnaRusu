//
//  GeofenceMonitor.h
//  Geofening
//
//  Created by Amit Gupta on 10/8/13.
//  Copyright (c) 2013 KH1386. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GeofenceMonitor : NSObject <CLLocationManagerDelegate>
+(GeofenceMonitor *) sharedObj;
+(void)stopMonitoringGeofencesForAllEvents;
-(void) addGeofence:(NSDictionary*) dict;
-(void) removeGeofence:(NSDictionary*) dict;
-(void)clearGeofences;
-(void) findCurrentFence;
-(BOOL)checkLocationManager;
@property CLLocationManager * locationManager;
@property (strong, nonatomic) NSNumber * speed;
@property (strong,nonatomic)NSMutableArray *isCheckin;
@property (nonatomic)BOOL *once;
@property (nonatomic,strong)GeofenceMonitor *fenceManager;

@end
