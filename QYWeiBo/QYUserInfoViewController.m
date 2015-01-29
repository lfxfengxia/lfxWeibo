//
//  QYUserInfoViewController.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/20.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYUserInfoViewController.h"

@interface QYUserInfoViewController ()


@end

@implementation QYUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"userBackGround.jpg"]];
    self.icon.layer.cornerRadius = 35;
    self.icon.layer.masksToBounds = YES;
}

#pragma mark - action
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
