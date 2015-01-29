//
//  QYLoginViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/11.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYLoginViewController.h"
#import "QYLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYMainViewController.h"
#import "Common.h"
#import "QYAcountInfo.h"
#import "QYLoginUserInfo.h"
#import "MBProgressHUD.h"
#import "QYTweetDatabase.h"

@interface QYLoginViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation QYLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"QYLoginViewController" bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"userinfo_tabicon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //清除cookie
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in storage.cookies) {
        [storage deleteCookie:cookie];
    }
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@",kAppKey,kRedirectURI]];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    [self.webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self getLoginUserInfo];
}

#pragma mark - webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *requestStr = request.URL.absoluteString;
    if ([requestStr hasPrefix:kRedirectURI]) {
        NSRange range = [requestStr rangeOfString:@"code="];
        NSString *code = [requestStr substringFromIndex:range.location + range.length];
        NSString *requestUrlStr = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/access_token"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        NSDictionary *paramters = @{
                                    @"client_id":kAppKey,
                                    @"client_secret":kAppSecret,
                                    @"grant_type":@"authorization_code",
                                    @"redirect_uri":kRedirectURI,
                                    @"code":code
                                    };
        [manager POST:requestUrlStr parameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"response object======= : %@",responseObject);
           
            [[QYAcountInfo shareAcountInfo] saveAcountInfo:responseObject];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self getToHomeVc];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error : %@",error);
            [self cancel];
        }];
        //不显示回调页面
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - get login user information
- (void)getLoginUserInfo
{
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"users/show.json"];
    QYAcountInfo *accountInfo = [QYAcountInfo shareAcountInfo];
    if (accountInfo.accessToken == nil) {
        return;
    }
    NSDictionary *parameters = @{
                                 kAccessToken:accountInfo.accessToken,
                                 kUserID:accountInfo.userID
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"******************response object : %@",responseObject);
//        NSString *loginName = responseObject[kName];
//        NSString *loginIcon = responseObject[@"avatar_hd"];
//        NSString *descriptions = responseObject[kDescriptions];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:loginName forKey:kLoginUserName];
//        [defaults setObject:loginIcon forKey:kLoginIcon];
//        [defaults setObject:descriptions forKey:kDescriptions];
        
        [QYLoginUserInfo saveUserInfo2FileWithDictionary:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@",error);
    }];
}

#pragma mark -  action
- (void)cancel
{   QYMainViewController *mainVC = [[QYMainViewController alloc]init];
    [self presentViewController:mainVC animated:YES completion:^{
        mainVC.selectedIndex = 3;
    }];
}

- (void)getToHomeVc
{   QYMainViewController *mainVC = [[QYMainViewController alloc]init];
    [self presentViewController:mainVC animated:YES completion:^{
        mainVC.selectedIndex = 0;
    }];
}

@end
