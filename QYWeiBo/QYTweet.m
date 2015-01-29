//
//  QYTweet.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTweet.h"
#import "QYUser.h"
#import "Model.h"


@implementation QYTweetData

- (instancetype)initTweetDataWithdictionary:(NSDictionary *)tweetData
{
    self = [super init];
    if (self) {
        self.user = [[QYUser alloc]initUserWithDictionary:tweetData[kUser]];
        
        NSString *dateStr = tweetData[kCreatedAt];
        NSString *formatterStr = @"EEE MMM dd HH:mm:ss zzz yyyy";
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:formatterStr];
        self.createAt = [formatter dateFromString:dateStr];

        self.tweetID = tweetData[kID];
        self.text = tweetData[kText];
        
        NSString *sourStr = tweetData[kSource];
        self.source = [self getSourceFromString:sourStr];
        
        self.favorited = [tweetData[kFavorited] boolValue];
        self.repostsCount = [tweetData[kRepostsCount] integerValue];
        self.commentsCount = [tweetData[kCommentsCount] integerValue];
        self.attitudesCount = [tweetData[kAttitudesCount] integerValue];
        NSArray *images = tweetData[kPicURLs];
        if (images.count) {
            NSMutableArray *imageUrls = [NSMutableArray array];
            for (NSDictionary *dic in images) {
                [imageUrls addObjectsFromArray:dic.allValues];
            }
            self.picURLs = imageUrls;
        }
    }
    
    return self;
}

- (NSString *)agoTime
{
    return [self formatWithDate:self.createAt];
}

#pragma mark - get data source
- (NSString *)getSourceFromString:(NSString *)string
{
    if([string isEqual:@""] || [string isKindOfClass:[NSNull class] ] || string == nil){
        return @"未注册设备";
    }
    NSString *source;
    NSString *regexStr = @">.*<";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:nil];
    NSRange sourceRange = [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length - 1)];
    source = [string substringWithRange:NSMakeRange(sourceRange.location + 1, sourceRange.length - 2)];
    if ([source isEqual:@""]) {
        return @"未注册设备";
    }
    return source;
}
#pragma mark - date formatter
- (NSString *) formatWithDate:(NSDate *)date
{
    NSString *agoTime;
    //NSTimeInterval time = [[[NSDate alloc]init] timeIntervalSinceDate:date];
    NSTimeInterval time = -[date timeIntervalSinceNow];
    if (time < 60) {
        agoTime = @"刚刚";
    }else if(time > 60 && time < 3600){
        agoTime = [NSString stringWithFormat:@"%.f分钟之前",time/60];
    }else if(time >3600 && time < 3600 * 24){
        agoTime = [NSString stringWithFormat:@"%.f小时之前",time/3600];
    }else{
        NSString *formatterStr = @"MMM-dd HH:mm";
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = formatterStr;
        agoTime = [formatter stringFromDate:date];
    }
    return agoTime;
}

- (NSString *)formatWithDateString:(NSString *)dateString
{
    NSString *agoTime;
    NSString *formatt = @"EEE MMM dd HH:mm:ss zzz";
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:formatt];
    NSDate * date = [dateformatter dateFromString:dateString];
    NSTimeInterval time = [[[NSDate alloc]init] timeIntervalSinceDate:date];
    if (time < 60) {
        agoTime = @"刚刚";
    }else if(time > 60 && time < 3600){
        agoTime = [NSString stringWithFormat:@"%.f分钟之前",time/60];
    }else if(time >3600 && time < 3600 * 24){
        agoTime = [NSString stringWithFormat:@"%.f小时之前",time/3600];
    }else{
        NSString *formatterStr = @"MMM-dd HH:mm";
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSDate *date = [formatter dateFromString:formatterStr];
        agoTime = [formatter stringFromDate:date];
    }
    return agoTime;
}


@end

@implementation QYTweet

- (instancetype)initTweetWithDictionary:(NSDictionary *)tweetInfo
{
    if (self == [super init]) {
        self.tweetData = [[QYTweetData alloc]initTweetDataWithdictionary:tweetInfo];
        if (tweetInfo[kRetweetStatus]) {
            self.retweetData = [[QYTweetData alloc]initTweetDataWithdictionary:tweetInfo[kRetweetStatus]];
        }
    }
    return self;
}


@end
