//
//  SearchQuestionsViewController.m
//  StackOverflowClient
//
//  Created by mike davis on 9/15/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "SearchQuestionsViewController.h"
#import "Question.h"
#import "StackOverflowService.h"
#import "AlertPopover.h"

static NSString *kSearchError = @"Search Error";
static NSString *kSearchImagesReturned = @"Images Returned";
static NSString *const kQueueName = @"com.mdaviscph.stackoverflowclient.question_search";

@interface SearchQuestionsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) NSMutableDictionary *profileImages;

@end

@implementation SearchQuestionsViewController

#pragma mark - Private Properties Getters, Setters

- (NSArray *)questions {
  if (!_questions) {
    _questions = [[NSArray alloc] init];
  }
  return _questions;
}

- (void)setProfileImages:(NSMutableDictionary *)profileImages {
  _profileImages = profileImages;
  if (_profileImages.count > 0) {
    [self downloadImages];
  }
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"vDL SearchQuestionsViewController");

  self.searchBar.placeholder = @"Search title";
  [self.searchBar becomeFirstResponder];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.searchBar.delegate = self;
}

#pragma mark - Helper Methods
- (void)downloadImages {
  dispatch_group_t imagesDispatchGroup = dispatch_group_create();
  dispatch_queue_t imageQueue = dispatch_queue_create(kQueueName.UTF8String, DISPATCH_QUEUE_CONCURRENT);
  
  for (id object in [self.profileImages allKeys]) {
    dispatch_group_async(imagesDispatchGroup, imageQueue, ^{
      //NSLog(@"[%@]", object);
      UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:object]]];
      self.profileImages[object] = image;
    });
  }
  dispatch_group_notify(imagesDispatchGroup, dispatch_get_main_queue(), ^{
    [AlertPopover alert:kSearchImagesReturned withDescription:@"" controller:self completion:nil];
    [self.tableView reloadData];
  });
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.questions.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  Question *question = self.questions[indexPath.row];
  cell.textLabel.text = question.title;
  cell.detailTextLabel.text = question.displayName;
  id object = self.profileImages[question.profileImageUrl];
  if (![object isEqual:[NSNull null]]) {
    cell.imageView.image = object;
  }
  return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  
  [self.searchBar resignFirstResponder];
  NSString *searchTerm = self.searchBar.text;
  if (!searchTerm || searchTerm.length == 0) {
    return;
  }
  
  [StackOverflowService questionSearch:searchTerm completion:^(NSArray *results, NSError *error) {
    if (results) {
      self.questions = results;
      // for this exercise we are to download all images at one time, rather than lazy loading,
      // using a dispatch group
      NSMutableDictionary *profileImageUrls = [[NSMutableDictionary alloc] init];
      for (Question * question in self.questions) {
        if (question.profileImageUrl) {
          profileImageUrls[question.profileImageUrl] = [NSNull null];
        }
      }
      self.profileImages = profileImageUrls;
      [self.tableView reloadData];
    } else {
      NSString *errorTitle = NSLocalizedString(kSearchError, nil);
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
