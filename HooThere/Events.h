//
//  Events.h
//  Hoothere
//
//  Created by Steve Sopoci on 1/28/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Events : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * endDateTime;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * eventid;
@property (nonatomic, retain) NSString * eventSettings;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSString * guestStatus;
@property (nonatomic, retain) NSString * invitation;
@property (nonatomic, retain) NSString * is_public;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * radius;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * startDateTime;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * statistics;
@property (nonatomic, retain) NSString * streetName;
@property (nonatomic, retain) NSString * timeZone;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) NSData * eventGuests;

@end
