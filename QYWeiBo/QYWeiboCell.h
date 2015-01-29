//
//  QYTableViewCell.h
//  QYWeiBo
//
//  Created by qingyun on 14/12/12.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QYTweet;

@interface QYWeiboCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UIButton *userName;
@property (weak, nonatomic) IBOutlet UILabel *timeAndSurLabel;
@property (weak, nonatomic) IBOutlet UILabel *selfContent;
@property (weak, nonatomic) IBOutlet UIView *selfImage;
@property (weak, nonatomic) IBOutlet UILabel *transContent;
@property (weak, nonatomic) IBOutlet UIView *transImage;

/**
 *  set cell height
 */
- (CGFloat)heightForCellWithTweet:(QYTweet *)tweet;

/**
 *  set property value
 */
- (void)cellWithTweet:(QYTweet *)tweet;

/**
 *  set contentView constraints
 */
//- (void)setConstraints;

@end
