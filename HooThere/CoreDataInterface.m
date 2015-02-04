//
//  CoreDataInterface.m
//  HooThere
//
//  Created by Abhishek Tyagi on 24/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "CoreDataInterface.h"
#import "AppDelegate.h"
#import "UtilitiesHelper.h"

@implementation CoreDataInterface

+(void)deleteAllObject:(NSString*)entityDescription andManagedOBC: (NSManagedObjectContext*)managedObjectContext{
    if (managedObjectContext ==nil) {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        managedObjectContext =appDelegate.managedObjectContext;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
        ////NSLog(@"%@ object deleted",entityDescription);
    }
    
}

+(NSMutableArray *) searchObjectsInContext: (NSString*) entityName : (NSPredicate *) predicate : (NSString*) sortKey : (BOOL) sortAscending : (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext ==nil) {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        managedObjectContext =appDelegate.managedObjectContext;
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    // If a predicate was passed, pass it to the query
    if(predicate != nil)
    {
        [request setPredicate:predicate];
    }
    
    // If a sort key was passed, use it for sorting.
    if(sortKey != nil)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        //[sortDescriptors release];
        //[sortDescriptor release];
    }
    
    NSError *error;
    
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy] ;
    
    //[request release];
    
    return mutableFetchResults;
}


+(NSMutableArray *) searchObjectsInContext: (NSString*) entityName andPredicate: (NSPredicate *) predicate andSortkey: (NSString*) sortKey isSortAscending: (BOOL) sortAscending

{
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext * managedObjectContext = appDelegate.managedObjectContext;
    //NSManagedObjectContext * managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    // If a predicate was passed, pass it to the query
    if(predicate != nil)
    {
        [request setPredicate:predicate];
    }
    
    // If a sort key was passed, use it for sorting.
    if(sortKey != nil)
    {
//        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending selector:@selector(caseInsensitiveCompare:)];

        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        //[sortDescriptors release];
        //[sortDescriptor release];
    }
    
    NSError *error;
    
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy] ;
    
    //[request release];
    
    return mutableFetchResults;
}

+(void)saveFacebookFriendsList:(NSMutableArray*)friendsList {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];

    [self deleteAllObject:@"Facebook" andManagedOBC:appDelegate.managedObjectContext];
    for (int i = 0; i < friendsList.count; i++)
    {
        NSDictionary *friendDict = [friendsList objectAtIndex:i];
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(userid == %@)",[friendDict objectForKey:@"id"]];
        
        NSArray *retData =  [self searchObjectsInContext:@"Facebook" andPredicate:entitySearchPredicate andSortkey:@"userid" isSortAscending:YES];
        if (![retData count] > 0)
        {
            [self storeNewFacebookFriend:friendDict];
        }
        else {
            [self deleteThisFacebookFriend:[retData objectAtIndex:0]];
            [self storeNewFacebookFriend:friendDict];
        }
        
    }
    [self saveAll];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kLoadFacebookFriends" object:nil];
}

+(void)saveUserInformation:(NSDictionary*)json {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [self deleteAllObject:@"UserInformation" andManagedOBC:appDelegate.managedObjectContext];
    
    UserInformation *newMyinfo = [self getInstanceOfMyInformation];
    
    NSDictionary *attributes = [[newMyinfo entity] attributesByName];
    //
    for (NSString *attribute in attributes) {
        
        id value = [json objectForKey:attribute];
        if (value == nil || value == [NSNull null] ) {
            continue;
        }
        value = [NSString stringWithFormat:@"%@",value];
        if ([attribute isEqualToString:@"userid"]) {
            newMyinfo.userid = [json objectForKey:@"id"];
            return;
        }
        [newMyinfo setValue:value forKey:attribute];
    }
    
    [self saveAll];
}

+(UserInformation*)getInstanceOfMyInformation {
    UserInformation *MyInformationToReturn;
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSArray *currentMyInfo = [self searchObjectsInContext:@"UserInformation" andPredicate:nil andSortkey:@"userid" isSortAscending:YES];
    if ([currentMyInfo count]==0) {
        //create new
        MyInformationToReturn =(UserInformation*)[NSEntityDescription insertNewObjectForEntityForName:@"UserInformation" inManagedObjectContext:appDelegate.managedObjectContext];
        
    }else{
        MyInformationToReturn = [currentMyInfo objectAtIndex:0];
    }
    
    return MyInformationToReturn;
}

+(void)deleteThisFacebookFriend:(Facebook*)thisFriend {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [appDelegate.managedObjectContext deleteObject:thisFriend];
}

+(void)storeNewFacebookFriend:(NSDictionary*)friendDict {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    Facebook *newFacebookFriend = (Facebook*)[NSEntityDescription insertNewObjectForEntityForName:@"Facebook" inManagedObjectContext:appDelegate.managedObjectContext];
    
    [newFacebookFriend setValue:[friendDict objectForKey:@"name"] forKey:@"name"];
    [newFacebookFriend setValue:[friendDict objectForKey:@"id"] forKey:@"userid"];
    [newFacebookFriend setValue:[[[friendDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] forKey:@"imageurl"];
    
    [self saveAll];
}

+(void)saveFriendList:(NSArray*)friendList{
    for (int i = 0; i < friendList.count; i++)
    {
        NSDictionary *serverFriendDict = [friendList objectAtIndex:i];
        NSMutableDictionary *serverFriend = [[serverFriendDict objectForKey:@"friend"] mutableCopy];
        [serverFriend setObject:[serverFriendDict objectForKey:@"status"] forKey:@"status"];
        if([serverFriendDict objectForKey:@"eventGuestStatus"] ){
            [serverFriend setObject:[serverFriendDict objectForKey:@"eventGuestStatus"] forKey:@"eventGuestStatus"];}
        
            
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",[serverFriend objectForKey:@"id"]];
        
        NSArray *retData =  [self searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
        if (![retData count] > 0)
        {
            [self storeNewFriend:serverFriend];
        }
        else {
            [self deleteThisFriend:[retData objectAtIndex:0]];
            [self storeNewFriend:serverFriend];
        }
    }
    [self saveAll];
}

+(void)deleteThisFriend:(Friends*)friendDict{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [appDelegate.managedObjectContext deleteObject:friendDict];
}

+(void)storeNewFriend:(NSMutableDictionary*)friendDict {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    Friends *newFriend = (Friends*)[NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSDictionary *attributes = [[newFriend entity] attributesByName];
    
    for (NSString *attribute in attributes) {
        
        id value = [friendDict objectForKey:attribute];
        if (value == nil || value == [NSNull null] ) {
            continue;
        }
        [newFriend setValue:[NSString stringWithFormat:@"%@",value] forKey:attribute];
    }
    [newFriend setValue:[NSString stringWithFormat:@"%@",[friendDict objectForKey:@"id"]] forKey:@"friendId"];
    NSLog(@"Friend : %@",newFriend);
}


+(void)saveContactList:(NSMutableArray*)contactList {
    for (int i = 0; i < contactList.count; i++)
    {
        NSDictionary *contactDict = [contactList objectAtIndex:i];
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(userid == %@)",[contactDict objectForKey:@"userid"]];
        
        NSArray *retData =  [self searchObjectsInContext:@"Contacts" andPredicate:entitySearchPredicate andSortkey:@"userid" isSortAscending:YES];
        if (![retData count] > 0)
        {
            [self storeNewContact:contactDict];
        }
        else {
            [self deleteThisContact:[retData objectAtIndex:0]];
            [self storeNewContact:contactDict];
        }
        
    }
    [self saveAll];
}

+(void)deleteThisContact:(Events*)thisContact {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [appDelegate.managedObjectContext deleteObject:thisContact];
}

+(void)storeNewContact:(NSDictionary*)contactDict {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    Contacts *newContact = (Contacts*)[NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:appDelegate.managedObjectContext];
    NSDictionary *attributes = [[newContact entity] attributesByName];
    
    for (NSString *attribute in attributes) {
        
        id value = [contactDict objectForKey:attribute];
        if (value == nil || value == [NSNull null] ) {
            continue;
        }
        [newContact setValue:value forKey:attribute];
    }
    [self saveAll];
}

+(void)saveEventList:(NSArray*)newListArray {
    for (int i = 0; i < newListArray.count; i++)
    {
        NSDictionary *serverEventDict = [newListArray objectAtIndex:i];
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",[serverEventDict objectForKey:@"id"]];
        
        NSArray *retData =  [self searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
        if (![retData count] > 0)
        {
            [self storeNewEvent:serverEventDict];
        }
        else {
            [self deleteThisEvent:[retData objectAtIndex:0]];
            [self storeNewEvent:serverEventDict];
        }
        
    }
    [self saveAll];
}

+(void)deleteThisEvent:(Events*)thisEvent{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [appDelegate.managedObjectContext deleteObject:thisEvent];
}

+(void)storeNewEvent:(NSDictionary*)eventDict {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    Events *newEvent = (Events*)[NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:appDelegate.managedObjectContext];
    NSDictionary *attributes = [[newEvent entity] attributesByName];
    
    [newEvent setValue:[NSString stringWithFormat:@"%@",[eventDict objectForKey:@"id"]] forKey:@"eventid"];

    NSArray *guestsArray = [eventDict objectForKey:@"eventGuests"];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:guestsArray];
    
    for (NSString *attribute in attributes) {
        
        NSLog(@"attribute = %@",attribute);
        
        id value = [eventDict objectForKey:attribute];
        
        if ([value isKindOfClass:[NSArray class]]) {
            [newEvent setValue:data forKey:attribute];
            continue;
        }
        
        if (value == nil || value == [NSNull null] ) {
            continue;
        }
        [newEvent setValue:[NSString stringWithFormat:@"%@",value] forKey:attribute];
    }
   // id value = [NSString stringWithFormat:@"%@",[eventDict objectForKey:@"id"]];
     id value = [eventDict objectForKey:@"id"];
    if (value == nil || value == [NSNull null]) {
    }
    else {
        
        [newEvent setValue:[NSString stringWithFormat:@"%@",value] forKey:@"eventid"];
            }
    
    
    [self saveAll];
}

#pragma mark get new connections --------

+ (NSDictionary *)getNewConnections:(NSMutableArray *)allFriends {
    NSMutableArray *newConnections = [[NSMutableArray alloc] init];
    NSMutableArray *currentFriends = [[NSMutableArray alloc] init];
    NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    for (int i = 0; i < allFriends.count; i++)
    {
        NSDictionary *serverFriendDict = [allFriends objectAtIndex:i];
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",[serverFriendDict objectForKey:@"guestId"]];
        
        NSArray *retData =  [self searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
       
        if ([retData count] > 0)
        { NSDictionary *friendData=[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:[retData objectAtIndex:0] type:nil] ;
            [currentFriends addObject:friendData];
        }
        else if([[serverFriendDict objectForKey:@"guestId"] isEqualToString:[NSString stringWithFormat:@"%@",uid]])
        {
//        [currentFriends addObject:[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:[CoreDataInterface getInstanceOfMyInformation] type:nil] ];
        
            [currentFriends addObject:serverFriendDict];
        }
        else {
            [newConnections addObject:serverFriendDict];
        }
    }
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                newConnections,@"new",
                                currentFriends,@"friends",
                                nil];
    
    NSLog(@"returnd %@",dictionary);
    return dictionary;
}

+ (NSString *)checkUserStatus:(NSDictionary *)friendInfo {
    NSString *friendshipStatus = @"N";
    
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",[friendInfo objectForKey:@"userId"]];
    
    NSArray *retData =  [self searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
    if ([retData count] > 0)
    {
        Friends *friendInfo = [retData objectAtIndex:0];
        id status = friendInfo.status;
        if (status != nil && ![status isEqual:[NSNull null]]) {
            friendshipStatus = status;
        }
    }
    
    return friendshipStatus;
}

#pragma mark common
+(void)saveAll{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSError *error;
    if (![appDelegate.managedObjectContext save:&error]) {
        
        // Handle the error.
        NSLog(@"error in saving mananged context%@", [error domain]);
    }
    //NSLog(@"saved core data" );
}

+ (void)saveUserImageForUserId:(NSString *)userId {
    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    if (userInfo.profile_picture.length > 0) {
        
        id imageName = userInfo.profile_picture;
        
        if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/image",kwebUrl,userId];
            [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
             {
                 if (success) {
                     NSData *imageData = UIImagePNGRepresentation(image);
                     if (imageData.length > 0) {
                         userInfo.profileImage = UIImagePNGRepresentation(image);
                     }
                     [self saveAll];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"KLoadProfilePicture" object:nil];
                 }
             }];
        }
    }
}

+(void) wipeOutSavedData{
     AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
     [self deleteAllObject:@"UserInformation" andManagedOBC:appDelegate.managedObjectContext];
     [self deleteAllObject:@"Events" andManagedOBC:appDelegate.managedObjectContext];
     [self deleteAllObject:@"Friends" andManagedOBC:appDelegate.managedObjectContext];
     [self deleteAllObject:@"Contacts" andManagedOBC:appDelegate.managedObjectContext];
     [self deleteAllObject:@"Facebook" andManagedOBC:appDelegate.managedObjectContext];
}
    


@end
