//
//  ChangeNumberViewController.m
//  HooThere
//
//  Created by Jasmeet Kaur on 21/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "ChangeNumberViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "VerifyViewController.h"

@interface ChangeNumberViewController ()

@end

@implementation ChangeNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    [UtilitiesHelper changeTextFields:_numberTextField];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)hideKeyboard {
    [self.view endEditing:YES];
}



- (IBAction)submitButtonClicked:(id)sender {
    
    if(_numberTextField.text.length>0){
    
        if([self validatePhoneNumber:_numberTextField.text])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Your Number" message:[NSString stringWithFormat:@"We are going to send text message to %@ \n That's your number,right?",_numberTextField.text] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alertView show];
            
    
            
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
           }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Please Enter Valid Mobile Number" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];

        
        
        }

    
    }
    
}


- (BOOL)validatePhoneNumber:(NSString *)phoneNumber {
    BOOL valid;
    if (phoneNumber.length < 10 || phoneNumber.length > 15) {
        return NO;
    }
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:phoneNumber];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    if (!valid) {
        return NO;
    }
    else {
        return YES;
    }
}


#pragma mark Textfield Delegate -------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _numberTextField) {
        [self submitButtonClicked:_submitButton];
    
    }
    
    return YES;
}


#pragma  mark for Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"title %@",title);
    if ([title isEqualToString:@"Yes"]) {

    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/editPhoneForVerification",kwebUrl,_userId];
    //[_activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:_numberTextField.text,@"mobile", nil];
    
    [UtilitiesHelper getResponseFor:dict url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         //[_activityIndicator stopAnimating];
         
         if (success) {
             
             VerifyViewController *verifyView= [self.storyboard instantiateViewControllerWithIdentifier:@"verifyView"];
             verifyView.userId=_userId;
             verifyView.phoneNumber=_numberTextField.text;
             NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
             
             [navigationViewsArray removeLastObject];
             [navigationViewsArray removeLastObject];
             [navigationViewsArray addObject:verifyView];
             
             [self.navigationController pushViewController:verifyView animated:YES];
             
         }
         
     }];
    }


}

#pragma mark Country Code Delegate --------


-(IBAction)actionMethodSelectCountry:(id)sender{
    CountryListViewController *pupulateCountryList = [[CountryListViewController alloc]initWithNibName:@"CountryListViewController" bundle:nil];
    //pupulateCountryList.parentScreen = self;
    pupulateCountryList.delegate = self;
    
    [self.navigationController pushViewController:pupulateCountryList animated:NO];
}

-(void) countryListReturnedValues:(NSString *)countryName andCode:(NSString *)countryCode{
    [countryCodeButton setTitle:[NSString stringWithFormat:@"+%@", countryCode] forState:UIControlStateNormal];
}


@end
