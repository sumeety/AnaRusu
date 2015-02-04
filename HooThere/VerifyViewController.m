//
//  VerifyViewController.m
//  HooThere
//
//  Created by Jasmeet Kaur on 21/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "VerifyViewController.h"
#import "UtilitiesHelper.h"
#import "HomeViewController.h"
#import "ChangeNumberViewController.h"
#import "CoreDataInterface.h"
#import "WhoThereViewController.h"

@interface VerifyViewController ()

@end

@implementation VerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _changeNumberButton.layer.borderWidth=1.0f;
    _changeNumberButton.layer.borderColor=[UIColor purpleColor].CGColor;
    _phoneLabel.text=_phoneNumber;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [UtilitiesHelper changeTextFields:_verifyTextField];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)hideKeyboard {
    [self.view endEditing:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)verifyButtonClicked:(id)sender {
    
    if(_verifyTextField.text.length>0){
   
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
     NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/verifycode",kwebUrl,_userId];
    //[_activityIndicator startAnimating];
    [self.view endEditing:YES];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:_verifyTextField.text,@"verificationCode",oldTokenId,@"deviceId", @"ios", @"platform" ,nil];
    

    NSLog(@"sending withh dict ...%@",dict);
    
    [UtilitiesHelper getResponseFor:dict url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         //[_activityIndicator stopAnimating];
         
         if (success) {
             NSString *userId=[[jsonDict objectForKey:@"id"] stringValue];
             if(userId.length > 0) {
                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setBool:YES forKey:@"isloggedin"];
                 [defaults synchronize];
                 
                 NSString *tokenStatusMessage = [jsonDict objectForKey:@"tokenStatusMessage"];
                 
                 if (tokenStatusMessage.length > 0) {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:tokenStatusMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alertView show];
                 }
                 
                 [CoreDataInterface saveUserInformation:jsonDict];
                 [CoreDataInterface saveUserImageForUserId:userId];

                 WhoThereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];

                 NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                 [navigationArray removeObjectAtIndex:1];
                 [navigationArray removeObjectAtIndex:1];
                 [navigationArray addObject:whoThereView];
                 [self.navigationController setViewControllers:navigationArray];
             }
         }
         
     }];

    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please Enter the Verification Code" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    
    }
    
    
}


- (IBAction)changeNumberClicked:(id)sender {
    
    ChangeNumberViewController *changeView = [self.storyboard instantiateViewControllerWithIdentifier:@"changeView"];
    changeView.userId=_userId;
    [self.navigationController pushViewController:changeView animated:YES];
}

- (IBAction)notReceivedYet:(id)sender {
   
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/resendVerificationCode",kwebUrl,_userId];
    //[_activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         //[_activityIndicator stopAnimating];
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:[NSString stringWithFormat:@"New Verification Code has been sent to your mobile number %@",_phoneNumber]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alertView show];
         }
     }];
}


#pragma mark Textfield Delegate -------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _verifyTextField) {
        [self verifyButtonClicked:_verifyButton];
    }
    return YES;
}




@end
