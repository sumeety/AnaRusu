//
//  NotificationHelper.m
//  HooThere
//
//  Created by Abhishek Tyagi on 18/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "NotificationHelper.h"
#import "UtilitiesHelper.h"

@implementation NotificationHelper


+ (void)getListOfNotifications:(NSString *)offset all:(BOOL)getAll complettionBlock:(SuccessfullBlockNotifications)successblock {
    //user/{userId}/allNotifications
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/allNotifications?pageIndex=%@&pageSize=20",kwebUrl,userId,offset];
    
    if (!getAll) {
        urlString = [NSString stringWithFormat:@"%@/user/%@/unreadNotifications?pageIndex=%@&pageSize=50",kwebUrl,userId,offset];
    }
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         if (success) {
             NSLog(@"Json : %@",jsonDict);
             successblock(TRUE,[jsonDict objectForKey:@"notifications"]);
         }
     }];
}

+ (void)getCountOfNotificationsWithComplettionBlock:(SuccessfullBlockNotificationsCount)successblock {
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/notificationCount",kwebUrl,userId];
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         if (success) {
             NSLog(@"Json : %@",jsonDict);
             successblock(TRUE,[jsonDict objectForKey:@"count"]);
         }
     }];
}

@end
