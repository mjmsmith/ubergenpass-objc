//
//  PasswordGenerator.h
//  SuperGenPass
//
//  Created by Mark Smith on 10/23/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordGenerator : NSObject

+ (PasswordGenerator *)sharedGenerator;
+ (NSData *)md5:(NSString *)str;
+ (NSData *)sha256:(NSString *)str;

- (NSString *)passwordForURL:(NSString *)url length:(int)length;
- (NSString *)domainFromURL:(NSString *)urlStr;

- (void)updatePassword:(NSString *)password storesHash:(BOOL)storesHash;

@property (assign, readonly, nonatomic) BOOL hasPassword;
@property (assign, readonly, nonatomic) BOOL storesHash;

@property (copy, readonly, nonatomic) NSData *hash;

@end
