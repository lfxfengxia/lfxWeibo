//
//  QYComment.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYComment.h"
#import "Common.h"
#import "Model.h"
#import "QYTweet.h"
#import "QYUser.h"

#define kStatus             @"status"
#define kReplyCommetn       @"reply_comment"

@implementation QYCommentData

- (instancetype)initCommentDataWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.tweet = [[QYTweet alloc]initTweetWithDictionary:dictionary[kStatus]];
        self.user = [[QYUser alloc]initUserWithDictionary:dictionary[kUser]];
        self.text = dictionary[kText];
        NSString *timeString = dictionary[kCreateAt];
        NSString *formatterStr = @"EEE MMM dd HH:mm:ss zzz yyyy";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:formatterStr];
        self.createAt = [dateFormatter dateFromString:timeString];
        NSString *sourceStr = dictionary[kSource];
        self.source = [[[QYTweetData alloc]init] getSourceFromString:sourceStr];
    }
    return self;
}

- (NSString *)agoTime
{
    return [[[QYTweetData alloc]init] formatWithDate:self.createAt];
}

@end

@implementation QYComment

- (instancetype) initCommentWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.sourComment = [[QYCommentData alloc]initCommentDataWithDictionary:dictionary];
        NSDictionary *replyCmt = dictionary[kReplyCommetn];
        if (replyCmt) {
            self.repalyComment = [[QYCommentData alloc]initCommentDataWithDictionary:replyCmt];
        }
    }
    return self;
}


@end
