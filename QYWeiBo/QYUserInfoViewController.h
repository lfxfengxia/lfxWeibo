//
//  QYUserInfoViewController.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/20.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYUserInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *attentionNum;
@property (weak, nonatomic) IBOutlet UILabel *followMeCount;
@property (weak, nonatomic) IBOutlet UILabel *gener;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *biFolowNum;
@property (weak, nonatomic) IBOutlet UILabel *descriptions;
@property (weak, nonatomic) IBOutlet UILabel *creatTime;

@end
