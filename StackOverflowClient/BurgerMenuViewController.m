//
//  BurgerMenuViewController.m
//  StackOverflowClient
//
//  Created by mike davis on 9/15/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "BurgerMenuViewController.h"
#import "SearchQuestionsViewController.h"
#import "UserProfileViewController.h"
#import "UserQuestionsViewController.h"

static const CGFloat kBurgerButtonWidth = 50;
static const CGFloat kBurgerButtonHeight = 50;
static const NSTimeInterval kDefaultAnimationDuration = 0.3;
static const CGFloat kBurgerMenuOpenWidthMultiplier = 1.2;

@interface BurgerMenuViewController () <UITableViewDelegate>

@property (strong, nonatomic) UITableViewController *mainMenuVC;
@property (strong, nonatomic) SearchQuestionsViewController *searchQuestionsVC;
@property (strong, nonatomic) UserProfileViewController *userProfileVC;
@property (strong, nonatomic) UserQuestionsViewController *userQuestionsVC;

@property (strong, nonatomic) NSArray *menuItemVCs;
@property (strong, nonatomic) UIViewController *topVC;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@property (strong, nonatomic) UIButton *burgerButton;
@end

@implementation BurgerMenuViewController

#pragma mark - Private Properties Getters, Setters

- (NSArray *)menuItemVCs {
  if (!_menuItemVCs) {
    _menuItemVCs = @[self.searchQuestionsVC, self.userProfileVC, self.userQuestionsVC];
  }
  return _menuItemVCs;
}

- (UITableViewController *)mainMenuVC {
  if (!_mainMenuVC) {
    _mainMenuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainMenuVC"];
  }
  return _mainMenuVC;
}
- (SearchQuestionsViewController *)searchQuestionsVC {
  if (!_searchQuestionsVC) {
    _searchQuestionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchQuestionsVC"];
  }
  return _searchQuestionsVC;
}

- (UserProfileViewController *)userProfileVC {
  if (!_userProfileVC) {
    _userProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileVC"];
  }
  return _userProfileVC;
}

- (UserQuestionsViewController *)userQuestionsVC {
  if (!_userQuestionsVC) {
    _userQuestionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UserQuestionsVC"];
  }
  return _userQuestionsVC;
}

- (UIButton *)burgerButton {
  if (!_burgerButton) {
    _burgerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kBurgerButtonWidth, kBurgerButtonHeight)];
  }
  return _burgerButton;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.mainMenuVC.tableView.delegate = self;
  [self addChildVC:self.mainMenuVC];
  
  self.topVC = self.menuItemVCs.firstObject;
  [self addChildVC:self.topVC];

  [self.burgerButton setImage:[UIImage imageNamed:@"burger"] forState:UIControlStateNormal];
  [self.topVC.view addSubview:self.burgerButton];
  [self.burgerButton addTarget:self action:@selector(burgerButtonUp:) forControlEvents:UIControlEventTouchUpInside];
  self.panRecognizer = [self addPanGRwithSelfAsTarger:self.topVC];


}

#pragma mark - Helper Methods

- (void)addChildVC:(UIViewController *)childVC {
  [self addChildViewController:childVC];
  childVC.view.frame = self.view.frame;
  [self.view addSubview:childVC.view];
  [childVC didMoveToParentViewController:self];
}
- (void)removeChildVC:(UIViewController *)childVC {
  [childVC willMoveToParentViewController:nil];
  [childVC.view removeFromSuperview];
  [childVC removeFromParentViewController];
}

- (UIPanGestureRecognizer *)addPanGRwithSelfAsTarger:(UIViewController *)childVC {
  UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topVCpan:)];
  [childVC.view addGestureRecognizer:panRecognizer];
  return panRecognizer;
}
- (UITapGestureRecognizer *)addTapGRwithSelfAsTarger:(UIViewController *)childVC {
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topVCtap:)];
  [childVC.view addGestureRecognizer:tapRecognizer];
  return tapRecognizer;
}

- (void)removePanGR:(UIPanGestureRecognizer *)gestureRecognizer from:(UIViewController *)childVC {
  [childVC.view removeGestureRecognizer:gestureRecognizer];
}
- (void)removeTapGR:(UITapGestureRecognizer *)gestureRecognizer from:(UIViewController *)childVC {
  [childVC.view removeGestureRecognizer:gestureRecognizer];
}

#pragma mark - Selectors
- (void)burgerButtonUp:(UIButton *)sender {
  
}

- (void)topVCpan:(UIPanGestureRecognizer *)sender {
  
  CGFloat xTranslation = [sender translationInView:self.topVC.view].x;
  CGFloat xVelocity = [sender velocityInView:self.topVC.view].x;
  [sender setTranslation:CGPointZero inView:self.topVC.view];
  switch (sender.state) {
    case UIGestureRecognizerStateChanged:
      if (xVelocity > 0) {
        self.topVC.view.center = CGPointMake(self.topVC.view.center.x + xTranslation, self.topVC.view.center.y);
      }
      break;
    case UIGestureRecognizerStateEnded:
      if (self.topVC.view.center.x != [self centerOfOpenVC:self.topVC].x) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
          self.topVC.view.center = [self centerOfOpenVC:self.topVC];
        } completion:^(BOOL finished) {
          [self addTapGRwithSelfAsTarger:self.topVC];
          self.burgerButton.userInteractionEnabled = NO;
        } ];
      }
      break;
    default:
      break;
  }
}
- (void)topVCtap:(UITapGestureRecognizer *)sender {
  [self removeTapGR:[self tapRecognizer] from:self.topVC];
  self.topVC.view.center = self.view.center;
  self.burgerButton.userInteractionEnabled = YES;
  
}

- (CGPoint)centerOfOpenVC:(UIViewController *)openVC {
  return CGPointMake(MAX(MIN(self.view.center.x, openVC.view.center.x), openVC.view.frame.size.width * kBurgerMenuOpenWidthMultiplier), openVC.view.center.y);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.topVC.view.center = self.view.center;
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
