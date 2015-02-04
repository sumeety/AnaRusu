//
//  AppDelegate.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

#import "GeofenceMonitor.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) CLLocationManager   *locationManager;

@property (nonatomic,strong)GeofenceMonitor *geofenceMonitor;


@property (strong, nonatomic)NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic)NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic)NSString *selectedFriendId;
@property BOOL *isFromMe;

@end
