//
//  StringExtensions.m
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import "StringExtensions.h"

@implementation NSString (Extensions)

// just going to replace the most common ones
// TODO - do this more efficiently!
+ (NSString *)stringByRemovingHTMLentityReferences:(NSString *)string {
  
  NSString *result = string;
  
  result = [result stringByReplacingOccurrencesOfString:@"&#34;" withString:@"\""];
  result = [result stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
  result = [result stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
  result = [result stringByReplacingOccurrencesOfString:@"&#60;" withString:@"<"];
  result = [result stringByReplacingOccurrencesOfString:@"&#62;" withString:@">"];

  result = [result stringByReplacingOccurrencesOfString:@"&#34" withString:@"\""];
  result = [result stringByReplacingOccurrencesOfString:@"&#38" withString:@"&"];
  result = [result stringByReplacingOccurrencesOfString:@"&#39" withString:@"'"];
  result = [result stringByReplacingOccurrencesOfString:@"&#60" withString:@"<"];
  result = [result stringByReplacingOccurrencesOfString:@"&#62" withString:@">"];

  result = [result stringByReplacingOccurrencesOfString:@"&34" withString:@"\""];
  result = [result stringByReplacingOccurrencesOfString:@"&38" withString:@"&"];
  result = [result stringByReplacingOccurrencesOfString:@"&39" withString:@"'"];
  result = [result stringByReplacingOccurrencesOfString:@"&60" withString:@"<"];
  result = [result stringByReplacingOccurrencesOfString:@"&62" withString:@">"];

  result = [result stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
  result = [result stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  result = [result stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
  result = [result stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
  result = [result stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];

  result = [result stringByReplacingOccurrencesOfString:@"&quot" withString:@"\""];
  result = [result stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
  result = [result stringByReplacingOccurrencesOfString:@"&apos" withString:@"'"];
  result = [result stringByReplacingOccurrencesOfString:@"&lt" withString:@"<"];
  result = [result stringByReplacingOccurrencesOfString:@"&gt" withString:@">"];

  return result;
}

@end
