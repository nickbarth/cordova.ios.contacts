#import "iOSContacts.h"

@implementation iOSContacts

@synthesize callbackId;

- (void)iOSContacts:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;


    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
       
      if (granted) {
          dispatch_async(dispatch_get_main_queue(), ^{
              CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
              CFIndex numOfContacts = ABAddressBookGetPersonCount(addressBook);
              // NSString *contacts = @"";

              if (numOfContacts > 0) {
                  NSString *result = [NSString stringWithFormat: @"{ \"error\": false, \"contacts\": ["];

                  for(int i = 0; i < numOfContacts; i++){
                      ABRecordRef person = CFArrayGetValueAtIndex(allContacts, i);

                      NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                      NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                      NSString *phoneNumber = @"";

                      ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);

                      NSMutableArray *numbers = [NSMutableArray array];
                      for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                          phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                          // [numbers addObject:phoneNumber];
                      }

                      // NSMutableDictionary *contact = [NSMutableDictionary dictionary];
                      // [contact setObject:name forKey:@"name"];
                      // [contact setObject:numbers forKey:@"numbers"];
                      result = [NSString stringWithFormat:@"%@ { \"name\": \"%@ %@\", \"number\": \"%@\" },", result, firstName, lastName, phoneNumber];
                  }

                  result = [NSString stringWithFormat:@"%@] }", [result substringToIndex:[result length] - 1]];
                  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
                  NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
                  [self writeJavascript:javaScript];

              } else {
                NSString *result = @"{ \"error\": false, \"contacts\": [] }";
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
                NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
                [self writeJavascript:javaScript];
              }
          });
      } else {
        NSString *result = @"{ \"error\": \"Request for Address Book Contacts declined.\" }";
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
        NSString* javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
        [self writeJavascript:javaScript];
      }
    });
}

@end
