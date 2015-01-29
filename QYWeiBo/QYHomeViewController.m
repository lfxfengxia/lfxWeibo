//
//  QYHomeViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYHomeViewController.h"
#import "QYWeiboCell.h"
#import "Common.h"
#import "QYAcountInfo.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYFooterView.h"
#import "MBProgressHUD.h"
#import "QYTweetDatabase.h"
#import "QYTweet.h"
#import "QYUser.h"
#import "QYUserInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "QYTweetInfo.h"
#import "QYQRCodeViewController.h"
#import "TSActionSheet.h"
#import "TSPopoverController.h"
#import "QYHomeTitleVC.h"
#import "QYEdittingViewController.h"
#import "QYCommentViewController.h"
#import "QYUserInfoTableViewController.h"
#import "QYLoginUserInfo.h"
#import "QYLoginViewController.h"

#define kQYWeiboCell        @"QYWeiboCell"
#define kFooterView             @"QYFooterView"

#define kStatuses               @"statuses"
#define kCount                  @"count"
#define kStatus                 @"status"
#define kID                     @"id"
#define kIsComment              @"is_comment"
#define kComment                @"comment"

@interface QYHomeViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *weiboData;
@property (nonatomic,strong) QYAcountInfo *accountInfo;
@property (nonatomic)BOOL isRefreshing;
@property (nonatomic,strong) NSDictionary *provinces;
@property (nonatomic,strong) UIImageView *boundsImgView;

@end

@implementation QYHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"首页";
        self.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"主页" image:[UIImage imageNamed:@"tabbar_home"] selectedImage:[UIImage imageNamed:@"tabbar_home_selected"]];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.isHiden = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@0 forKey:kLastSelectedIndex];
    
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar_pop"] style:UIBarButtonItemStylePlain target:self action:@selector(scanHandleNavigationItem:withEvent:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar_friendsearch"] style:UIBarButtonItemStyleDone target:self action:@selector(addAttention)];
    if (![self.accountInfo isLogining]) {
//        self.navigationItem.leftBarButtonItem.enabled = NO;
//        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountInfo = [QYAcountInfo shareAcountInfo];
    if (![self.accountInfo isLogining]) {
        [self setupNotLoginImage];
        [self setButton];
        [NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(startImageAnimating) userInfo:nil repeats:YES];
        self.navigationItem.leftBarButtonItem.customView.alpha = 0.0;
        [self setupButtonWithTitle:@"微博" enable:NO];
        return;
    }
    [self removeImage];
    NSString *title = [[[QYLoginUserInfo defaultLoginUser] getUserInfo] name];
    [self setupButtonWithTitle:title enable:YES];
    //从本地加载数据并排序
    NSArray *tweets = [QYTweetDatabase selectTweetsFromLocal];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"tweetData.createAt" ascending:NO];
    tweets = [tweets sortedArrayUsingDescriptors:@[sort]];
    self.weiboData = [NSMutableArray arrayWithArray:tweets];
    //获取未读消息
    [self loadUnreadCount];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshTweet:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
    [self.tableView registerNib:[UINib nibWithNibName:kQYWeiboCell bundle:nil] forCellReuseIdentifier:kQYWeiboCell];
    [self.tableView registerNib:[UINib nibWithNibName:kFooterView bundle:nil] forHeaderFooterViewReuseIdentifier:kFooterView];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    if (self.weiboData.count == 0) {
        //从网络请求数据
        [self loadData];
    }
}

#pragma mark - add subviews
- (void)setupButtonWithTitle:(NSString *)title enable:(BOOL)isEnable
{
    UIButton *titleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 2, 100, 40)];
    [titleBtn setTitle:title forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleBtn addTarget:self action:@selector(showLocalUserInfo:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    titleBtn.enabled = isEnable;
    self.navigationItem.titleView = titleBtn;
}

#pragma mark - add not login UI
- (void)setupNotLoginImage
{
    self.boundsImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.boundsImgView.image = [UIImage imageNamed:@"visitordiscover_feed_image_smallicon"];
    self.boundsImgView.center = CGPointMake(self.view.center.x, self.view.center.y - 120);
    [self.view addSubview:self.boundsImgView];
    [self setupTransluteLabel];
    [self setupLabel];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.center = self.boundsImgView.center;
    imageView.image = [UIImage imageNamed:@"visitordiscover_feed_image_house"];
    imageView.tag = 600;
    [self.view addSubview:imageView];
}

- (void)setupTransluteLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2 - 120, kHeight - 390, 240, 20)];
    label.backgroundColor = self.view.backgroundColor;
    label.alpha = 0.7;
    [self.view addSubview:label];
}

- (void)setupLabel
{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2 - 120, kHeight - 370, 240, 140)];
    lable.backgroundColor = self.view.backgroundColor;
    lable.numberOfLines = 0;
    lable.text = [NSString stringWithFormat:@" \r \r但你关注一些人以后，他们发布的最新消息会显示在这里"];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor lightGrayColor];
    lable.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:lable];
}

- (void)startImageAnimating
{
    [UIView animateWithDuration:2.6 animations:^{
        self.boundsImgView.transform = CGAffineTransformRotate(self.boundsImgView.transform, M_PI_4);
    }];
}

- (void)removeImage
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:600];
    if (imageView) {
        [imageView removeFromSuperview];
    }
}

- (void)setButton
{
    [self setupBtnWithTitle:@"注册" rect:CGRectMake(kWidth/2 - 120, kHeight - 260, 100, 40) selector:(@selector(registerAcount:)) setTitleColor:[UIColor orangeColor]];
    [self setupBtnWithTitle:@"登录" rect:CGRectMake(kWidth/2 + 20, kHeight - 260, 100, 40) selector:(@selector(login:)) setTitleColor:[UIColor darkGrayColor]];
}

- (void)setupBtnWithTitle:(NSString *)title rect:(CGRect)rect selector:(SEL)selector setTitleColor:(UIColor *)color
{
    UIButton *btn = [[UIButton alloc]initWithFrame:rect];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"userinfo_relationship_messagebutton_background"] forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageNamed:@"userinfo_relationship_messagebutton_background_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

#pragma mark - load data from to sina weibo
- (void)loadData
{
    if(self.isRefreshing){
        return;
    }
    if (![self.accountInfo isLogining]) {
        return;
    }
    self.isRefreshing = YES;
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/home_timeline.json"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.accountInfo.accessToken forKey:kAccessToken];
    [parameters setObject:@2 forKey:kCount];
    if (self.weiboData.count > 0) {
        [parameters setObject:[self.weiboData.firstObject tweetData].tweetID forKey:@"since_id"];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Response object : %@",responseObject);
        NSArray *statuses = responseObject[kStatuses];
        NSMutableArray *tweets = [NSMutableArray array];
        for (NSDictionary *dic in statuses) {
            QYTweet *tweet = [[QYTweet alloc]initTweetWithDictionary:dic];
            [tweets addObject:tweet];
        }
        if (self.weiboData) {
            [tweets addObjectsFromArray:self.weiboData];
        }
        [self showNumberOfLoadData:statuses.count];
        self.weiboData = tweets;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        //保存模型数据
        [QYTweetDatabase saveTweetDataWithArray:statuses];
        self.isRefreshing = NO;
        self.tabBarItem.badgeValue = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error : %@",error);
        [self showNumberOfLoadData:0];
        self.isRefreshing = NO;
    }];
}
#pragma mark - down load old data
- (void)loadMoreData
{
    if (![self.accountInfo isLogining]) {
        
        return;
    }
    self.isRefreshing = YES;
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/home_timeline.json"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.accountInfo.accessToken forKey:kAccessToken];
    [parameters setObject:@20 forKey:kCount];
    if (self.weiboData.count > 0) {
        [parameters setObject:[self.weiboData.lastObject tweetData].tweetID forKey:@"max_id"];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *statuses = responseObject[kStatuses];
        NSMutableArray *tweets = [NSMutableArray array];
        for (NSDictionary *dic in statuses) {
            QYTweet *tweet = [[QYTweet alloc]initTweetWithDictionary:dic];
            [tweets addObject:tweet];
        }
        if (self.weiboData.count > 0) {
            QYTweetData *lastTweetData = [self.weiboData.lastObject tweetData];
            QYTweetData *firtTweetData = [tweets.firstObject tweetData];
            if (firtTweetData.tweetID == lastTweetData.tweetID) {
                [tweets removeObjectAtIndex:0];
            }
        }
        [self.weiboData addObjectsFromArray:tweets];
        [self.tableView reloadData];
        //保存模型数据
        [QYTweetDatabase saveTweetDataWithArray:statuses];
        self.isRefreshing = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error : %@",error);
        self.isRefreshing = NO;
    }];
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.weiboData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYWeiboCell *weiboCell = [tableView dequeueReusableCellWithIdentifier:kQYWeiboCell forIndexPath:indexPath];
    weiboCell.selectionStyle = UITableViewCellSelectionStyleNone;
    QYTweet *tweet = self.weiboData[indexPath.section ];
    [weiboCell cellWithTweet:tweet];
    [self button:weiboCell.iconBtn setTitle:nil tag:indexPath.section selector:@selector(goToUserInfo:)];
    [self button:weiboCell.userName setTitle:[weiboCell.userName titleForState:UIControlStateNormal] tag:indexPath.section selector:@selector(getUserInfo:)];
    [self button:weiboCell.attentionBtn setTitle:[weiboCell.attentionBtn titleForState:UIControlStateNormal] tag:indexPath.section selector:@selector(following:)];
    
    return weiboCell;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYWeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:kQYWeiboCell];
    QYTweet *tweet = self.weiboData[indexPath.section];
    CGFloat cellHeight = [cell heightForCellWithTweet:tweet];
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    QYFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kFooterView];
    QYTweet *footerContent = self.weiboData[section];
    NSInteger repostCount = footerContent.tweetData.repostsCount;
    if (repostCount == 0) {
        [self button:footerView.retweedBtn setTitle:@"转发" tag:section selector:@selector(repost:)];
    }else{
        [self button:footerView.retweedBtn setTitle:[@(repostCount) stringValue] tag:section selector:@selector(repost:)];
    }
    NSInteger commentCount = footerContent.tweetData.commentsCount;
    if (commentCount == 0) {
        [self button:footerView.commentBtn setTitle:@"评论" tag:section selector:@selector(comment:)];
    }else{
        [self button:footerView.commentBtn setTitle:[@(commentCount) stringValue] tag:section selector:@selector(comment:)];
    }
    NSInteger likeCount = footerContent.tweetData.attitudesCount;
    if (likeCount == 0) {
        [self button:footerView.likeBtn setTitle:@"赞" tag:section selector:@selector(like:)];
    }else{
        [self button:footerView.likeBtn setTitle:[@(likeCount) stringValue] tag:section selector:@selector(like:)];
    }
    if(footerContent.tweetData.favorited){
        footerView.likeBtn.highlighted = YES;
    }else{
        footerView.likeBtn.highlighted = NO;
    }
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.weiboData.count - indexPath.section < 5) {
        [self loadMoreData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYTweet *tweet = self.weiboData[indexPath.section];
    QYTweetInfo *tweetInfoVC = [[QYTweetInfo alloc]init];
    tweetInfoVC.tweet = tweet;
    tweetInfoVC.hidesBottomBarWhenPushed = YES;
    [self showViewController:tweetInfoVC sender:nil];
}

#pragma mark - button setting
- (void)button:(UIButton *)btn setTitle:(NSString *)title tag:(NSInteger)tag selector:(SEL)selector
{
    [btn setTitle:title forState:UIControlStateNormal];
    btn.tag = tag;
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - load unread_count
- (void)loadUnreadCount
{
    NSLog(@"home directory : %@",NSHomeDirectory());
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"remind/unread_count.json"];
    QYAcountInfo *remindInfo = [QYAcountInfo shareAcountInfo];
    if (remindInfo.accessToken == nil) {
        return;
    }
    NSDictionary *paramters = @{
                                kAccessToken:remindInfo.accessToken,
                                kUserID:remindInfo.userID
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:paramters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //NSLog(@"=========responseObject:%@",responseObject);
             int unreadCount = [responseObject[kStatus] intValue];
             //if (unreadCount) {
                 self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",unreadCount];
            //}
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"=======Error : %@",error);
         }];
}

#pragma mark - show number of load weibo
- (void)showNumberOfLoadData:(NSInteger)number
{
    UILabel *weiboCountLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 34, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
    weiboCountLable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]];
    weiboCountLable.alpha = 0.7;
    weiboCountLable.text = [NSString stringWithFormat:@"%ld条新微薄",(long)number];
    weiboCountLable.textAlignment = NSTextAlignmentCenter;
    [self.navigationController.navigationBar insertSubview:weiboCountLable belowSubview:self.navigationController.navigationBar];
    [UIView animateWithDuration:0.7 animations:^{
        weiboCountLable.transform = CGAffineTransformMakeTranslation(0, 30);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 animations:^{
            weiboCountLable.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [weiboCountLable removeFromSuperview];
        }];
    }];
}

#pragma mark - action
- (void)login:(UIButton *)sender
{
    QYLoginViewController *loginVC = [[QYLoginViewController alloc]init];
    UINavigationController *loginNVC = [[UINavigationController alloc]initWithRootViewController:loginVC];
    [self showViewController:loginNVC sender:nil];
}
- (void)registerAcount:(UIButton *)sender
{

}
- (void)addAttention
{
    
}

- (void)showLocalUserInfo:(UIButton *)sender withEvent:(UIEvent *)event
{
    QYHomeTitleVC *homeTitleVc = [[QYHomeTitleVC alloc]initWithStyle:UITableViewStylePlain];
    homeTitleVc.view.frame = CGRectMake(0, 0, 150, 200);
    TSPopoverController *popverController = [[TSPopoverController alloc]initWithContentViewController:homeTitleVc];
    popverController.popoverBaseColor = [UIColor lightGrayColor];
    popverController.popoverGradient = NO;
    [popverController showPopoverWithTouch:event];
}

- (void)scanHandleNavigationItem:(UIBarButtonItem *)sender withEvent:(UIEvent *)event
{
    TSActionSheet *actionSheet = [[TSActionSheet alloc]initWithTitle:nil];
    [actionSheet addButtonWithTitle:@"扫一扫" block:^{
        [self showQRCodeView];
    }];
    
    [actionSheet addButtonWithTitle:@"刷新" block:^{
        [self loadData];
    }];
    [actionSheet showWithTouch:event];
}

- (void)showQRCodeView
{
    QYQRCodeViewController *QRVC = [[QYQRCodeViewController alloc]init];
    UINavigationController *QRNVC = [[UINavigationController alloc]initWithRootViewController:QRVC];
    [self presentViewController:QRNVC animated:YES completion:nil];
}

- (void)refreshTweet:(id)sender
{
    [self loadData];
}
- (void)goToUserInfo:(UIButton *)sender
{
    QYUserInfoViewController *userVc = [[QYUserInfoViewController alloc]init];
    [self presentViewController:userVc animated:YES completion:^{
        QYTweet *tweet = self.weiboData[sender.tag];
        UIImageView *imageView = [[UIImageView alloc]init];
        [imageView sd_setImageWithURL:[NSURL URLWithString:tweet.tweetData.user.avatarHd] placeholderImage:nil];
        NSString *name = tweet.tweetData.user.name;
        NSInteger attentionNum = tweet.tweetData.user.friendsCount;
        NSInteger followMeNum = tweet.tweetData.user.followersCount;
        NSInteger biFollow = tweet.tweetData.user.biFollowersCount;
        NSInteger isOnline  = tweet.tweetData.user.onlineStatus;
        NSString *gender = tweet.tweetData.user.gender;
        NSString *descriptions = tweet.tweetData.user.descriptions;
        NSString *location = tweet.tweetData.user.location;
        NSDate *creatTime = tweet.tweetData.createAt;
        NSString *formaterStr = @"yyyy-MM-dd HH:mm";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:formaterStr];
        userVc.creatTime.text = [dateFormatter stringFromDate:creatTime];
        userVc.name.text = name;
        userVc.icon.image = imageView.image;
        userVc.attentionNum.text = [NSString stringWithFormat:@"关注 %ld",(long)attentionNum];
        userVc.followMeCount.text = [NSString stringWithFormat:@"粉丝 %ld",(long)followMeNum];
        if ([gender isEqualToString:@"m"]) {
            userVc.gener.text = @"男";
        }else{
            userVc.gener.text = @"女";
        }
        userVc.location.text = location;
        userVc.biFolowNum.text = [@(biFollow) stringValue];
        if (isOnline) {
            userVc.status.text = @"在线";
        }else{
            userVc.status.text = @"离线";
        }
        userVc.descriptions.text = descriptions;
    }];
}

- (void)getUserInfo:(UIButton *)userName
{
    QYTweet *tweet = self.weiboData[userName.tag];
    QYUser *user = tweet.tweetData.user;
    QYUserInfoTableViewController *userInfoVC = [[QYUserInfoTableViewController alloc]init];
    UINavigationController *userInfoNVC = [[UINavigationController alloc]initWithRootViewController:userInfoVC];
    //[self.navigationController showDetailViewController:userInfoNVC sender:self];
    [self.navigationController showViewController:userInfoNVC sender:self];
    userInfoVC.user = user;
/*
    NSLog(@"user info : %@",tweet);
    NSString *name = user.name;
    NSString *descriptions = user.descriptions;
    NSString *blog = user.blogURL;
    NSString *onlineStatus = nil;
    NSString *userID = [@(user.userID) stringValue];
    if(user.onlineStatus == 0){
    onlineStatus = @"离线";
    }else{
    onlineStatus = @"在线";
    }
    UIActionSheet *userInfoSheet = [[UIActionSheet alloc]initWithTitle:@"好友信息" delegate:self cancelButtonTitle:[NSString stringWithFormat:@"姓名:%@",name] destructiveButtonTitle:[NSString stringWithFormat:@"description:%@",descriptions]otherButtonTitles:[NSString stringWithFormat:@"状态:%@",onlineStatus], [NSString stringWithFormat:@"博客地址:%@",blog],[NSString stringWithFormat:@"ID :%@",userID], nil];
    [userInfoSheet showInView:self.view];
*/
}

#pragma mark - repost comment attitudes
- (void)repost:(UIButton *)sender
{
    QYTweet *repostTweet = self.weiboData[sender.tag];
    NSInteger repostID = [repostTweet.tweetData.tweetID integerValue];
    QYEdittingViewController *edittingVC = [[QYEdittingViewController alloc]init];
    UINavigationController *edittingNVC = [[UINavigationController alloc]initWithRootViewController:edittingVC];
    [self presentViewController:edittingNVC animated:YES completion:^{
        edittingVC.tweetID = repostID;
        [edittingVC.image sd_setImageWithURL:[NSURL URLWithString:repostTweet.tweetData.user.avatarHd]];
        edittingVC.name.text = repostTweet.tweetData.user.name;
        edittingVC.text.text = repostTweet.tweetData.text;
    }];
}

- (void)comment:(UIButton *)sender
{
    QYTweet *repostsTweet = self.weiboData[sender.tag];
    NSInteger commentID = [repostsTweet.tweetData.tweetID integerValue];
    QYCommentViewController *commentVC = [[QYCommentViewController alloc]init];
    UINavigationController *commentNVC = [[UINavigationController alloc]initWithRootViewController:commentVC];
    [self presentViewController:commentNVC animated:YES completion:^{
        commentVC.tweetID = commentID;
    }];
}
//赞
- (void)like:(UIButton *)sender
{
    QYTweet *tweet = self.weiboData[sender.tag];
    NSDictionary *parameters = @{
                                @"attitude":@"simle",
                                kAccessToken:self.accountInfo.accessToken.self,
                                kID:tweet.tweetData.tweetID
                                };
    NSString *urlStrCreate = [kBaseURL stringByAppendingPathComponent:@"attitudes/create.json"];
    NSString *urlStrDestory = [kBaseURL stringByAppendingPathComponent:@"attitudes/destroy.json"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr;
    if (sender.highlighted) {
        urlStr = urlStrDestory;
    }else{
        urlStr = urlStrCreate;
    }
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (sender.highlighted) {
            sender.highlighted = NO;
        }else{
            sender.highlighted = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error : %@,responseString :%@",error,operation.responseString);
    }];
}

//关注
- (void)following:(UIButton *)follow
{
    QYTweet *userInfo = self.weiboData[follow.tag];
    QYUser *user = userInfo.tweetData.user;
    NSString *urlStr;
    if (follow.highlighted) {
        urlStr = [kBaseURL stringByAppendingPathComponent:@"friendships/destroy.json"];
    }else{
        urlStr = [kBaseURL stringByAppendingPathComponent:@"friendships/create.json"];
    }
    NSDictionary *parameters = @{
                                 kAccessToken:self.accountInfo.accessToken,
                                 kUserID:@(user.userID)
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"follow response object : %@",responseObject);
        NSLog(@"%@",urlStr);
        if (follow.highlighted) {
            follow.highlighted = NO;
            userInfo.tweetData.favorited = NO;
            NSLog(@"*****取消关注");
        }else{
            follow.highlighted = YES;
            userInfo.tweetData.favorited = YES;
            NSLog(@"*****已关注");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"follow error : %@",error);
    }];
}

@end
