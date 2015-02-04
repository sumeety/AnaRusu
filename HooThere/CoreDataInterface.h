//
//  CoreDataInterface.h
//  HooThere
//
//  Created by Abhishek Tyagi on 24/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Events.h"
#import "Contacts.h"
#import "Facebook.h"
#import "Friends.h"
#import "UserInformation.h"

@interface CoreDataInterface : NSObject

+(NSMutableArray *) searchObjectsInContext: (NSString*) entityName andPredicate: (NSPredicate *) predicate andSortkey: (NSString*) sortKey isSortAscending: (BOOL) sortAscending;
+(NSMutableArray *) searchObjectsInContext: (NSString*) entityName : (NSPredicate *) predicate : (NSString*) sortKey : (BOOL) sortAscending : (NSManagedObjectContext *) managedObjectContext;

+(void)saveAll;


+(void)saveUserInformation:(NSDictionary*)json;
+(UserInformation*)getInstanceOfMyInformation;

+(void)deleteAllObject:(NSString*)entityDescription andManagedOBC: (NSManagedObjectContext*)managedObjectContext;

+(void)saveEventList:(NSArray*)newList;
+(void)saveFriendList:(NSArray*)friendList;
+(void)deleteThisFriend:(Friends*)friendDict;
+(void)deleteThisEvent:(Events*)thisEvent;

+(void)saveContactList:(NSMutableArray*)contactList;

+(void)saveFacebookFriendsList:(NSMutableArray*)friendsList;
+ (NSDictionary *)getNewConnections:(NSMutableArray *)allFriends;
+(void)wipeOutSavedData;
+ (NSString *)checkUserStatus:(NSDictionary *)friendInfo;
+ (void)saveUserImageForUserId:(NSString *)userId;
//+(void)deleteThisFriend:(Friends*)friendDict;

@end
