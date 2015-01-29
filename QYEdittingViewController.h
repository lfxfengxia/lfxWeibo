//
//  QYEdittingViewController.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/25.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYEdittingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *text;

@property (nonatomic) NSInteger tweetID;

@end
