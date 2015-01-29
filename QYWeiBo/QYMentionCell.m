//
//  QYMentionCell.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/23.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYMentionCell.h"
#import "QYTweet.h"
#import "QYUser.h"
#import "Common.h"
#import "UIImageView+WebCache.h"

@implementation QYMentionCell

- (void)setCellDataWithMentionTweet:(QYTweet *)mention
{
    self.text.text = mention.tweetData.text;
    UIImageView *imageView = [[UIImageView alloc]init];
    QYUser *user = mention.tweetData.user;
    [self.name setTitle:user.name forState:UIControlStateNormal];
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.avatarHd]];
    [self.icon setImage:imageView.image forState:UIControlStateNormal];
    NSString *agoTime = mention.tweetData.agoTime;
    NSString *source = mention.tweetData.source;
    self.timeAndSource.text = [NSString stringWithFormat:@"%@   来自%@",agoTime,source];
    if (mention.retweetData) {
        self.tweetText.text = mention.retweetData.text;
        QYUser *reUser = mention.retweetData.user;
        if (mention.tweetData.picURLs.count == 0) {
            [self.tweetIcon sd_setImageWithURL:[NSURL URLWithString:reUser.avatarHd]];
        }else{
            [self.tweetIcon sd_setImageWithURL:[NSURL URLWithString:mention.tweetData.picURLs.firstObject]];
        }
        self.mentionName.text = [NSString stringWithFormat:@"@%@",[[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserName]];
    }else{
        self.mentionName.text = nil;
    }
}

- (CGFloat)cellHeightWithMentionTweet:(QYTweet *)mention
{
    self.text.text = mention.tweetData.text;
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    if (mention.retweetData.text.length == 0 && self.showView) {
//        [self.showView removeFromSuperview];
//        return size.height + 1 - 88;
//    }else{
//        [self.contentView addSubview:self.showView];
//        [self.showView addSubview:self.mentionName];
//        [self.showView addSubview:self.tweetText];
//        [self.showView addSubview:self.tweetIcon];
//        return size.height + 1;
//    }
    return size.height + 1;
}

//- (void)layoutTweetInfo
//{
//    self.tweetIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
//    self.mentionName = [[UILabel alloc]initWithFrame:CGRectMake(88, 8, 224, 18)];
//    self.mentionName.font = [UIFont systemFontOfSize:15];
//    self.tweetText = [[UILabel alloc]initWithFrame:CGRectMake(88, 30, 224, 50)];
//    self.tweetText.font = [UIFont systemFontOfSize:13];
//    self.tweetText.numberOfLines =  2;
//    self.tweetText.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.showView addSubview:self.tweetIcon];
//    [self.showView addSubview:self.mentionName];
//    [self.showView addSubview:self.tweetText];
//}

@end
