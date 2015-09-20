//
//  Comment.h
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *commentId;
@property (strong, nonatomic) NSString *body;
@property (nonatomic) NSInteger score;

+ (Comment *)createUsingJSON:(NSDictionary *)jsonDictionary;

@end
