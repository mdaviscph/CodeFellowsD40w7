//
//  Question.h
//  StackOverflowClient
//
//  Created by mike davis on 9/17/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *profileImageUrl;

+ (Question *)createUsingJSON:(NSDictionary *)jsonDictionary;

@end
