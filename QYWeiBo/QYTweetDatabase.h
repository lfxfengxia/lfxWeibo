//
//  QYSinaDatabase.h
//  QYWeiBo
//
//  Created by qingyun on 14/12/15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase,QYUser;

@interface QYTweetDatabase : NSObject
/**
 *  保存微博数据
 *
 *  @param tweets 微博请求的多组数据
 *
 *  @return 
 */
+ (void)saveTweetDataWithArray:(NSArray *)tweets;

/**
 *  插入用户信息
 *
 *  @param userInfo 传入的字典
 *  @param database 数据库
 */
+ (void)insertIntoTableUserWithDicitonary:(NSDictionary *)userInfo atDatabase:(FMDatabase *)database;

/**
 *  从本地数据库请求数据
 */
+ (NSArray *)selectTweetsFromLocal;

/**
 *  查询用户
 */
+ (QYUser *)selectUserIndoByID:(id)userID inDB:(FMDatabase *)db;
/**
 *  保存评论数据
 *
 *  @param comments 服务器请求的评论
 */
+ (void)saveCommentDataWithArray:(NSArray *)comments andTweetID:(id)tweetID;
/**
 *  本地请求评论数据
 */
+ (NSArray *)selectCommentsFromLocalByTweetID:(id)tweetID;

@end
