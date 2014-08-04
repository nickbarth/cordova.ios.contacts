#import "iOSContacts.h"

@implementation iOSContacts

@synthesize callbackId;

- (void)iOSContacts:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;

    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
      if (granted) {
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
              NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);

              if ([allContacts count] > 0) {
                  NSString *result = [NSString stringWithFormat: @"{ \"error\": false, \"contacts\": ["];
                  for(int i = 0; i < [allContacts count]; i++){
                      ABRecordRef person = (__bridge ABRecordRef)[allContacts objectAtIndex:i];

                      NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                      NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                      NSString *phoneNumber = @"";
                      NSString *phoneLabel = @"";
                      
                      ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);

                      for (CFIndex n = 0; n < ABMultiValueGetCount(phoneNumbers); n++) {
                          phoneLabel = (__bridge_transfer NSString *) ABMultiValueCopyLabelAtIndex(phoneNumbers, n);
                          
                          if ([phoneLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                              phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, n);
                              break;
                          }
                      }
                      
                      if (![phoneNumber isEqualToString:@""]) {
                          result = [NSString stringWithFormat:@"%@ { \"name\": \"%@ %@\", \"number\": \"%@\" },", result, firstName, lastName, phoneNumber];
                      }
                  }

                  result = [NSString stringWithFormat:@"%@] }", [result substringToIndex:[result length] - 1]];
                  
                  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
                  NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
                  [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:javaScript waitUntilDone:NO];

              } else {
                NSString *result = @"{ \"error\": false, \"contacts\": [] }";
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
                NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
                [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:javaScript waitUntilDone:NO];
              }
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

