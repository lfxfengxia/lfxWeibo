//
//  QYComment.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QYUser,QYTweet;

@interface QYCommentData : NSObject
@property (nonatomic,strong) QYUser *user;
@property (nonatomic,strong) QYTweet *tweet;
@property (nonatomic,assign) NSInteger commentID;
@property (nonatomic,strong) NSDate *createAt;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSString *source;
@property (nonatomic,strong) NSString *agoTime;

- (instancetype)initCommentDataWithDictionary:(NSDictionary *)dictionary;

@end

@interface QYComment : NSObject
@property (nonatomic,strong) QYCommentData *sourComment;
@property (nonatomic,strong) QYCommentData *repalyComment;
@property (nonatomic,strong) QYTweet *tweet;

- (instancetype)initCommentWithDictionary:(NSDictionary *)dictionary;

@end
