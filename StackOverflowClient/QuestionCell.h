//
//  QuestionCell.h
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Question;
@class UIImage;

@interface QuestionCell : UITableViewCell

@property (strong, nonatomic) Question *question;
@property (strong, nonatomic) UIImage *profileImage;

@end
