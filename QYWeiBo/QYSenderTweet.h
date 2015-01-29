//
//  QYSenderWordTweet.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/29.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    kComment,
    kRepost,
    kWrite
}sendType;

@class QYTweet;

@interface QYSenderTweet : UITableViewController

@property (nonatomic,strong) NSMutableArray *uploadImages;
@property (nonatomic)sendType sendType;
@property (nonatomic,strong) QYTweet *tweet;

@end
