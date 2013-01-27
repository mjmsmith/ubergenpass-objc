//
//  HelpViewController.m
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController () <UIWebViewDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UIWebView *webView;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, readwrite, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@end

@implementation HelpViewController

#pragma mark Lifecycle

- (void)dealloc {
  self.webView.delegate = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.backButton.enabled = self.webView.canGoBack;
  self.forwardButton.enabled = self.webView.canGoForward;
  
  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSBundle.mainBundle URLForResource:self.documentName withExtension:@"html"]]];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  self.backButton.enabled = self.webView.canGoBack;
  self.forwardButton.enabled = self.webView.canGoForward;
}

#pragma mark Actions

- (IBAction)done {
  [self.delegate helpViewControllerDidFinish:self];
}

- (IBAction)back {
  [self.webView goBack];
}

- (IBAction)forward {
  [self.webView goForward];
}

@end
