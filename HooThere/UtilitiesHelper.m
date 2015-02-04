//
//  UtilitiesHelper.m
//  movee
//
//  Created by Abhishek Tyagi on 31/07/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"

@interface NSURLRequest (DummyInterface)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation UtilitiesHelper
//https://maps.googleapis.com/maps/api/place/search/json?location=-33.8670522,151.1957362&radius=500&types=food&sensor=true&key=AddYourOwnKeyHere

+(UIActivityIndicatorView *)loadCustomActivityIndicatorWithYorigin:(float)y Xorigin:(float)x {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x+10, y, 80, 80)];
    
    activityIndicator.hidesWhenStopped = TRUE;
    
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicator.alpha = 1.0f;
    activityIndicator.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8];
    activityIndicator.layer.cornerRadius = 10.0f;
    activityIndicator.layer.borderWidth = 0;
    activityIndicator.layer.borderColor = [[UIColor clearColor] CGColor];
    UILabel *lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 80, 20)];
    lblLoading.text =@"Loading";
    lblLoading.font = [UIFont systemFontOfSize:12];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.backgroundColor = [UIColor clearColor];
    [activityIndicator addSubview:lblLoading];
    
    return activityIndicator;
}



+(UIView *)createViewForNavigationBar {
    UIView *leftItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    
    UIButton *createEventButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    createEventButton.frame = CGRectMake(20, 0, 35, 30);
    [createEventButton addTarget:self action:@selector(createEventButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *createEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 7, 35, 20)];
    createEventImageView.contentMode = UIViewContentModeScaleAspectFit;
    createEventImageView.image = [UIImage imageNamed:@"create-event.png"];
    
    [leftItemView addSubview:createEventButton];
    [leftItemView addSubview:createEventImageView];
    
    UIButton *notificationButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    notificationButton.frame = CGRectMake(55, 0, 35, 30);
    [notificationButton addTarget:self action:@selector(notificationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *notificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(55, 2, 35, 26)];
    notificationImageView.contentMode = UIViewContentModeScaleAspectFit;
    notificationImageView.image = [UIImage imageNamed:@"notification.png"];
    
    [leftItemView addSubview:notificationButton];
    [leftItemView addSubview:notificationImageView];
    
    return leftItemView;
}

- (void)createEventButtonClicked {
    NSLog(@"Create Event");
}

- (void)notificationButtonClicked {
    NSLog(@"Notifications");
}

+(MKNumberBadgeView *)createBadgeNumberForValue:(NSInteger)value {
    MKNumberBadgeView *numberBadge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(10, -10, 34,20)];
    numberBadge.value = value;
    
    return numberBadge;
}

+(FBLoginView *)loadFacbookButton:(CGRect )frame {
    FBLoginView *loginview = [[FBLoginView alloc] initWithReadPermissions:
                              @[@"public_profile", @"email", @"user_birthday", @"user_friends"]];
    loginview.frame = frame;
    
    [loginview sizeToFit];
    
    NSLog(@"Array : %@",loginview.subviews);
    
    [[loginview.subviews objectAtIndex:0] setTitle:@"" forState:UIControlStateNormal];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(65 ,-1, 175 ,42)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    [loginview addSubview:label];
    
    [[loginview.subviews objectAtIndex:1] setHidden:YES];
    
    [[loginview.subviews objectAtIndex:2] setHidden:NO];
    [loginview bringSubviewToFront:label];
    
    CGRect newFrame = CGRectMake(0, 0, 290, 43);

    [[loginview.subviews objectAtIndex:0] setTitle:@"" forState:UIControlStateNormal];
    [[loginview.subviews objectAtIndex:0] setFrame:newFrame];
    [[loginview.subviews objectAtIndex:0] setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    
    return loginview;
}

+(NSDictionary*)stringToDictionary:(NSString*)stringDict{
    return [NSPropertyListSerialization
            propertyListWithData:[stringDict dataUsingEncoding:NSUTF8StringEncoding]
            options:kNilOptions
            format:NULL
            error:NULL];
    
}

+(void) changeTextFields:(UITextField *)textFieldToChange{
    
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textFieldToChange.leftView = paddingView;
    textFieldToChange.leftViewMode = UITextFieldViewModeAlways;
    
    
    textFieldToChange.layer.borderWidth=1.0f;
    textFieldToChange.layer.cornerRadius=3;
    
    textFieldToChange.layer.borderColor=[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f].CGColor;
    
    
}


+(NSString *)getFullName:(NSString *)firstName  middleName:(NSString *)middleName lastName:(NSString *)lastName{

 NSString *fullName=   [NSString stringWithFormat:@"%@ %@ %@",
     (![firstName isEqual:[NSNull null]] && firstName !=nil)?firstName:@"",
     
     (![middleName isEqual:[NSNull null]] && middleName !=nil)?middleName:@"",
     (![lastName isEqual:[NSNull null]] && lastName !=nil)?lastName:@"" ];


    return fullName;
}




+(void)getResponseFor:(NSDictionary *)dictionary url:(NSURL*)url requestType:(NSString *)requestType complettionBlock:(SuccessfullBlockResponse)successblock {
    NSError *error;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:requestType];
    
    if ([[dictionary objectForKey:@"type"] isEqualToString:@"I"]) {
        NSMutableData *body = [NSMutableData data];
        NSString *boundary = [NSString stringWithFormat:@"---------------------------14737809831466499882746641449"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"XXX.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: multipart/form-data\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:[dictionary objectForKey:@"file"]]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // close form
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // set request body
        [request setHTTPBody:body];
    }
    else {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        if(dictionary!=nil)
        {
            NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
            [request setHTTPBody:postData];
        }
    }

//    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:url.host];
 

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *jsonData, NSError *error)
     {
         NSLog(@"Description : %@",response.description);
         NSLog(@"error %@",[error description]);
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         BOOL loggedIn = [defaults boolForKey:@"isloggedin"];
//         if (loggedIn) {
             if (jsonData == nil ) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We were unable to connect to the required services. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alert show];
                 successblock(FALSE,nil);
                 return ;
             }
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             NSInteger responseStatusCode = [httpResponse statusCode];
             
             NSLog(@"Status Code :: %ld", (long)responseStatusCode);
             
             NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
             
             responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
             responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
             responseString = [responseString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
             
             NSData *jsonData1 = [responseString dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *jsonDict = [NSJSONSerialization
                                       JSONObjectWithData:jsonData1
                                       options:kNilOptions
                                       error:&error];
             
             NSLog(@"Details ::::::::::::: %@",jsonDict);
             
             if (responseStatusCode >= 200 && responseStatusCode < 350) {
                 successblock(TRUE,jsonDict);
             }
             else {
                 successblock(FALSE,jsonDict);
                 [self displayErrorMessage:jsonDict];
             }
//         }
     }];
}

//+ (UIImage *)getImageForStatus:(NSString *)status {
//    
//    
//}

+ (void)displayErrorMessage:(NSDictionary *)jsonDict {
    NSString *errorMsg = [jsonDict objectForKey:@"errorMessage"];
    if (errorMsg.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (![[jsonDict objectForKey:@"message"] isEqual:[NSNull null]] && [jsonDict objectForKey:@"message"] != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[jsonDict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if ([[jsonDict objectForKey:@"error"] length] > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[jsonDict objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We were unable to connect to the required services. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
}

+(void)getFacebookFriends {
//    [FBRequestConnection startWithGraphPath:@"me/taggable_friends?fields=email,id,name,picture"
//                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                              if (!error) {
//                                  // Sucess! Include your code to handle the results here
//                                  NSLog(@"friends: %@", result);
//                                  NSMutableArray *fbFriends = [result objectForKey:@"data"];
//                                  [CoreDataInterface saveFacebookFriendsList:fbFriends];
//                              } else {
//                                  // An error occurred, we need to handle the error
//                                  // See: https://developers.facebook.com/docs/ios/errors
//                              }
//                          }];
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {        
        if (!error) {
            NSMutableArray *fbFriends = [result objectForKey:@"data"];
            
            NSLog(@"friends: %@", fbFriends);
            [CoreDataInterface saveFacebookFriendsList:fbFriends];
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
        
    }];
}

+ (NSDictionary *)setUserDetailsDictionaryFromCoreDataWithInfo:(id)info type:(NSString *)type {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSDictionary *attributes = [[info entity] attributesByName];
    for (NSString *attribute in attributes) {
        //        SEL attributeMethod = NSSelectorFromString(attribute);
        id value = [info valueForKey:attribute];
        if ([attribute isEqualToString:@"profileImage"]) {
            continue;
        }
        if (value == nil || value == [NSNull null] || [attribute isEqualToString:@"eventid"]) {
            continue;
        }
        
        value = [NSString stringWithFormat:@"%@",value];
        if ([attribute isEqualToString:@"userid"] || [attribute isEqualToString:@"friendId"]) {
            [dictionary setValue:value forKey:@"guestId"];
            continue;
        }
        [dictionary setValue:value forKey:attribute];
    }
    
    NSLog(@"Dictionary : %@",dictionary);
    
    return dictionary;
}


+ (void)uploadImage:(NSData*)imageData {
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                imageData,@"file",
                                @"I", @"type",nil];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];

    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/upload",kwebUrl,uid];
    
    [self getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         
         if (success) {
             NSLog(@"Json : %@",jsonDict);
             
         }
     }];
}

+(void)fetchListOfHootThereFriends:(NSURL*)url requestType:(NSString *)requestType complettionBlock:(SuccessfullBlockResponse)successblock{
    
    
    //NSString *urlString = [NSString stringWithFormat:@"%@/friends/1/getAll",kwebUrl];
    
    [self getResponseFor:nil url:url requestType:requestType  complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
           if (success) {
              successblock(TRUE,jsonDict);
         }
     }];
};

+(void)getImageFromServer:(NSURL *)url complettionBlock:(SuccessfullBlockForImage)successblock
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void)
                   {
                       NSData * data = [[NSData alloc] initWithContentsOfURL:url];
                       UIImage * image = [[UIImage alloc] initWithData:data];
                       dispatch_async( dispatch_get_main_queue(), ^(void){
                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                           BOOL loggedIn = [defaults boolForKey:@"isloggedin"];
                           if (loggedIn) {
                               if( image != nil )
                               {
                                   successblock(TRUE,image);
                               } else {
                                   successblock(FALSE,nil);
                               }
                           }
                       });
                   });
}

+ (BOOL)sendCreateEventRequest {
    return YES;
}

+(NSString *)setStatusIcon:(NSString *)status for:(NSString *)type{
    
    if([type isEqualToString:@"status"])
    {
    if([status isEqualToString:@"Going Out"])
        return @"going.png";
    else if([status isEqualToString:@"Looking for plans"])
        return @"makeplan.png";
    else
        return @"invited.png";
    }
    else if([type isEqualToString:@"phone"])
    {
        return @"mobile-icon.png";
    }
    else
        return @"email-icon.png";
    
}
@end


