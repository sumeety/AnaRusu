//
//  AddressBook.m
//  HooThere
//
//  Created by Abhishek Tyagi on 16/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "AddressBook.h"
#import "CoreDataInterface.h"

@implementation AddressBook


+(void)getContactsFromAddressBook {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        
        [self showAlertForContactsPermission];
       
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        
        [self getListOfContacts];
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4
                [self showAlertForContactsPermission];
                return;
            }
            //5
            NSLog(@"Just authorized");
        });
    }
}

+ (void)showAlertForContactsPermission {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Share your contacts with us to use our app feature. To share your contacts just go to Setting > Privacy > Contacts and Switch it ON for HooThere." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+ (void)getListOfContacts {
//    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
//    CFIndex nPeople = CFArrayGetCount(allPeople);
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
//    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
//    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
    CFArrayRef allSources = ABAddressBookCopyArrayOfAllSources(addressBook);
    CFIndex nSource = CFArrayGetCount(allSources);
    for (int j = 0; j < nSource; j++) {
        ABRecordRef source = CFArrayGetValueAtIndex(allSources, j);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = CFArrayGetCount(allPeople);
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        for (int i = 0; i < nPeople; i++)
        {
            NSMutableDictionary *contacts = [[NSMutableDictionary alloc] init];
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            NSString *firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            if (!firstName.length > 0) {
                firstName = @"";
            }
            if (!lastName.length > 0) {
                lastName = @"";
            }
            [contacts setObject:[NSString stringWithFormat:@"%@ %@",firstName,lastName] forKey:@"name"];
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
            }
            if (phoneNumbers.count > 0) {
                [contacts setObject:[phoneNumbers objectAtIndex:0] forKey:@"number"];
            }
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                [contactEmails addObject:contactEmail];
            }
            if (contactEmails.count > 0) {
                [contacts setObject:[contactEmails objectAtIndex:0] forKey:@"email"];
            }
            [contacts setObject:[NSString stringWithFormat:@"%d",i+1] forKey:@"userid"];
            [items addObject:contacts];
            
            //        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
            //        if (imgData.length > 0) {
            //            [contacts setObject:imgData forKey:@"imageData"];
            //        }
            
        }
        [CoreDataInterface saveContactList:items];
    }
}


@end
