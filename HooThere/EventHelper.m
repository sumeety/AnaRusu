//
//  EventHelper.m
//  HooThere
//
//  Created by Abhishek Tyagi on 31/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "EventHelper.h"

@implementation EventHelper


+ (BOOL)compareStartDate:(NSDate *)startDate endDate:(NSDate *)endDate endDateSelected:(BOOL)endDateSelected{
    NSTimeInterval distanceBetweenDates = [startDate timeIntervalSinceDate:endDate];
    double secondsInAnHour = 60;
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    
    if (hoursBetweenDates > 0) {
        return TRUE;
    }
    else if (hoursBetweenDates == 0 && !endDateSelected){
        return TRUE;
    }
    else {
        return FALSE;
    }
}

+(NSString *)createTimeStamp:(NSString *)dateTimeStr withDateFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    NSLog(@"%@",dateTimeStr);
    NSDate *date  = [dateFormatter dateFromString:dateTimeStr];
    
    NSLog(@"%@",date);
    //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
   
    
   
    dateTimeStr=[NSString stringWithFormat:@"%lli",[@(floor([date timeIntervalSince1970] * 1000)) longLongValue]];
    //dateStr = [dateFormatter stringFromDate:date];
     NSLog(@"String Returned %@",dateTimeStr);
    return dateTimeStr;



}

//+ (NSString *)changeDateFormat:(NSString *)dateStr {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd MMM yyyy "];
//    
//    NSDate *date  = [dateFormatter dateFromString:dateStr];
//    
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    
//    dateStr = [dateFormatter stringFromDate:date];
//    
//    return dateStr;
//}
//
//+ (NSString *)changeTimeFormat:(NSString *)timeStr {
//    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
//    
//    [timeFormatter  setDateFormat:@"hh:mm a"];
//    
//    NSDate *time  = [timeFormatter dateFromString:timeStr];
//    
//    
//    [timeFormatter setDateFormat:@"HH:mm"];
//    
//    timeStr = [timeFormatter stringFromDate:time];
//     
//    return timeStr;
//}

+ (NSString *)changeDateFormat:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"dd MMM yyyy "];
    
    //NSDate *date  = [dateFormatter dateFromString:dateStr];
    NSLog(@"date to changeDateFormat %@",date);
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSLog(@"String Returned %@",dateStr);
    return dateStr;
}


+ (NSString *)changeDateTimeFormat:(NSString *)dateTimeStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE dd MMM yyyy hh:mm a"];
    
    NSDate *date  = [dateFormatter dateFromString:dateTimeStr];
    NSLog(@"date to changeDateFormat %@",date);
    [dateFormatter setDateFormat:@"dd MMM yyyy hh:mm a"];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSLog(@"String Returned %@",dateStr);
    return dateStr;
}

+ (NSDate *)getDateFromString:(NSString *)dateTimeStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    
    NSDate *date  = [dateFormatter dateFromString:dateTimeStr];
    
    return date;
}



+ (NSString *)changeTimeFormat:(NSDate *)date {
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLog(@"date to changeTimeFormat %@",date);

    [dateFormatter setDateFormat:@"hh:mm a"];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
     NSLog(@"String Returned %@",dateStr);
    return dateStr;
}
@end
