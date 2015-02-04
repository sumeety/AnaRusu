//
//  ChangePasswordViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 14/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    savePassword.layer.cornerRadius=3;
    self.cancelButton.layer.cornerRadius=3;
    self.cancelButton.layer.borderColor=[UIColor purpleColor].CGColor;
    self.cancelButton.layer.borderWidth=1.0f;
    
    [currentPasswordTextfield becomeFirstResponder];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    // Do any additional setup after loading the view.
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
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

- (void)checkPassword:(UITextField *)passwordTextfield{
    if (!passwordTextfield.text.length > 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter the password minimum of 8 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
   
}


-(BOOL) confirmPassword{
    
    
    if (![newPasswordTextfield.text isEqualToString:confirmPasswordTextfield.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Passwords do not match \n please retype", @"Passwords do not match \n please retype") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        newPasswordTextfield.text = @"";
        confirmPasswordTextfield.text= @"";
        return NO;
    }
    else
        return YES;
    
}
- (IBAction)okButtonClicked:(id)sender {
    
    [self checkPassword:newPasswordTextfield];
    [self checkPassword:confirmPasswordTextfield];
    if([self confirmPassword]){
        
        NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  currentPasswordTextfield.text, @"currentPassword",
                                  newPasswordTextfield.text, @"newPassword",
                                  nil];
        
        
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
        
         NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/updatePassword",kwebUrl,uid];
//        NSString *urlString = @"http://192.168.1.148:8080/user/1/updatePassword";
        
        NSLog(@"%@",urlString);
        [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             
             
             if (success) {
                 [self.navigationController popViewControllerAnimated:YES];
             }
             
         }];
    }
    
    
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark textfield delegate-----

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == currentPasswordTextfield) {
        [newPasswordTextfield becomeFirstResponder];
    }
    else if (textField == newPasswordTextfield) {
        [confirmPasswordTextfield becomeFirstResponder];
    }
    else if (textField == confirmPasswordTextfield) {
        [self okButtonClicked:self];
    }
    
    return YES;
}


@end
