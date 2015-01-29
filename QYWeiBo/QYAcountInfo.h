//
//  QYAcountInfo.h
//  QYWeiBo
//
//  Created by qingyun on 14/12/11.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYAcountInfo : NSObject

@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *expiresIn;


/**
 *  单例
 */
+ (id)shareAcountInfo;

/**
 *  保存用户信息
 */
- (void)saveAcountInfo:(NSDictionary *)info;

/**
 *  删除用户信息
 */
- (void)deleteAcountInfo;

/**
 *  返回用户的登录状态
 */
- (BOOL)isLogining;
@end
