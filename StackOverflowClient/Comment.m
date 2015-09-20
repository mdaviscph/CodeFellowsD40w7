//
//  Comment.m
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import "Comment.h"

@implementation Comment

+ (Comment *)createUsingJSON:(NSDictionary *)jsonDictionary {
  
  Comment *comment = [[Comment alloc] init];
  
  comment.body = jsonDictionary[@"body"];
  comment.body = [comment.body stringByRemovingPercentEncoding];
  comment.commentId = [(NSNumber *)jsonDictionary[@"user_id"] stringValue];
  comment.score = [(NSNumber *) jsonDictionary[@"score"] integerValue];
  
  NSDictionary *ownerDictionary = jsonDictionary[@"owner"];
  if (ownerDictionary) {
    comment.userId = [(NSNumber *)ownerDictionary[@"user_id"] stringValue];
    comment.displayName = ownerDictionary[@"display_name"];
    comment.displayName = [comment.displayName stringByRemovingPercentEncoding];
  }
  return comment;
}

@end
