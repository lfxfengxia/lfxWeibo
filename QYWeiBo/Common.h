//
//  Common.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#ifndef QYWeiBo_Common_h
#define QYWeiBo_Common_h

#define kWidth                   [UIScreen mainScreen].bounds.size.width
#define kHeight                  [UIScreen mainScreen].bounds.size.height

/**
 *  UserDefaults Key
 */
#define kNotFirstLaunch     @"kNotFirstLaunch"
#define kExpirseIn          @"expires_in"
#define kLastSelectedIndex  @"lastSelectedIndex"
#define kLoginUserName      @"loginUserName"
#define kLoginIcon          @"avatar_hd"
#define kDescriptions       @"description"

/**
 *  dictionary key
 */
#define kCount              @"count"

/**
 * App Key
 */
#define kAppKey             @"3557104683"
#define kAppSecret          @"a7a611909a2896243681d7237dc7ffc3"
#define kRedirectURI        @"https://api.weibo.com/oauth2/default.html"

/**
 *  userInfo  Key
 */
#define kAccessToken        @"access_token"
#define kUserID             @"uid"
#define kName               @"name"

/**
 *  Notification Key
 */
#define kLogout             @"logout"
#define kReturnMain         @"returnMain"

/**
 *  URL key
 */
#define kBaseURL            @"https://api.weibo.com/2"

#endif
