//
//  UserProfileViewController.m
//  StackOverflowClient
//
//  Created by mike davis on 9/15/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "UserProfileViewController.h"
#import "StackOverflowService.h"
#import "User.h"
#import "AlertPopover.h"

static NSString *kUserProfileError = @"Search Error";
static NSString *const kQueueName = @"com.mdaviscph.stackoverflowclient.user_search";

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bronzeBadgesLabel;
@property (weak, nonatomic) IBOutlet UILabel *silverBadgesLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldBadgesLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *profileImageUrl;    // observed with KVO

@end

@implementation UserProfileViewController

#pragma mark - Private Properties Getters, Setters

- (void)setProfileImage:(UIImage *)profileImage {
  _profileImage = profileImage;
  self.imageView.image = profileImage;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"vDL User Profile");
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [StackOverflowService meSearchWithCompletion:^(User *results, NSError *error) {
    if (results) {
      self.user = results;
      self.displayNameLabel.text = self.user.displayName;
      self.userIdLabel.text = self.user.userId;
      self.bronzeBadgesLabel.text = [NSString stringWithFormat:@"%ld", self.user.bronzeBadges];
      self.silverBadgesLabel.text = [NSString stringWithFormat:@"%ld", self.user.silverBadges];
      self.goldBadgesLabel.text = [NSString stringWithFormat:@"%ld", self.user.goldBadges];
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.dateFormat = @"MM/dd/yyyy";
      self.createdDateLabel.text = [dateFormatter stringFromDate: self.user.creation];
      
      // as an exercise I am using KVO to watch this property so that when it is
      // set then I can download the image
      self.profileImageUrl = self.user.profileImageUrl;
      
    } else {
      NSString *errorTitle = NSLocalizedString(kUserProfileError, nil);
      NSError *reachableError = [StackOverflowService reachableError];
      NSString *generalMessage = NSLocalizedString(@"An undefined error occurred. Please try again later.", nil);
      if (error) {
        [AlertPopover alert:errorTitle withNSError:[StackOverflowService convertStackOverflowError:error] controller:self completion:nil];
      } else if (reachableError) {
        [AlertPopover alert:errorTitle withNSError:reachableError controller:self completion:nil];
      } else {
        [AlertPopover alert:errorTitle withDescription:generalMessage controller:self completion:nil];
      }
    }
  }];  
}

@end
