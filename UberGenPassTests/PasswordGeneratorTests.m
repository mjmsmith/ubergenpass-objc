//
//  UberGenPassTests.m
//  UberGenPassTests
//
//  Created by Mark Smith on 11/27/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import "PasswordGenerator.h"
#import "PasswordGeneratorTests.h"

@interface UberGenPassTests ()
@property (strong, readwrite, nonatomic) PasswordGenerator *generator;
@end

@implementation UberGenPassTests

- (void)setUp {
  self.generator = [[PasswordGenerator alloc] init];
  [self.generator updatePassword:@"t0pS3cr3t"];
}

- (void)tearDown {
  self.generator = nil;
}

- (void)testURLs {
  NSArray *urls = @[
    @"http://example.com",
    @"http://example.com/foo",
    @"http://example.com?foo",

    @"http://www.example.com",
    @"http://www.example.com/foo",
    @"http://www.example.com?foo",
  ];

  for (NSString *url in urls) {
    STAssertEqualObjects([self.generator passwordForURL:url length:10], @"sTX7smlm3O", url);
  }
}

- (void)testDomains {
  STAssertEqualObjects([self.generator passwordForURL:@"example.com" length:10], @"sTX7smlm3O", nil);
  STAssertEqualObjects([self.generator passwordForURL:@"example.com/foo" length:10], @"sTX7smlm3O", nil);
  
  STAssertEqualObjects([self.generator passwordForURL:@"www.example.com" length:10], @"u8zU8AndAo", nil);
  STAssertEqualObjects([self.generator passwordForURL:@"www.example.com/foo" length:10], @"u8zU8AndAo", nil);
}

- (void)testTLDs {
  STAssertEqualObjects([self.generator passwordForURL:@"example.co.uk" length:10], @"dyqtqDL83O", nil);
  STAssertEqualObjects([self.generator passwordForURL:@"example.com.au" length:10], @"m1DnmJ4c4Q", nil);
  
}

- (void)testLengths {
  for (int i = 4; i < 24; ++i) {
    STAssertEqualObjects([self.generator passwordForURL:@"http://example.com" length:i],
                         [@"sTX7smlm3OiNOKgHC3gjpQAA" substringToIndex:i],
                         [[NSNumber numberWithInt:i] stringValue]);
  }
}

- (void)testGarbage {
  NSArray *urls = @[
    @"",
    @"...",
    @"http:",
    @"x",
  ];

  for (NSString *url in urls) {
    STAssertNil([self.generator passwordForURL:url length:10], url);
  }
}

@end
