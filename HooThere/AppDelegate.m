//
//  AppDelegate.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height > 500)
        {
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            UIStoryboard *iPhone35Storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            // Instantiate the initial view controller object from the storyboard
            UIViewController *initialViewController = [iPhone35Storyboard instantiateInitialViewController];
            
            // Instantiate a UIWindow object and initialize it with the screen size of the iOS device
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            
            // Set the initial view controller to be the root view controller of the window object
            //            self.window.rootViewController  = initialViewController;
            [self.window setRootViewController:initialViewController];
            
            // Set the window object to be the key window and show it
            [self.window makeKeyAndVisible];
        }
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
//    NSLog(@"start updating Location");
//    NSArray * monitoredRegions = [self.locationManager.monitoredRegions allObjects];
//    for(CLRegion *region in monitoredRegions) {
//        [self.locationManager stopMonitoringForRegion:region];
//    }
//    
//    [self.locationManager startUpdatingLocation];
//    
//   self.geofenceMonitor = [[GeofenceMonitor alloc] init];
    
//    //self.geofenceMonitor.delegate = self;
//    //self.geofenceMonitor.desiredAccuracy = kCLLocationAccuracyBest;
//    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    
//    NSLog(@"start updating Location");

    //[self.geofenceMonitor ];
    
    
//    self.locationTracker = [[LocationTracker alloc]init];
//    [self.locationTracker startLocationTracking];
//    
//    //Send the best location to server every 60 seconds
//    //You may adjust the time interval depends on the need of your app.
//    NSTimeInterval time = 60.0;
//    self.locationUpdateTimer =
//    [NSTimer scheduledTimerWithTimeInterval:time
//                                     target:self
//                                   selector:@selector(updateLocation)
//                                   userInfo:nil
//                                    repeats:YES];
//
    
    [FBProfilePictureView class];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        //        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
    NSLog(@"My token is: %@", newToken);
    
    if (![newToken isEqualToString:oldTokenId]) {
        NSUserDefaults *localDefaults = [NSUserDefaults standardUserDefaults];
        [localDefaults setValue:newToken forKey:@"kPushNotificationUDID"];
        
        [localDefaults synchronize];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received");
    
    if (application.applicationState == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushNotificationReceivedForeground" object:userInfo];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushNotificationReceivedBackground" object:userInfo];
    }
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"Received");
//}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //nslog(@"Failed to get token, error: %@", error);
    NSLog(@"Failed to get token, error: %@", error);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    NSLog(@"Location: %f, %f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    if (currentLocation != nil) {
        [self.locationManager stopUpdatingLocation];
        //[self.locationManager requestAlwaysAuthorization];
    }
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}



/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
//    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"HooThere"
//                                                          ofType:@"momd"];
//    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
//    if (modelURL != nil) {
//        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    }
//    NSArray *bundleArray = [NSArray arrayWithObject:[NSBundle mainBundle]];
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    // Complete url to our database file
    NSString *databaseFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"HooThere.sqlite"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:databaseFilePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"HooThere" ofType:@"sqlite"];
        
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:databaseFilePath error:NULL];
            //}
        }
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: databaseFilePath];
    
    
    
    NSError *error;
    
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *migrateOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:migrateOptions error:&error]) {
        // Handle error
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark App Call Back From Other App

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        NSLog(@"In fallback handler");
                    }];
    //    return [FBSession.activeSession handleOpenURL:url];
    
}

@end
