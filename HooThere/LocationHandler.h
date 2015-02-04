//
//  LocationHandler.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 17/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessfullBlockLocationName)(BOOL, NSString*);
typedef void (^SuccessfullBlockLocationCoordinates)(BOOL, NSDictionary*);

@interface LocationHandler : NSObject


+(void)getLocationCoordinates:(NSString *)locationName complettionBlock:(SuccessfullBlockLocationCoordinates)successblock;

+(void)locationLatitude:(float)latitude Longitude:(float)longitude complettionBlock:(SuccessfullBlockLocationName)successblock;

+(NSDictionary *)getDictionaryFromStringAddress:(NSString*)locationName;

@end
