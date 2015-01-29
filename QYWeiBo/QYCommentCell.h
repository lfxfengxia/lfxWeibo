//
//  QYWeiboInfoCell.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYComment;

@interface QYCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *icon;
@property (weak, nonatomic) IBOutlet UIButton *name;
@property (weak, nonatomic) IBOutlet UIButton *atittude;
@property (weak, nonatomic) IBOutlet UILabel *timeAndSource;
@property (weak, nonatomic) IBOutlet UILabel *content;

- (CGFloat) cellHeightWithComment:(QYComment *)comment;
- (void) cellDataWithComment:(QYComment *)comment;

@end
