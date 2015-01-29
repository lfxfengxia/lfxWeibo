//
//  QYTableViewCell.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/12.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYWeiboCell.h"
#import "QYCountTextHeight.h"
#import "UIImageView+WebCache.h"
#import "QYTweet.h"
#import "QYUser.h"
#import "QYStringSize.h"



#define kUser           @"user"
#define kIcon           @"avatar_hd"
#define kName           @"name"
#define kTime           @"created_at"
#define kSource         @"source"
#define kText           @"text"
#define kTrans          @"retweeted_status"
#define kImage          @"thumbnail_pic"
#define kImages         @"pic_urls"

#define kWidth          [UIScreen mainScreen].bounds.size.width - 16

static NSInteger imageX = 90;
static NSInteger imageY = 90;
static NSInteger imageMargin = 5;

@implementation QYWeiboCell

//方法一
/*
//- (CGFloat)heightForCellWithTweet:(QYTweet *)tweet
//{
//    CGFloat cellHeight = 66.f;
//    self.selfContent.text = tweet.tweetData.text;
//    cellHeight += [QYCountTextHeight heightForText:self.selfContent.text font:[UIFont systemFontOfSize:15] andTextWidth:0];
//    cellHeight += 8;
//    NSArray *selfImages = tweet.tweetData.picURLs;
//    cellHeight += [self heightForImages:selfImages];
//    cellHeight += 8;
//    QYTweetData *transText = tweet.retweetData;
//    cellHeight += [QYCountTextHeight heightForText:self.transContent.text font:[UIFont systemFontOfSize:14] andTextWidth:0];
//    cellHeight += 8;
//    NSArray *transImages = transText.picURLs;
//    cellHeight += [self heightForImages:transImages];
//    return cellHeight + 1;
//}
*/

//方法二
#pragma mark - calculate cell height
- (CGFloat)heightForCellWithTweet:(QYTweet *)tweet
{
    CGFloat cellHeight = 66.f;
    NSString *content = tweet.tweetData.text;
    cellHeight += [QYStringSize calculateStringSizeWithString:content font:[UIFont systemFontOfSize:15] inSize:CGSizeMake(kWidth, 1000)].height;
    cellHeight += 8;
    
    NSArray *selfImages = tweet.tweetData.picURLs;
    cellHeight += [self heightForImages:selfImages];
    cellHeight += 8;
    
    QYTweetData *retweetData = tweet.retweetData;
    NSString *transContent = retweetData.text;
    cellHeight += [QYStringSize calculateStringSizeWithString:transContent font:[UIFont systemFontOfSize:14] inSize:CGSizeMake(kWidth, 1000)].height;
    cellHeight += 8;
    NSArray *transImages = retweetData.picURLs;
    cellHeight += [self heightForImages:transImages];
    return cellHeight;
}

//方法三
/*
//- (CGFloat)heightForCellWithTweet:(QYTweet *)tweet
//{
//    NSLog(@"initalize :============= %.f",self.contentView.frame.size.height);
//    CGFloat cellHeight = 0.f;
//    self.selfContent.text = tweet.tweetData.text;
//    NSArray *selfImages = tweet.tweetData.picURLs;
//    cellHeight += [self heightForImages:selfImages];
//    
//    QYTweetData *transInfo = tweet.retweetData;
//    self.transContent.text = transInfo.text;
//    
//    cellHeight += [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    
//    NSArray *transImages = transInfo.picURLs;
//    cellHeight += [self heightForImages:transImages];
//    NSLog(@"addtional height :*********** %.f",cellHeight);
//    //return cellHeight + self.contentView.frame.size.height;
//    return cellHeight;
//}
*/
#pragma mark get cell data
- (void)cellWithTweet:(QYTweet *)tweet
{
    QYUser *userInfo = tweet.tweetData.user;
    self.attentionBtn.highlighted = tweet.tweetData.favorited;
    //user name
    [self.userName setTitle:userInfo.name forState:UIControlStateNormal];
    //user icon
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarHd]];
    [self.iconBtn setImage:imageView.image forState:UIControlStateNormal];
    //data source and time
    NSString *sourceStr = tweet.tweetData.source;
    NSString *dateStr = tweet.tweetData.agoTime;
    self.timeAndSurLabel.text = [NSString stringWithFormat:@"%@    来自%@",dateStr,sourceStr];
    //self text and images
    self.selfContent.text = tweet.tweetData.text;
    NSArray *selfImages = tweet.tweetData.picURLs;
    [self addImagesWith:selfImages toView:self.selfImage];
    //trans text and images
    QYTweetData *transInfo = tweet.retweetData;
    self.transContent.text = transInfo.text;
    NSArray *images = transInfo.picURLs;
    [self addImagesWith:images toView:self.transImage];
}

#pragma mark - add image
- (void)addImagesWith:(NSArray *)images toView:(UIView *)view
{
    NSArray *preImages = view.subviews;
    for (UIView *subview in preImages) {
        [subview removeFromSuperview];
    }
    NSInteger columns = 3;
    NSInteger rows = ceil(images.count / 3.0);
    if (images.count == 4) {
        columns = 2;
    }
    NSInteger imageHeight = rows * imageY + (rows - 1) * imageMargin;
    if (images.count == 0) {
        imageHeight = 0;
    }
    for (NSLayoutConstraint *constraint in view.constraints) {
        if(constraint.firstAttribute == NSLayoutAttributeHeight){
            constraint.constant = imageHeight;
        }
    }
    //CGFloat beginX = (kWidth - rows * imageX - (rows - 1) * imageMargin)/2;
    for (int i = 0; i < images.count; i ++) {
        NSString *imageUrl = images[i];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(4 + i % columns * (imageX + imageMargin), i/columns * (imageY + imageMargin), imageX, imageY)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        [view addSubview:imageView];
    }
}

#pragma mark - calculate imageView height
- (CGFloat)heightForImages:(NSArray *)images
{
    NSInteger height = 0;
    NSInteger columns = 3;
    NSInteger rows = ceil(images.count / (CGFloat)columns);
    if (images.count != 0) {
        height = rows * imageY + (rows - 1) * imageMargin;
    }
    return height;
}
@end
