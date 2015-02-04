//
//  Friends.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 08/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * availabilityStatus;
@property (nonatomic, retain) NSString * dateOfBirth;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * eventGuestStatus;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * friendId;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * profile_picture;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * profileThumbnail;

@end
