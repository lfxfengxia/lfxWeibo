//
//  QYWeiboInfoCell.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYCommentCell.h"
#import "QYComment.h"
#import "UIImageView+WebCache.h"
#import "QYUser.h"
#import "QYTweet.h"
#import "QYCountTextHeight.h"
#import "QYStringSize.h"

#define kWidth                  [UIScreen mainScreen].bounds.size.width

@implementation QYCommentCell

- (CGFloat)cellHeightWithComment:(QYComment *)comment
{
    CGFloat cellHeight = 59.f;
//    CGFloat cellHeight = 0.0;
//    self.content.text = comment.sourComment.text;
//    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    cellHeight += size.height;
    
    cellHeight += [QYCountTextHeight heightForText:comment.sourComment.text font:[UIFont systemFontOfSize:14] andTextWidth:0];
    //cellHeight += [QYStringSize calculateStringSizeWithString:comment.sourComment.text font:[UIFont systemFontOfSize:15] inSize:CGSizeMake(kWidth - 68, 1000)].height;//需将预估row高度设置
    return cellHeight;
}

- (void)cellDataWithComment:(QYComment *)comment
{
    QYUser *user = comment.sourComment.user;
    self.content.text = comment.sourComment.text;
    [self.name setTitle:user.name forState:UIControlStateNormal];
//    self.atittude
    NSString *agoTime = comment.sourComment.agoTime;
    NSString *source = comment.sourComment.source;
    self.timeAndSource.text = [NSString stringWithFormat:@"%@  来自%@",agoTime,source];
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView  sd_setImageWithURL:[NSURL URLWithString:user.avatarHd] placeholderImage:nil];
    [self.icon setImage:imageView.image forState:UIControlStateNormal];
}

@end
