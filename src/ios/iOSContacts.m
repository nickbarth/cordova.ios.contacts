#import "iOSContacts.h"

@implementation iOSContacts

@synthesize callbackId;

- (void)iOSContacts:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted && addressBook) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
                CFIndex totalPeople = ABAddressBookGetPersonCount(addressBook);
                
                BOOL hasContacts = NO;
                
                if (totalPeople > 0) {
                    NSString *result = [NSString stringWithFormat: @"{ \"error\": false, \"contacts\": ["];
                    
                    for(ABRecordID i = 0; i < totalPeople; i++){
                        ABRecordRef person = CFArrayGetValueAtIndex(allContacts, i);
                        
                        NSString *firstName = @"";
                        NSString *lastName = @"";
                        NSString *phoneNumber = @"";
                        NSString *phoneLabel = @"";
                        
                        if (person) {
                            CFStringRef cfFirstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                            
                            if (cfFirstName) {
                                firstName = (NSString *)CFBridgingRelease(cfFirstName);
                            }
                            
                            CFStringRef cfLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
                            
                            if (cfLastName) {
                                lastName = (NSString *)CFBridgingRelease(cfLastName);
                            }
                            
                            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                            
                            if (phoneNumbers) {
                                CFIndex totalNumbers = ABMultiValueGetCount(phoneNumbers);
                                
                                for (CFIndex n = 0; n < totalNumbers; n++) {
                                    CFTypeRef cfPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, n);
                                    
                                    if (cfPhoneLabel) {
                                        phoneLabel = (NSString *)CFBridgingRelease(cfPhoneLabel);
                                        CFTypeRef cfPhoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, n);
                                        
                                        if (cfPhoneNumber) {
                                            if ([phoneLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                                                hasContacts = YES;
                                                phoneNumber = (NSString *) CFBridgingRelease(cfPhoneNumber);
                                                break;
                                            }
                                        }
                                    }
                                }
                                
                                CFRelease(phoneNumbers);
                            }
                            
                            NSString *fullname = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                            if (![phoneNumber isEqualToString:@""] && ![fullname isEqualToString:@" "]) {
                                result = [NSString stringWithFormat:@"%@ { \"name\": \"%@ %@\", \"number\": \"%@\" },", result, firstName, lastName, phoneNumber];
                            }
                        }
                        
                        CFRelease(person);
                    }
                    
                    if (hasContacts) {
                        result = [NSString stringWithFormat:@"%@] }", [result substringToIndex:[result length] - 1]];
                    } else {
                        result = @"{ \"error\": false, \"contacts\": [] }";
                    }
                    
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
                    NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
                    [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:javaScript waitUntilDone:NO];
                } else {
                    NSString *result = @"{ \"error\": false, \"contacts\": [] }";
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
                    NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
                    [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:javaScript waitUntilDone:NO];
                }
                
                CFRelease(allContacts);
            }];
        } else {
            NSString *result = @"{ \"error\": \"Request for Address Book Contacts declined.\" }";
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
            NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
            [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:javaScript waitUntilDone:NO];
        }
    });
}

@end
