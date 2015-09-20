//
//  StackOverflowService.h
//  StackOverflowClient
//
//  Created by mike davis on 9/17/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

enum StackOverflowErrors {
  ErrorInvalidRequestParameter = 100,
  ErrorAuthorizationOrAccess = 110,
  ErrorAPIerror = 120,
  ErrorServiceLimit = 130,
  ErrorReachability = 140
};
typedef enum StackOverflowErrors StackOverflowErrors;

@interface StackOverflowService : NSObject

+ (void)questionSearch:(NSString *)search completion:(void (^)(NSArray *, NSError *))completion;
+ (void)commentSearch:(NSString *)search completion:(void (^)(NSArray *, NSError *))completion;
+ (void)meSearchWithCompletion:(void (^)(User *, NSError *))completion;
  
+ (NSError *)reachableError;
+ (NSError *)convertStackOverflowError:(NSError *)soError;

@end
