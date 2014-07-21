#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Cordova/CDV.h>

@interface iOSContacts: CDVPlugin{
  NSString* callbackId;
}

@property (nonatomic, retain) NSString* callbackId;

- (void)iOSContacts:(CDVInvokedUrlCommand *)command;
@end
