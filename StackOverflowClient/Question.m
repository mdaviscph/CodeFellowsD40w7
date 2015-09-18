//
//  Question.m
//  StackOverflowClient
//
//  Created by mike davis on 9/17/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import "Question.h"

@implementation Question

+ (Question *)createUsingJSON:(NSDictionary *)jsonDictionary {
  
  Question *question = [[Question alloc] init];
  question.title = jsonDictionary[@"title"];
  NSDictionary *ownerDictionary = jsonDictionary[@"owner"];
  if (ownerDictionary) {
    question.displayName = ownerDictionary[@"display_name"];
    question.profileImageUrl = ownerDictionary[@"profile_image"];
  }
  return question;
}
@end
