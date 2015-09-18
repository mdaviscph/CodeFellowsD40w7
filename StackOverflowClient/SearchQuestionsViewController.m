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

@interface SearchQuestionsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *questions;

@end

@implementation SearchQuestionsViewController

#pragma mark - Private Properties Getters, Setters

- (NSArray *)questions {
  if (!_questions) {
    _questions = [[NSArray alloc] init];
  }
  return _questions;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"vDL SearchQuestionsViewController");

  self.searchBar.placeholder = @"Search title";
  [self.searchBar becomeFirstResponder];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"Cell"];
  
  self.searchBar.delegate = self;
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
  
  [StackOverflowService search:searchTerm completion:^(NSArray *results, NSError *error) {
    if (results) {
      self.questions = results;
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
