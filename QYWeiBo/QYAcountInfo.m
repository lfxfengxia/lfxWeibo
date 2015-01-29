//
//  QYAcountInfo.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/11.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYAcountInfo.h"
#import "Common.h"


@interface QYAcountInfo ()

@end

@implementation QYAcountInfo

+ (id)shareAcountInfo
{
    static QYAcountInfo *acountInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        acountInfo = [[self alloc]init];
    });
    return acountInfo;
}

- (instancetype)init
{
    if (self == [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.accessToken = [defaults objectForKey:kAccessToken];
        self.userID = [defaults objectForKey:kUserID];
        NSDate *date = [defaults objectForKey:kExpirseIn];
        if (self.accessToken && [[NSDate date] compare:date] == NSOrderedDescending) {
            [self deleteAcountInfo];
        }
    }
    return self;
}
- (void)saveAcountInfo:(NSDictionary *)info
{
    self.accessToken = info[kAccessToken];
    self.userID = info[kUserID];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.accessToken forKey:kAccessToken];
    [defaults setObject:self.userID forKey:kUserID];
    
    NSTimeInterval time = [info[kExpirseIn] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:time];
    [defaults setObject:date forKey:kExpirseIn];
    
}

- (void)deleteAcountInfo
{
    self.userID = nil;
    self.accessToken = nil;
    
    NSUserDefaults *defaultes = [NSUserDefaults standardUserDefaults];
    [defaultes setObject:nil forKey:kUserID];
    [defaultes setObject:nil forKey:kAccessToken];
    [defaultes setObject:nil forKey:kExpirseIn];
}

- (BOOL)isLogining
{
    return (self.accessToken != nil);
}

@end
