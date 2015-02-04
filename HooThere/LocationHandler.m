//
//  LocationHandler.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 17/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "LocationHandler.h"
#import "UtilitiesHelper.h"

@implementation LocationHandler

+(void)getLocationCoordinates:(NSString *)locationName complettionBlock:(SuccessfullBlockLocationCoordinates)successblock {

    locationName = [locationName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=AIzaSyDlFXsZsC7XoYCZ1v6sEL2autBMyJehwUE",locationName];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:url] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *dictionary) {
        NSString *status = [dictionary objectForKey:@"status"];
        NSMutableArray *locations = [dictionary objectForKey:@"results"];
        BOOL isLocationFound = FALSE;
        
        if ([status isEqualToString:@"OK"]) {
            if (locations.count > 0) {
                isLocationFound = TRUE;
                successblock(TRUE,[locations objectAtIndex:0]);
            }
        }
        
        if (!isLocationFound)
        {
            successblock(FALSE,nil);
            return ;
        }
    }];
}

+(void)locationLatitude:(float)latitude Longitude:(float)longitude complettionBlock:(SuccessfullBlockLocationName)successblock;
{
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%f,%f&mode=driving",latitude,longitude,latitude,longitude];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:url] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *dictionary) {
        NSString *status = [dictionary objectForKey:@"status"];
        NSMutableArray *locations = [dictionary objectForKey:@"destination_addresses"];
        BOOL isLocationFound = FALSE;
        
        if ([status isEqualToString:@"OK"]) {
            if (locations.count > 0) {
                isLocationFound = TRUE;
                successblock(TRUE,[locations objectAtIndex:0]);
            }
        }
        
        if (!isLocationFound)
        {
            successblock(FALSE,@"Location Not Found");
            return ;
        }
    }];
}

+(NSDictionary *)getDictionaryFromStringAddress:(NSString*)locationName {
    
    NSLog(@"Location Name : %@",locationName);
    
    NSArray *locationArray1 = [locationName componentsSeparatedByString:@","];
    
    NSMutableArray *locationArray = [[NSMutableArray alloc] initWithArray:locationArray1];
    
    NSString *city;
    NSString *state1;
    NSString *country;
    NSString *zip;
    NSString *street;
    
    if (locationArray.count == 4 || locationArray.count > 4) {
        NSMutableArray *stateZipArray = [[[locationArray objectAtIndex:locationArray.count-2] componentsSeparatedByString:@" "] mutableCopy];
        
        
        city = [locationArray objectAtIndex:locationArray.count-3];
        if (stateZipArray.count > 2) {
            zip = [stateZipArray lastObject];
            [stateZipArray removeLastObject];
            
            NSString *state =@"";
            
            for (int j = 0; j < stateZipArray.count; j++) {
                state = [NSString stringWithFormat:@"%@ %@",state,[stateZipArray objectAtIndex:j]];
            }
            state1 = state;
            
        }
        country = [locationArray objectAtIndex:locationArray.count-1];
        
        
        [locationArray removeLastObject];
        [locationArray removeLastObject];
        [locationArray removeLastObject];
        
        NSString *location =@"";
        
        for (int j = 0; j < locationArray.count; j++) {
            location = [NSString stringWithFormat:@"%@ %@",location,[locationArray objectAtIndex:j]];
        }
        street = location;
    }
    
    NSDictionary *locationDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        street,@"street",
                                        city,@"city",
                                        country,@"",
                                        zip,@"zip",
                                        state1,@"state",
                                        nil];
    return locationDictionary;
}

@end
