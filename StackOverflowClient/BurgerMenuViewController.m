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
#import "WebViewController.h"

static const CGFloat kBurgerButtonWidth = 50;
static const CGFloat kBurgerButtonHeight = 50;
static const NSTimeInterval kOpenAnimationDuration = 0.3;
static const NSTimeInterval kCloseAnimationDuration = 0.4;
static const NSTimeInterval kOffscreenAnimationDuration = 0.4;
static const CGFloat kBurgerMenuOpenPercent = 0.60;

static NSString *const kUserDefaultsTokenKey = @"StackOverflowToken";
static NSString *const kUserDefaultsKeyKey = @"StackOverflowToken";

static NSString *const kKVOuserProfileUrl = @"profileImageUrl";

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
    // order of VCs must match the order of cells for the static tableViewController in Storyboard
    _menuItemVCs = @[self.searchQuestionsVC, self.userQuestionsVC, self.userProfileVC];
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

- (UIPanGestureRecognizer *)panRecognizer {
  if (!_panRecognizer) {
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topVCpanned:)];
  }
  return _panRecognizer;
}

- (UITapGestureRecognizer *)tapRecognizer {
  if (!_tapRecognizer) {
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topVCtapped:)];
  }
  return _tapRecognizer;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"vDL Burger Menu");
  
  self.mainMenuVC.tableView.delegate = self;
  [self addChildVC:self.mainMenuVC onScreen:YES];
  
  self.topVC = self.menuItemVCs.firstObject;
  [self addChildVC:self.topVC onScreen:YES];

  [self.burgerButton setImage:[UIImage imageNamed:@"burger"] forState:UIControlStateNormal];
  [self.topVC.view addSubview:self.burgerButton];
  [self.burgerButton addTarget:self action:@selector(burgerButtonUp:) forControlEvents:UIControlEventTouchUpInside];
  [self.topVC.view addGestureRecognizer:self.panRecognizer];
  
  [self.userProfileVC addObserver:self forKeyPath:kKVOuserProfileUrl options:NSKeyValueObservingOptionNew context:nil];
  
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  NSLog(@"vDA Burger Menu");
  
  [self authorizationToken];
}

- (void)dealloc {
  
  [self.userProfileVC removeObserver:self forKeyPath:kKVOuserProfileUrl];
}

#pragma mark - Helper Methods

- (void)addChildVC:(UIViewController *)childVC onScreen:(BOOL)onScreen {
  [self addChildViewController:childVC];
  childVC.view.frame = self.view.frame;
  if (!onScreen) {
    childVC.view.center = [self centerOfOffscreenVC:childVC];
  }
  [self.view addSubview:childVC.view];
  [childVC didMoveToParentViewController:self];
}
- (void)removeChildVC:(UIViewController *)childVC {
  [childVC willMoveToParentViewController:nil];
  [childVC.view removeFromSuperview];
  [childVC removeFromParentViewController];
}

- (void)openBurgerMenu {
  [UIView animateWithDuration:kOpenAnimationDuration animations:^{
    self.topVC.view.center = [self centerOfOpenVC:self.topVC];
  } completion:^(BOOL finished) {
    [self.topVC.view addGestureRecognizer:self.tapRecognizer];
    self.burgerButton.userInteractionEnabled = NO;
  } ];
}
-(void)closeBurgerMenu {
  [UIView animateWithDuration:kCloseAnimationDuration animations:^{
    self.topVC.view.center = self.view.center;
  } completion:^(BOOL finished) {
    [self.topVC.view removeGestureRecognizer:self.tapRecognizer];
    self.burgerButton.userInteractionEnabled = YES;
  }];
}

- (CGPoint)centerOfOpenVC:(UIViewController *)childVC {
  return CGPointMake(MAX(MIN(self.view.center.x, childVC.view.center.x), self.view.center.x +
                         childVC.view.frame.size.width * kBurgerMenuOpenPercent), childVC.view.center.y);
}
- (CGPoint)centerOfOffscreenVC:(UIViewController *)childVC {
  return CGPointMake(childVC.view.center.x + childVC.view.frame.size.width, childVC.view.center.y);
}

- (NSString *)authorizationToken {
  NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsTokenKey];
  if (token) {
    return token;
  }
  
  WebViewController *webVC = [[WebViewController alloc] init];
  [self presentViewController:webVC animated:YES completion:nil];
  
  return token = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsTokenKey];
}

#pragma mark - Selectors

- (void)burgerButtonUp:(UIButton *)sender {
  [self openBurgerMenu];
}

- (void)topVCpanned:(UIPanGestureRecognizer *)sender {
  
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
        [self openBurgerMenu];
      }
      break;
    default:
      break;
  }
}
- (void)topVCtapped:(UITapGestureRecognizer *)sender {
  [self closeBurgerMenu];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:kKVOuserProfileUrl]) {
    NSString *profileImageUrl = change[NSKeyValueChangeNewKey];
    NSLog(@"KVO change new: <%@>", profileImageUrl);
    
    dispatch_queue_t imageQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
    dispatch_async(imageQueue, ^{
      UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profileImageUrl]]];
      dispatch_async(dispatch_get_main_queue(), ^{
        self.userProfileVC.profileImage = image;
      });
    });
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self closeBurgerMenu];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  UIViewController *nextTopVC = self.menuItemVCs[indexPath.row];
  
  if (![self.topVC isEqual:nextTopVC]) {
    [UIView animateWithDuration:kOffscreenAnimationDuration animations:^{
      self.topVC.view.center = [self centerOfOffscreenVC:self.topVC];
    } completion:^(BOOL finished) {
      [self removeChildVC:self.topVC];
      [self.burgerButton removeFromSuperview];
      
      self.topVC = nextTopVC;
      [self addChildVC:self.topVC onScreen:NO];
      
      [UIView animateWithDuration:kOpenAnimationDuration animations:^{
        self.topVC.view.center = self.view.center;
      } completion:^(BOOL finished) {
        [self.topVC.view addGestureRecognizer:self.panRecognizer];
        [self.topVC.view addSubview:self.burgerButton];
      }];
    }];
  }
}
@end
