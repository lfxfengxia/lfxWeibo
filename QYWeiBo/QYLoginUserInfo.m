//
//  QYLoginUserInfo.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/26.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYLoginUserInfo.h"
#import "QYUser.h"
#import "Model.h"
#import "FMDB.h"
#import "QYTweetDatabase.h"
#import "QYAcountInfo.h"

#define kfilePath               @"loginUserInfo.db"

static QYLoginUserInfo *loginUser;

@implementation QYLoginUserInfo

+ (instancetype)defaultLoginUser
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        loginUser = [[QYLoginUserInfo alloc]init];
    });
    return loginUser;
}

+ (NSString *)filePath
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *userPath = [docPath stringByAppendingPathComponent:kfilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:kfilePath ofType:nil];
    if (![fileManager fileExistsAtPath:userPath]) {
        [fileManager copyItemAtPath:tempPath toPath:userPath error:nil];
    }
    return userPath;
}

+ (void)saveUserInfo2FileWithDictionary:(NSDictionary *)userInfo
{
    NSString *userFile = [QYLoginUserInfo filePath];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:userFile];
    [queue inDatabase:^(FMDatabase *db) {
       [QYTweetDatabase insertIntoTableUserWithDicitonary:userInfo atDatabase:db]; 
    }];
}

- (QYUser *)getUserInfo
{
    NSString *userFile = [QYLoginUserInfo filePath];
    FMDatabase *db = [FMDatabase databaseWithPath:userFile];
    //NSString *userID = [[QYAcountInfo shareAcountInfo] userID];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    [db open];
    loginUser.user = [QYTweetDatabase selectUserIndoByID:userID inDB:db];
    [db close];
    return loginUser.user;
}

- (void)deleteUserInfo
{
    loginUser.user = nil;
}
@end
