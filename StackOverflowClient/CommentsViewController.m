//
//  CommentsViewController.m
//  StackOverflowClient
//
//  Created by mike davis on 9/15/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "Comment.h"
#import "StackOverflowService.h"
#import "AlertPopover.h"
#import "Constants.h"

static NSString *kCommentSearchError = @"Comment Search Error";

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *comments;

@end

@implementation CommentsViewController

#pragma mark - Private Properties Getters, Setters

@synthesize comments = _comments;
- (NSArray *)comments {
  if (!_comments) {
    _comments = [[NSArray alloc] init];
  }
  return _comments;
}
- (void)setComments:(NSArray *)comments {
  _comments = comments;
  [self.tableView reloadData];
}

@synthesize commentSearchTerm = _commentSearchTerm;
- (NSString *)commentSearchTerm {
  if (!_commentSearchTerm) {
    _commentSearchTerm = [[NSString alloc] init];
  }
  return _commentSearchTerm;
}
- (void)setCommentSearchTerm:(NSString *)commentSearchTerm {
  _commentSearchTerm = commentSearchTerm;
  [self commentSearch:commentSearchTerm];
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"vDL Search Comments");
  
  self.searchBar.placeholder = NSLocalizedString(@"Search user ID", nil);
  [self.searchBar becomeFirstResponder];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.estimatedRowHeight = self.tableView.rowHeight;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  
  self.searchBar.delegate = self;
  NSString *previousSearch = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCommentSearchKey];
  if (previousSearch) {
    self.searchBar.text = previousSearch;
    self.commentSearchTerm = previousSearch;
  }
}

#pragma mark - Helper Methods

- (void)commentSearch:(NSString *)userId {
  
  if (!userId || userId.length == 0) {
    return;
  }
  
  [StackOverflowService commentSearch:userId completion:^(NSArray *results, NSError *error) {
    
    if (results) {
      
      // save off last successful title search
      [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kUserDefaultsCommentSearchKey];

      self.comments = results;       // this triggers a tableView reload
      
    } else {
      NSString *errorTitle = NSLocalizedString(kCommentSearchError, nil);
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
  return self.comments.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
  
  cell.comment = self.comments[indexPath.row];

  return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  
  [self.searchBar resignFirstResponder];
  self.commentSearchTerm = self.searchBar.text;   // this triggers the search
}

@end
