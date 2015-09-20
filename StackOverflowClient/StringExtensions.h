//
//  StringExtensions.h
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

+ (NSString *)stringByRemovingHTMLentityReferences:(NSString *)string;

@end
