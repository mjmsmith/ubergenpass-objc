//
//  MainViewController.h
//  UberGenPass
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "HelpViewController.h"
#import "SettingsViewController.h"

@interface MainViewController : UIViewController <HelpViewControllerDelegate, SettingsViewControllerDelegate>

@property (copy, readwrite, nonatomic) NSString *url;

@end
