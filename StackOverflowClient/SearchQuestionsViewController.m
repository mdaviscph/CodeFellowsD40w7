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

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *tableController;
@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) NSArray *questions;

@end

@implementation SearchQuestionsViewController

#pragma mark - Private Properties Getters, Setters

- (UISearchController *)searchController {
  if (!_searchController) {
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_tableController];
  }
  return _searchController;
}

- (UITableViewController *)tableController {
  if (!_tableController) {
    _tableController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
  }
  return _tableController;
}

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

  self.tableController.tableView.frame = self.view.frame;
  [self.searchController.searchBar sizeToFit];
  self.searchController.searchBar.placeholder = @"Search title";
  [self.searchBarView addSubview:self.searchController.searchBar];
  
  self.tableController.tableView.delegate = self;
  self.tableController.tableView.dataSource = self;
  [self.tableController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"Cell"];
  
  self.searchController.searchBar.delegate = self;
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
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  [self presentViewController:self.searchController animated:YES completion:nil];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  
  [self.searchController resignFirstResponder];
  NSString *searchTerm = self.searchController.searchBar.text;
  if (!searchTerm || searchTerm.length == 0) {
    return;
  }
  
  [StackOverflowService search:searchTerm completion:^(NSArray *results, NSError *error) {
    if (results) {
      self.questions = results;
      [self.tableController.tableView reloadData];
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
