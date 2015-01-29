//
//  QYMentionCell.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/23.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QYTweet;

@interface QYMentionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIButton *icon;
@property (weak, nonatomic) IBOutlet UIButton *name;
@property (weak, nonatomic) IBOutlet UILabel *timeAndSource;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIImageView *tweetIcon;
@property (weak, nonatomic) IBOutlet UILabel *mentionName;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;


- (void)setCellDataWithMentionTweet:(QYTweet *)mention;

- (CGFloat)cellHeightWithMentionTweet:(QYTweet *)mention;

@end
