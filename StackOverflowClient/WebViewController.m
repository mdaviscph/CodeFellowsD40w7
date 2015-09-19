//
//  WebViewController.m
//  StackOverflowClient
//
//  Created by mike davis on 9/16/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

static NSString *const kURLpathWithToken = @"login_success";
static NSString *const kStackOverflowOAuthBaseURL = @"https://stackexchange.com/oauth/dialog";
static NSString *const kStackOverflowClientID = @"5579";
static NSString *const kStackOverflowRedirectURIschemeAndDomain = @"https://stackexchange.com";
static NSString *const kStackOverflowRedirectURIpath = @"/oauth/login_success";
static NSString *const kStackOverflowURLformat = @"%@?client_id=%@&redirect_uri=%@%@";

// TODO - use Keychain service instead of userdefaults
static NSString *const kUserDefaultsTokenKey = @"StackOverflowToken";

@interface WebViewController () <WKNavigationDelegate>

@end

@implementation WebViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"vDL Web View");

  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame];
  webView.navigationDelegate = self;
  [self.view addSubview:webView];
  
  NSString *finalURL = [NSString stringWithFormat:kStackOverflowURLformat, kStackOverflowOAuthBaseURL, kStackOverflowClientID, kStackOverflowRedirectURIschemeAndDomain, kStackOverflowRedirectURIpath];
  NSLog(@"<%@>", finalURL);
  [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalURL]]];
}

#pragma mark - WKNavigationDelegate

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  
  NSLog(@"[%@]",navigationAction.request.URL);
  NSLog(@"path: %@", navigationAction.request.URL.path);
  
  if ([navigationAction.request.URL.path isEqualToString:kStackOverflowRedirectURIpath]) {
    
    NSString *fragment = navigationAction.request.URL.fragment;
    
    NSArray *components = [fragment componentsSeparatedByString:@"&"];
    NSString *fullTokenParameter = components.firstObject;
    NSString *token = [fullTokenParameter componentsSeparatedByString:@"="].lastObject;
    NSLog(@"{%@}",token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kUserDefaultsTokenKey];
    [self dismissViewControllerAnimated:YES completion:nil];
  }
  decisionHandler(WKNavigationActionPolicyAllow);
}

@end
