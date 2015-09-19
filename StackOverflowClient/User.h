//
//  User.h
//  StackOverflowClient
//
//  Created by mike davis on 9/18/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSDate *creation;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) NSString *displayName;
@property (nonatomic) NSInteger bronzeBadges;
@property (nonatomic) NSInteger silverBadges;
@property (nonatomic) NSInteger goldBadges;

+ (User *)createUsingJSON:(NSDictionary *)jsonDictionary;

@end
