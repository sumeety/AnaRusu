//
//  EventHelper.h
//  HooThere
//
//  Created by Abhishek Tyagi on 31/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventHelper : NSObject

+ (BOOL)compareStartDate:(NSDate *)startDate endDate:(NSDate *)endDate endDateSelected:(BOOL)endDateSelected;

//+ (NSString *)changeDateFormat:(NSString *)dateStr;
//+ (NSString *)changeTimeFormat:(NSString *)TimeStr;
+ (NSString *)changeDateFormat:(NSDate *)date;
+ (NSString *)changeTimeFormat:(NSDate *)date;

+(NSString *)createTimeStamp:(NSString *)dateStr  withDateFormat:(NSString *)format;
+(NSString *)changeDateTimeFormat:(NSString *)dateTimeStr;

+ (NSDate *)getDateFromString:(NSString *)dateTimeStr;
@end
