//
//  UtilitiesHelper.h
//  movee
//
//  Created by Abhishek Tyagi on 31/07/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MKNumberBadgeView.h"


typedef void (^SuccessfullBlockResponse)(BOOL, NSDictionary*);
typedef void (^SuccessfullBlockForImage)(BOOL, UIImage *);


@protocol NavigationButtonDelegate <NSObject>
@required
- (void)createEventButtonClicked;
- (void)notificationButtonClicked; 
@end

@interface UtilitiesHelper : NSObject

+(UIActivityIndicatorView *)loadCustomActivityIndicatorWithYorigin:(float)y Xorigin:(float)x;

+(FBLoginView *)loadFacbookButton:(CGRect )frame;

+(void) changeTextFields:(UITextField *)textFieldToChange;

+ (void)updateUserAllInformations;

+(MKNumberBadgeView *)createBadgeNumberForValue:(NSInteger)value;

+(void)getResponseFor:(NSDictionary *)dictionary url:(NSURL*)url requestType:(NSString *)requestType complettionBlock:(SuccessfullBlockResponse)successblock;

+(void)fetchListOfHootThereFriends:(NSURL*)url requestType:(NSString *)requestType complettionBlock:(SuccessfullBlockResponse)successblock;

+(void)getFacebookFriends;

+ (NSDictionary *)setUserDetailsDictionaryFromCoreDataWithInfo:(id)info type:(NSString *)type;
+(NSString *)getFullName:(NSString *)firstName  middleName:(NSString *)middleName lastName:(NSString *)lastName;
+(void)uploadImage:(NSData*)imageData;
+(NSDictionary*)stringToDictionary:(NSString*)stringDict;
+(void)getImageFromServer:(NSURL *)url complettionBlock:(SuccessfullBlockForImage)successblock;
+(NSString *)setStatusIcon:(NSString *)status for:(NSString *)type;
@end
