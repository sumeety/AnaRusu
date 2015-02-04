//
//  NotificationHelper.h
//  HooThere
//
//  Created by Abhishek Tyagi on 18/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessfullBlockNotifications)(BOOL, NSMutableArray*);
typedef void (^SuccessfullBlockNotificationsCount)(BOOL, NSString*);

@interface NotificationHelper : NSObject

+ (void)getListOfNotifications:(NSString *)offset all:(BOOL)getAll complettionBlock:(SuccessfullBlockNotifications)successblock;
+ (void)getCountOfNotificationsWithComplettionBlock:(SuccessfullBlockNotificationsCount)successblock;

@end
