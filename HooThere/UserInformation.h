//
//  UserInformation.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 08/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInformation : NSManagedObject

@property (nonatomic, retain) NSString * availabilityStatus;
@property (nonatomic, retain) NSString * createdOn;
@property (nonatomic, retain) NSString * dateOfBirth;
@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * modifiedOn;
@property (nonatomic, retain) NSString * profile_picture;
@property (nonatomic, retain) NSData * profileImage;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * profileThumbnail;

@end
