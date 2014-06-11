//
//  StatusImageView.m
//  UberGenPass
//
//  Created by Mark Smith on 6/11/14.
//  Copyright (c) 2014 Camazotz Limited. All rights reserved.
//

#import "StatusImageView.h"

@implementation StatusImageView

#pragma mark Public

- (void)animate {
  CGRect frame = self.frame;
  
  [UIView animateWithDuration:0.4
                   animations:^{
                     self.frame = CGRectInset(self.frame, -12, -12);
                   }
                   completion:^(BOOL finished) {
                     [UIView animateWithDuration:0.6 animations:^{ self.frame = frame; }];
                   }];
}

@end
