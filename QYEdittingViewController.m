//
//  QYEdittingViewController.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/25.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYEdittingViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Common.h"
#import "QYAcountInfo.h"
#import "QYLoginUserInfo.h"
#import "QYUser.h"

@interface QYEdittingViewController ()
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) QYAcountInfo *accountInfo;
@property (nonatomic,strong) NSUserDefaults *defaults;
@end

@implementation QYEdittingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.clearsOnInsertion = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.accountInfo = [QYAcountInfo shareAcountInfo];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.title = @"转发微博";
    [self setupLabel];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(repost:)];
}

#pragma mark - add subviews
- (void)setupLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(110, 20, 2, 40)];
    QYLoginUserInfo *loginUser = [QYLoginUserInfo defaultLoginUser];
    NSString *name = [[loginUser getUserInfo] name];
    label.text = [NSString stringWithFormat:@"转发微博\r%@",name];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    self.navigationItem.titleView = label;
}

#pragma mark - barButton Item action
- (void)cancel:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)repost:(UIBarButtonItem *)sender
{
    if (![self.accountInfo isLogining]) {
        return;
    }
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/repost.json"];
    NSDictionary *paramters = @{
                                kAccessToken:self.accountInfo.accessToken,
                                @"id":@(self.tweetID),
                                @"status":self.textView.text,
                                @"is_comment":@1
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlStr parameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"response object : %@",responseObject);
        [self altertAfterRepost:@"转发成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@",error);
        [self altertAfterRepost:@"转发失败"];
    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - action
- (void)altertAfterRepost:(NSString *)text
{
    [UIView animateWithDuration:2.0 animations:^{
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(110, 260, 100, 40)];
        self.label.text = text;
        self.label.backgroundColor = [UIColor blackColor];
        self.label.alpha = 0.7;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.textColor = [UIColor whiteColor];
        self.label.layer.cornerRadius = 10;
        self.label.layer.masksToBounds = YES;
        [self.view addSubview:self.label];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.label.alpha = 0;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } completion:^(BOOL finished) {
            [self.label removeFromSuperview];
            if([text isEqualToString:@"转发成功"])
            {
                [self cancel:nil];
            }

        }];
    }];
}

@end
