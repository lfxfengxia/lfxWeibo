//
//  QYLoginUserInfo.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/26.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QYUser;

@interface QYLoginUserInfo : NSObject

@property (nonatomic,strong) QYUser *user;

+ (instancetype)defaultLoginUser;

+ (void)saveUserInfo2FileWithDictionary:(NSDictionary *)dic;

- (QYUser *)getUserInfo;
- (void)deleteUserInfo;
//+ (instancetype)initWithDictionary:(NSDictionary *)userInfo;

@end
