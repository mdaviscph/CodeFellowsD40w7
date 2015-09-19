//
//  StackOverflowService.m
//  StackOverflowClient
//
//  Created by mike davis on 9/17/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import "StackOverflowService.h"
#import "Question.h"
#import "User.h"
#import "Keys.h"
#import <AFNetworking/AFNetworking.h>

static NSString *const kTitleSearch = @"https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=%@&site=stackoverflow&key=%@&access_token=%@";
static NSString *const kUserDetailSearch = @"https://api.stackexchange.com/2.2/me?order=desc&sort=reputation&site=stackoverflow&key=%@&access_token=%@";
static NSString *const kUserDefaultsTokenKey = @"StackOverflowToken"; //TODO switch to KeyChain
static NSString *const domain = @"com.mdaviscph.stackoverflowclient";

@implementation StackOverflowService

+ (void)questionSearch:(NSString *)search completion:(void (^)(NSArray *, NSError *))completion {
  
  NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsTokenKey];

  NSString *url = [NSString stringWithFormat:kTitleSearch, search, kStackOverflowKey, token];
  NSLog(@"<%@>", url);
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
  [manager GET:url parameters:nil
   
       success:^(AFHTTPRequestOperation* _Nonnull operation, id _Nonnull responseObject) {
         
    NSMutableArray *questions;

    NSDictionary *responseJSON = responseObject;
    NSArray *itemsJSON = responseJSON[@"items"];

    if (itemsJSON) {
      NSLog(@"Request success: %ld items", itemsJSON.count);
      questions = [[NSMutableArray alloc] init];
      for (NSDictionary *item in itemsJSON) {
        Question *question = [Question createUsingJSON:item];
        if (question) {
          [questions addObject:question];
        }
      }
    }
    completion(questions, nil);
  }
   
       failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {

    NSLog(@"Request failure: %ld", operation.response.statusCode);
    completion(nil, error);
  }];
}

+ (void)meSearchWithCompletion:(void (^)(User *, NSError *))completion {
  
  NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsTokenKey];
  
  NSString *url = [NSString stringWithFormat:kUserDetailSearch, kStackOverflowKey, token];
  NSLog(@"<%@>", url);
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
  [manager GET:url parameters:nil
   
       success:^(AFHTTPRequestOperation* _Nonnull operation, id _Nonnull responseObject) {
         
         User *user;
         
         NSDictionary *responseJSON = responseObject;
         NSArray *itemsJSON = responseJSON[@"items"];
         if (itemsJSON) {
           NSLog(@"Request success: %ld items", itemsJSON.count);
          user = [User createUsingJSON:[itemsJSON firstObject]];
         }
         completion(user, nil);
       }
   
       failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         
         NSLog(@"Request failure: %ld", operation.response.statusCode);
         completion(nil, error);
       }];
}

+ (NSError *)reachableError {

  if ([AFNetworkReachabilityManager sharedManager].reachable) {
    return nil;
  }
  NSString *localizedDescription = NSLocalizedString(@"Server or network error. Please try again later.", nil);
  NSError *error = [[NSError alloc] initWithDomain:domain code:ErrorReachability userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
  return error;
}

// Error codes returned from StackOverflow
//bad_parameter – 400 An invalid parameter was passed, this includes even "high level" parameters like key or site.
//access_token_required – 401 A method that requires an access token (obtained via authentication) was called without one.
//invalid_access_token – 402 An invalid access token was passed to a method.
//access_denied – 403 A method which requires certain permissions was called with an access token that lacks those permissions.
//no_method – 404 An attempt was made to call a method that does not exist. Note, calling methods that expect numeric ids (like /users/{ids}) with non-numeric ids can also result in this error.
//key_required – 405 A method was called in a manner that requires an application key (generally, with an access token), but no key was passed.
//access_token_compromised – 406 An access token is no longer believed to be secure, normally because it was used on a non-HTTPS call. The access token will be invalidated if this error is returned.
//write_failed – 407 A write operation was rejected, see the returned error_message for more details.
//duplicate_request – 409 A request identified by a request_id has already been run.
//internal_error – 500 An unexpected error occurred in the API. It has been logged, and Stack Exchange developers have been notified. You should report these errors on Stack Apps if you want to be notified when they're fixed.
//throttle_violation – 502 An application has violated part of the rate limiting contract, so the request was terminated.
//temporarily_unavailable – 503 Some or all of the API is unavailable. Applications should backoff on requests to the method invoked.

+ (NSError *)convertStackOverflowError:(NSError *)soError {
  
  NSString *errorDescription;
  NSInteger code;
  
  switch (soError.code) {
    case 400:
      code = ErrorInvalidRequestParameter;
      errorDescription = NSLocalizedString(@"Invalid parameter in search or request string. Please reword your search or request.", nil);
      break;
    case 401:
      code = ErrorAuthorizationOrAccess;
      errorDescription = NSLocalizedString(@"No authorization for this request. Please reword your request.", nil);
      break;
    case 402:
      code = ErrorAuthorizationOrAccess;
      errorDescription = NSLocalizedString(@"Access denied. Please retry your request after restarting this application.", nil);
      break;
    case 403:
      code = ErrorAuthorizationOrAccess;
      errorDescription = NSLocalizedString(@"No authorization for this request. Please reword your request.", nil);
      break;
    case 404:
      code = ErrorAPIerror;
      errorDescription = NSLocalizedString(@"This application may require an update due to a StackOverflow API change.", nil);
      break;
    case 405:
      code = ErrorAuthorizationOrAccess;
      errorDescription = NSLocalizedString(@"Access denied. Please retry your request after restarting this application.", nil);
      break;
    case 406:
      code = ErrorAuthorizationOrAccess;
      errorDescription = NSLocalizedString(@"Access denied. Please reset the settings for this application, this may require a re-intallation.", nil);
      break;
    case 407:
      code = ErrorAPIerror;
      errorDescription = NSLocalizedString(@"Unable to upload information to StackOverflow. Please try again later.", nil);
      break;
    case 409:
      code = ErrorServiceLimit;
      errorDescription = NSLocalizedString(@"StackOverflow has indicated that this is a duplicate request.", nil);
      break;
    case 500:
      code = ErrorAPIerror;
      errorDescription = NSLocalizedString(@"StackOverflow has indicated an API error. Please reword or retry your request.", nil);
      break;
    case 502:
      code = ErrorServiceLimit;
      errorDescription = NSLocalizedString(@"Too many requests in a short time period. Please wait and then retry your search or request.", nil);
      break;
    case 503:
      code = ErrorServiceLimit;
      errorDescription = NSLocalizedString(@"Too many requests in a short time period. Please wait and then retry your search or request.", nil);
      break;
    default:
      code = ErrorAPIerror;
      errorDescription = NSLocalizedString(@"This application may require an update due to a StackOverflow API change.", nil);
      break;
  }
  
  // save original NSError and a detailed NSError with text from StackOverflow's website
  NSString *localizedDetailed = [self stackOverflowExplanation:soError.code];
  NSError *detailedError = [[NSError alloc] initWithDomain:domain code:soError.code userInfo:@{NSLocalizedDescriptionKey : localizedDetailed}];
  
  NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey : errorDescription, @"NSDetailedErrors" : @[soError, detailedError]}];
  
  return error;
}

// Text for error codes from https://api.stackexchange.com/docs/error-handling
+ (NSString *)stackOverflowExplanation:(NSInteger)code {
  switch (code) {
    case 400:
      return NSLocalizedString(@"An invalid parameter was passed, this includes even high level parameters like key or site.", nil);
    case 401:
      return NSLocalizedString(@"A method that requires an access token (obtained via authentication) was called without one.", nil);
    case 402:
      return NSLocalizedString(@"An invalid access token was passed to a method.", nil);
    case 403:
      return NSLocalizedString(@"A method which requires certain permissions was called with an access token that lacks those permissions.", nil);
    case 404:
      return NSLocalizedString(@"An attempt was made to call a method that does not exist. Note, calling methods that expect numeric ids (like /users/{ids}) with non-numeric ids can also result in this error.", nil);
    case 405:
      return NSLocalizedString(@"A method was called in a manner that requires an application key (generally, with an access token), but no key was passed.", nil);
    case 406:
      return NSLocalizedString(@"An access token is no longer believed to be secure, normally because it was used on a non-HTTPS call. The access token will be invalidated if this error is returned.", nil);
    case 407:
      return NSLocalizedString(@"A write operation was rejected, see the returned error_message for more details.", nil);
    case 409:
      return NSLocalizedString(@"A request identified by a request_id has already been run.", nil);
    case 500:
      return NSLocalizedString(@"An unexpected error occurred in the API. It has been logged, and Stack Exchange developers have been notified. You should report these errors on Stack Apps if you want to be notified when they're fixed.", nil);
    case 502:
      return NSLocalizedString(@"An application has violated part of the rate limiting contract, so the request was terminated.", nil);
    case 503:
      return NSLocalizedString(@"Some or all of the API is unavailable. Applications should backoff on requests to the method invoked.", nil);
    default:
      return NSLocalizedString(@"An undefined error has been returned by StackOverflow.com", nil);
  }
}

@end
