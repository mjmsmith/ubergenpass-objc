//
//  PasswordGenerator.h
//  UberGenPass
//
//  Created by Mark Smith on 10/23/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

@interface PasswordGenerator : NSObject

+ (PasswordGenerator *)sharedGenerator;
+ (NSData *)md5:(NSString *)str;
+ (NSData *)sha256:(NSString *)str;

- (NSString *)passwordForURL:(NSString *)url length:(int)length;
- (NSString *)domainFromURL:(NSString *)urlStr;

- (void)updateMasterPassword:(NSString *)masterPassword;

@property (assign, readonly, nonatomic) BOOL hasMasterPassword;
@property (copy, readonly, nonatomic) NSData *hash;

@end
