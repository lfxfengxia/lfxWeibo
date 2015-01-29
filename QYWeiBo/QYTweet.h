//
//  QYTweet.h
//  QYWeiBo
//
//  Created by qingyun on 14/12/15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QYUser;

@interface QYTweetData : NSObject

@property (nonatomic,strong) NSDate *createAt;
@property (nonatomic,strong) NSString *tweetID;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSString *source;
@property (nonatomic,strong) QYUser *user;
@property (nonatomic) BOOL favorited;
@property (nonatomic) NSInteger repostsCount;
@property (nonatomic) NSInteger commentsCount;
@property (nonatomic) NSInteger attitudesCount;
@property (nonatomic,strong) NSArray *picURLs;

@property (nonatomic,strong) NSString *agoTime;

- (instancetype)initTweetDataWithdictionary:(NSDictionary *)tweetData;
- (NSString *)getSourceFromString:(NSString *)string;
- (NSString *) formatWithDate:(NSDate *)date;

@end

@interface QYTweet : NSObject

@property (nonatomic,strong)QYTweetData *tweetData;
@property (nonatomic,strong)QYTweetData *retweetData;

- (instancetype)initTweetWithDictionary:(NSDictionary *)tweetInfo;

@end
