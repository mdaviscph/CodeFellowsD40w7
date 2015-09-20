//
//  SearchQuestionsViewController.m
//  StackOverflowClient
//
//  Created by mike davis on 9/15/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "SearchQuestionsViewController.h"
#import "QuestionCell.h"
#import "Question.h"
#import "StackOverflowService.h"
#import "AlertPopover.h"
#import "Constants.h"

static NSString *kQuestionSearchError = @"Question Search Error";
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

@synthesize questions = _questions;
- (NSArray *)questions {
  if (!_questions) {
    _questions = [[NSArray alloc] init];
  }
  return _questions;
}
- (void)setQuestions:(NSArray *)questions {
  _questions = questions;
  [self.tableView reloadData];
}

@synthesize titleSearchTerm = _titleSearchTerm;
- (NSString *)titleSearchTerm {
  if (!_titleSearchTerm) {
    _titleSearchTerm = [[NSString alloc] init];
  }
  return _titleSearchTerm;
}
- (void)setTitleSearchTerm:(NSString *)titleSearchTerm {
  _titleSearchTerm = titleSearchTerm;
  [self titleSearch:titleSearchTerm];
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
  NSLog(@"vDL Search Questions");

  self.searchBar.placeholder = NSLocalizedString(@"Search title", nil);
  [self.searchBar becomeFirstResponder];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.estimatedRowHeight = self.tableView.rowHeight;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  
  self.searchBar.delegate = self;
  NSString *previousSearch = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsTitleSearchKey];
  if (previousSearch) {
    self.searchBar.text = previousSearch;
    self.titleSearchTerm = previousSearch;
  }
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

- (void)titleSearch:(NSString *)title {
  
  if (!title || title.length == 0) {
    return;
  }
  
  [StackOverflowService questionSearch:title completion:^(NSArray *results, NSError *error) {
    
    if (results) {
      
      // save off last successful title search
      [[NSUserDefaults standardUserDefaults] setObject:title forKey:kUserDefaultsTitleSearchKey];
      
      // for this exercise we are to download all images at one time, rather than lazy loading,
      // using a dispatch group
      NSMutableDictionary *profileImageUrls = [[NSMutableDictionary alloc] init];
      for (Question * question in results) {
        if (question.profileImageUrl) {
          profileImageUrls[question.profileImageUrl] = [NSNull null];
        }
      }
      self.profileImages = profileImageUrls;
      self.questions = results;       // this triggers a tableView reload
      
    } else {
      NSString *errorTitle = NSLocalizedString(kQuestionSearchError, nil);
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

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.questions.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionCell" forIndexPath:indexPath];
  
  cell.question = self.questions[indexPath.row];
  
  id object = self.profileImages[[self.questions[indexPath.row] profileImageUrl]];
  if (![object isEqual:[NSNull null]]) {
    cell.profileImage = object;
  }
  return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  
  [self.searchBar resignFirstResponder];
  self.titleSearchTerm = self.searchBar.text;   // this triggers the search
}

@end
