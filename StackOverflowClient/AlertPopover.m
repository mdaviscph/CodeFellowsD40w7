//
//  AlertPopover.m
//  LocationReminders
//
//  Created by mike davis on 9/7/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//
//  Note: If rootViewController is a normal ViewController then you cannot present an alert
//  controller until after viewDidLoad and viewWillAppear. One solution is to use a Navigation
//  Controller with the normal ViewController as the rootViewController.

#import "AlertPopover.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

NSString *const kErrorNotSignedIn = @"Please sign in and try again.";
NSString *const kErrorNoAccess = @"Please grant access to your account to continue.";
NSString *const kErrorNoConnection = @"Cannot connect to server. Please try again later.";
NSString *const kErrorBadData = @"Unable to communicate successfully with server. Please try again later.";
NSString *const kErrorNoAuthorization = @"Access denied by server. Please verify your account.";
NSString *const kErrorBusyOrServerError = @"Service is unavailable. Please try again later.";
NSString *const kErrorNoNewData = @"No new data. Please try again later.";
NSString *const kErrorLocationServicesDenied = @"Location Services - Authorization Denied.";
NSString *const kErrorLocationServicesRestricted = @"Location Services - Authorization Restricted.";
NSString *const kEnableLocationServices = @"Please enable Location Services - Allow Access: [While Using the App]";
NSString *const kErrorMapKit = @"Mapping Service";
NSString *const kErrorParseFramework = @"Parse Framework Error";
NSString *const kErrorCoreDataFetch = @"Core Data Fetch Error";
NSString *const kErrorCoreDataSave = @"Core Data Save Error";
NSString *const kErrorJSONSerialization = @"JSON Serialization Error";

NSString *const kActionOk = @"Ok";

@interface AlertPopover ()
@end

@implementation AlertPopover

+ (void) alert: (NSString *)title withNSError: (NSError *)error controller: (UIViewController *)parent completion: (void(^)(void)) handler {
  
  NSString *message = error.localizedDescription;
  if (error.userInfo) {
    NSArray *detailedErrors = error.userInfo[@"NSDetailedErrors"];
    for (NSError *detailedError in detailedErrors) {
      message = [[message stringByAppendingString: @"\n"] stringByAppendingString: detailedError.localizedDescription];
    }
  }
  [AlertPopover presentAlert: title message: message parent: parent handler: handler];
}

+ (void) alert: (NSString *)title withStatusCode: (NSInteger)statusCode controller: (UIViewController *)parent completion: (void(^)(void)) handler {
  
  NSString *message;
  NSString *format = @"%@ (%ld)";

  if (statusCode >= 200 && statusCode < 300) {
    message = [NSString stringWithFormat: format, kErrorBadData, (long)statusCode];
  } else if (statusCode >= 300 && statusCode < 400) {
    message = [NSString stringWithFormat: format, kErrorNoNewData, (long)statusCode];
  } else if (statusCode >= 400 && statusCode < 500) {
    message = [NSString stringWithFormat: format, kErrorNoAuthorization, (long)statusCode];
  } else if (statusCode >= 500 && statusCode < 600) {
    message = [NSString stringWithFormat: format, kErrorBusyOrServerError, (long)statusCode];
  } else {
    message = [NSString stringWithFormat: format, kErrorBusyOrServerError, (long)statusCode];
  }

  [AlertPopover presentAlert: title message: message parent: parent handler: handler];
}

+ (void) alert: (NSString *)title withDescription: (NSString *)message controller: (UIViewController *)parent completion: (void(^)(void)) handler {

  [AlertPopover presentAlert: title message: message parent: parent handler: handler];
}

+ (void) presentAlert: (NSString *)title message: (NSString *)message parent: (UIViewController *)parent handler: (void(^)(void)) handler {
  
  UIViewController *anchorVC = parent ? parent : [[UIApplication sharedApplication].delegate window].rootViewController;
  UIAlertController *alert = [UIAlertController alertControllerWithTitle: title message: message preferredStyle: UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = anchorVC.view;
  alert.popoverPresentationController.sourceRect = anchorVC.view.frame;
  
  UIAlertAction *okAction = [UIAlertAction actionWithTitle: kActionOk style: UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
    if (handler) {
      handler();
    }
  }];
  [alert addAction: okAction];
  
  [anchorVC presentViewController: alert animated: YES completion: nil];
}

@end
