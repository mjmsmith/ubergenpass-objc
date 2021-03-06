//
//  AboutViewController.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//


#import "AboutViewController.h"
#import "FUIButton.h"

@interface AboutViewController () <UIWebViewDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, readwrite, nonatomic) IBOutlet FUIButton *rateButton;
@property (strong, readwrite, nonatomic) IBOutlet UIWebView *webView;
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
  
  self.rateButton.buttonColor = FUIButton.defaultButtonColor;
  self.rateButton.cornerRadius = 6.0f;

  self.webView.scrollView.bounces = NO;
  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSBundle.mainBundle URLForResource:@"About" withExtension:@"html"]]];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type {
  if (type == UIWebViewNavigationTypeLinkClicked && [[request.URL absoluteString] hasPrefix:@"http"]) {
    [UIApplication.sharedApplication openURL:request.URL];
    return NO;
  }
  
  return YES;
}

#pragma mark Actions

- (IBAction)done {
  [self.delegate aboutViewControllerDidFinish:self];
}

- (IBAction)rate {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appstore.com/ubergenpass"]];
}

@end
