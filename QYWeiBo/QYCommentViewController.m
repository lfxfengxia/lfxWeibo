//
//  QYCommentViewController.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/25.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYCommentViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYAcountInfo.h"
#import "QYLoginUserInfo.h"
#import "QYUser.h"
#import "Common.h"

@interface QYCommentViewController ()

@property (nonatomic,strong) NSUserDefaults *defaults;
@property (nonatomic,strong) QYAcountInfo *accountInfo;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation QYCommentViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)loadView
{
    self.view = [[NSBundle mainBundle] loadNibNamed:@"QYCommentViewController" owner:self options:nil][0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.accountInfo = [QYAcountInfo shareAcountInfo];
    self.textView.clearsOnInsertion = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupLabel];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(comment)];
}

#pragma mark - navigation item action
- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)comment
{
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"comments/create.json"];
    NSDictionary *paramters = @{
                                kAccessToken:self.accountInfo.accessToken,
                                @"id":@(self.tweetID),
                                @"comment":self.textView.text,
                                @"comment_ori":@1
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlStr parameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object : %@",responseObject);
        [self commentPromptWithText:@"发送成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@,responseString :%@",error,operation.responseString);
        [self commentPromptWithText:@"发送失败"];
    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - add subviews 
- (void)setupLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 100, 40)];
    QYLoginUserInfo *loginUser = [QYLoginUserInfo defaultLoginUser];
    NSString *name = [[loginUser getUserInfo] name];
    label.text = [NSString stringWithFormat:@"发表评论\r%@",name];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
}

- (void)commentPromptWithText:(NSString *)text
{
    UILabel *prompt = [[UILabel alloc]initWithFrame:CGRectMake(110, 150, 100, 40)];
    prompt.text = @"发送中。。。";
    prompt.textColor = [UIColor whiteColor];
    prompt.backgroundColor = [UIColor blackColor];
    prompt.layer.cornerRadius = 10;
    prompt.layer.masksToBounds = YES;
    prompt.alpha = 0;
    [self.view addSubview:prompt];
    [UIView animateWithDuration:1.0 animations:^{
        prompt.alpha = 0.6;
    } completion:^(BOOL finished) {
        prompt.text = text;
        [UIView animateWithDuration:2.0 animations:^{
            prompt.alpha = 0;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } completion:^(BOOL finished) {
            [prompt removeFromSuperview];
            if([text isEqualToString:@"发送成功"])
            {
                [self cancel];
            }
        }];
    }];
}

@end
