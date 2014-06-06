//
//  PasswordGenerator.h
//  UberGenPass
//
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

@interface PasswordGenerator : NSObject
@property (assign, readonly, nonatomic) BOOL hasMasterPassword;
@property (copy, readonly, nonatomic) NSData *hash;

+ (PasswordGenerator *)sharedGenerator;

- (NSString *)passwordForSite:(NSString *)site length:(NSUInteger)length;
- (NSString *)domainFromSite:(NSString *)site;

- (void)updateMasterPassword:(NSString *)masterPassword;

- (BOOL)textMatchesHash:(NSString *)text;
@end
