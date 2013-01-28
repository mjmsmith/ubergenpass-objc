//
//  PasswordGenerator.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

@interface PasswordGenerator : NSObject
@property (assign, readonly, nonatomic) BOOL savesHash;
@property (assign, readonly, nonatomic) BOOL hasMasterPassword;
@property (copy, readonly, nonatomic) NSData *hash;

+ (PasswordGenerator *)sharedGenerator;
+ (NSData *)md5:(NSString *)str;
+ (NSData *)sha256:(NSString *)str;

- (NSString *)passwordForURL:(NSString *)url length:(int)length;
- (NSString *)domainFromURL:(NSString *)urlStr;

- (void)updateMasterPassword:(NSString *)masterPassword;

- (BOOL)textMatchesHash:(NSString *)text;
@end
