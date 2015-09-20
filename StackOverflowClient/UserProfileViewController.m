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

static NSString *kUserProfileError = @"User Profile Error";

@interface UserProfileViewController ()

@property (retain, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *bronzeBadgesLabel;
@property (retain, nonatomic) IBOutlet UILabel *silverBadgesLabel;
@property (retain, nonatomic) IBOutlet UILabel *goldBadgesLabel;
@property (retain, nonatomic) IBOutlet UILabel *userIdLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@property (retain, nonatomic) User *user;
@property (retain, nonatomic) NSString *profileImageUrl;    // observed with KVO

@end

@implementation UserProfileViewController

#pragma mark - Private Properties Getters, Setters

- (void)setProfileImage:(UIImage *)profileImage {
  [_profileImage release];
  _profileImage = [profileImage retain];
  self.imageView.image = [profileImage retain];
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
      self.user = [results retain];
      
      self.displayNameLabel.text = [self.user.displayName retain];
      self.userIdLabel.text = [self.user.userId retain];
      self.bronzeBadgesLabel.text = [[NSString stringWithFormat:@"%ld", self.user.bronzeBadges] retain];
      self.silverBadgesLabel.text = [[NSString stringWithFormat:@"%ld", self.user.silverBadges] retain];
      self.goldBadgesLabel.text = [[NSString stringWithFormat:@"%ld", self.user.goldBadges] retain];
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.dateFormat = @"MM/dd/yyyy";
      self.createdDateLabel.text = [[dateFormatter stringFromDate: self.user.creation] retain];
      
      // as an exercise I am using KVO to watch this property so that when it is
      // set then I can download the image
      self.profileImageUrl = [self.user.profileImageUrl retain];

      [dateFormatter release];
      
    } else {
      
      NSString *errorTitle = NSLocalizedString(kUserProfileError, nil);
      NSError *reachableError = [[StackOverflowService reachableError] retain];
      NSString *generalMessage = NSLocalizedString(@"An undefined error occurred. Please try again later.", nil);
      if (error) {
        [AlertPopover alert:errorTitle withNSError:[StackOverflowService convertStackOverflowError:error] controller:self completion:nil];
      } else if (reachableError) {
        [AlertPopover alert:errorTitle withNSError:reachableError controller:self completion:nil];
      } else {
        [AlertPopover alert:errorTitle withDescription:generalMessage controller:self completion:nil];
      }
      [reachableError release];
    }
  }];  
}

- (void)dealloc {
  
  [_user release];
  [_profileImage release];
  [_profileImageUrl release];
  
  [_displayNameLabel release];
  [_createdDateLabel release];
  [_bronzeBadgesLabel release];
  [_silverBadgesLabel release];
  [_goldBadgesLabel release];
  [_userIdLabel release];
  [_imageView release];
  
  [super dealloc];
}
@end
