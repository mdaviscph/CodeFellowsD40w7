//
//  CommentCell.m
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"
#import "StringExtensions.h"

@interface CommentCell ()

@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end

@implementation CommentCell

- (void)setComment:(Comment *)comment {
  _comment = comment;
  self.bodyLabel.text = [NSString stringByRemovingHTMLentityReferences:comment.body];
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)comment.score];
}


@end
