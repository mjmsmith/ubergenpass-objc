//
//  AboutViewController.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//


#import "AboutViewController.h"
#import "FUIButton.h"

#define AppStoreReviewsURL @"http://camazotz.com/ubergenpass/review"

@interface AboutViewController () <UIWebViewDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, readwrite, nonatomic) IBOutlet FUIButton *rateButton;
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
  
  self.rateButton.buttonColor = [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1];
  self.rateButton.cornerRadius = 6.0f;

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
