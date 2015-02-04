//
//  Facebook.h
//  HooThere
//
//  Created by Abhishek Tyagi on 31/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Facebook : NSManagedObject

@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * imageurl;
@property (nonatomic, retain) NSString * name;

@end
