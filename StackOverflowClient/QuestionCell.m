//
//  QuestionCell.m
//  StackOverflowClient
//
//  Created by mike davis on 9/19/15.
//  Copyright © 2015 mike davis. All rights reserved.
//

#import "QuestionCell.h"
#import "Question.h"
#import "StringExtensions.h"

@interface QuestionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation QuestionCell

- (void)setQuestion:(Question *)question {
  _question = question;
  self.titleLabel.text = [NSString stringByRemovingHTMLentityReferences:question.title];
  self.displayNameLabel.text = [NSString stringWithFormat:@"%@  (%@)", [NSString stringByRemovingHTMLentityReferences:question.displayName], question.userId];
}

- (void)setProfileImage:(UIImage *)profileImage {
  _profileImage = profileImage;
  self.profileImageView.image = profileImage;
}
@end
