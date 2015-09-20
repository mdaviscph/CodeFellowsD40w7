//
//  CommentCell.h
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

@interface CommentCell : UITableViewCell

@property (strong, nonatomic) Comment *comment;

@end
