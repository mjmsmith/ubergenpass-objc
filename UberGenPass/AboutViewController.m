//
//  AboutViewController.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//


#import "AboutViewController.h"
#import "GradientButton.h"

#define AppStoreReviewsURL @"http://camazotz.com/ubergenpass/review"

@interface AboutViewController () <UIWebViewDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, readwrite, nonatomic) IBOutlet GradientButton *rateButton;
@property (strong, readwrite, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)done;
- (IBAction)rate;
@end

@implementation AboutViewController

#pragma mark Lifecycle

- (void)dealloc {
  self.webView.delegate = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                         [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
  
  [self.rateButton useAlertStyle];

  self.webView.scrollView.bounces = NO;
  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSBundle.mainBundle URLForResource:@"About" withExtension:@"html"]]];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type {
  if (type == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
  }
  
  return YES;
}

#pragma mark Actions

- (IBAction)done {
  [self.delegate aboutViewControllerDidFinish:self];
}

- (IBAction)rate {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStoreReviewsURL]];
}

@end
