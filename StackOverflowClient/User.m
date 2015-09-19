//
//  User.m
//  StackOverflowClient
//
//  Created by mike davis on 9/18/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import "User.h"

@implementation User

+ (User *)createUsingJSON:(NSDictionary *)jsonDictionary {
  
  User *user = [[User alloc] init];
  
  user.userId = [(NSNumber *)jsonDictionary[@"user_id"] stringValue];
  
  NSTimeInterval unixDate = [(NSNumber *)jsonDictionary[@"creation_date"] integerValue];
  user.creation = [NSDate dateWithTimeIntervalSince1970:unixDate];
  
  user.displayName = jsonDictionary[@"display_name"];
  user.profileImageUrl = jsonDictionary[@"profile_image"];
  
  NSDictionary *badgeDictionary = jsonDictionary[@"badge_counts"];
  if (badgeDictionary) {
    user.bronzeBadges = [(NSNumber *)badgeDictionary[@"bronze"] integerValue];
    user.bronzeBadges = [(NSNumber *)badgeDictionary[@"silver"] integerValue];
    user.bronzeBadges = [(NSNumber *)badgeDictionary[@"gold"] integerValue];
  }
  return user;
}

@end
