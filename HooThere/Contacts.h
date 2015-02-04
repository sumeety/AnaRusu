//
//  Contacts.h
//  HooThere
//
//  Created by Abhishek Tyagi on 14/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contacts : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSData * imageData;

@end
