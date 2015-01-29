//
//  QYTweetInfo.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTweetInfo.h"
#import "QYWeiboCell.h"
#import "QYCommentCell.h"
#import "Common.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+WebCache.h"
#import "QYTweet.h"
#import "QYAcountInfo.h"
#import "QYComment.h"
#import "QYTweetDatabase.h"
#import "QYMainViewController.h"
#import "QYTooBar.h"
#import "QYSenderTweet.h"

@interface QYTweetInfo ()

@property (nonatomic,strong) NSMutableArray *commentsArray;
@property (nonatomic,strong) QYTooBar *tooBar;

@end

@implementation QYTweetInfo

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"微博正文";
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //从本地加载评论数据
    NSArray *comments = [QYTweetDatabase selectCommentsFromLocalByTweetID:self.tweet.tweetData.tweetID];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sourComment.createAt" ascending:NO];
    [comments sortedArrayUsingDescriptors:@[sort]];
    self.commentsArray = [NSMutableArray arrayWithArray:comments];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(loadNewData) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"QYWeiboCell" bundle:nil] forCellReuseIdentifier:@"QYWeiboCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"QYCommentCell" bundle:nil] forCellReuseIdentifier:@"QYCommentCell"];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    if (self.commentsArray.count == 0) {
        [self loadCommentsFromServer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
    
    [self.navigationController setToolbarHidden:NO];
    [self setTooBar];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController setToolbarHidden:YES];
}

#pragma mark - set tooBar
- (void)setTooBar
{
    UIButton *reweetBtn = [self setupButtonWithTitle:@"转发" andImageName:@"statusdetail_icon_retweet" highlitedImgName:@"statusdetail_icon_retweet"];
    [reweetBtn addTarget:self action:@selector(repost) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *reweetItem = [[UIBarButtonItem alloc]initWithCustomView:reweetBtn];
    UIButton *commentBtn = [self setupButtonWithTitle:@"评论" andImageName:@"statusdetail_comment_icon_more" highlitedImgName:@"statusdetail_comment_icon_more_highlighted"];
    [commentBtn addTarget:self action:@selector(comment) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc]initWithCustomView:commentBtn];
    UIButton *likeBtn = [self setupButtonWithTitle:@"赞" andImageName:@"statusdetail_comment_icon_like" highlitedImgName:@"statusdetail_comment_icon_like_highlighted@2x"];
    UIBarButtonItem *likeItem = [[UIBarButtonItem alloc]initWithCustomView:likeBtn];
    [likeBtn addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *firstImage = [self imageView];
    UIBarButtonItem *firstSperator = [[UIBarButtonItem alloc]initWithCustomView:firstImage];
    UIImageView *secondImage = [self imageView];
    UIBarButtonItem *secondSperator = [[UIBarButtonItem alloc]initWithCustomView:secondImage];
//    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
//    spaceItem.width = 20;
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSArray *items = @[reweetItem,spaceItem, firstSperator, spaceItem,commentItem,spaceItem,secondSperator,spaceItem, likeItem];
    [self setToolbarItems:items animated:YES];
}

- (UIButton *)setupButtonWithTitle:(NSString *)title andImageName:(NSString *)imageName highlitedImgName:(NSString *)highlitedName
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 2, 80, 40)];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlitedName] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    return btn;
}

- (UIImageView *)imageView
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 4, 1, 36)];
    imageView.image = [UIImage imageNamed:@"settings_statistic_verticalline"];
    return imageView;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }else{
        return self.commentsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        QYWeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYWeiboCell" forIndexPath:indexPath];
        [cell cellWithTweet:self.tweet];
        return cell;
    }else{
        QYCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYCommentCell" forIndexPath:indexPath];
        QYComment *comment = self.commentsArray[indexPath.row];
        [cell cellDataWithComment:comment];
        return cell;
    }
}
#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [[[QYWeiboCell alloc]init] heightForCellWithTweet:self.tweet];
    }else{
        QYComment *comment = self.commentsArray[indexPath.row];
        return [[[QYCommentCell alloc]init] cellHeightWithComment:comment];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UITabBar *headerView = [[UITabBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
        UITabBarItem *repostItem = [[UITabBarItem alloc]initWithTitle:@"转发" image:[UIImage imageNamed:@"statusdetail_icon_retweet"] selectedImage:nil];
        UITabBarItem *commentItem = [[UITabBarItem alloc]initWithTitle:@"评论" image:[UIImage imageNamed:@"statusdetail_icon_comment"] selectedImage:nil];
        UITabBarItem *likeItem = [[UITabBarItem alloc]initWithTitle:@"赞" image:[UIImage imageNamed:@"statusdetail_icon_like"] selectedImage:nil];
        headerView.tintColor = [UIColor grayColor];
        headerView.items = @[repostItem,commentItem,likeItem];
        return headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }else {
        return 44;
    }
}
#pragma mark - action
- (void)setToolbar
{
//    UIBarButtonItem *
}

- (void)loadNewData
{
    [self loadCommentsFromServer];
}

- (void)repost
{
    QYSenderTweet *sendVC = [[QYSenderTweet alloc]init];
    UINavigationController *sendNVC = [[UINavigationController alloc]initWithRootViewController:sendVC];
    //[self showViewController:sendNVC sender:nil];
    [self presentViewController:sendNVC animated:YES completion:nil];
    sendVC.tweet = self.tweet;
    sendVC.sendType = kRepost;
}
- (void)comment
{
    QYSenderTweet *sendVC = [[QYSenderTweet alloc]init];
    UINavigationController *sendNVC = [[UINavigationController alloc]initWithRootViewController:sendVC];
    //[self showViewController:sendNVC sender:nil];
    [self presentViewController:sendNVC animated:YES completion:nil];
    sendVC.tweet = self.tweet;
    sendVC.sendType = kComment;
}
- (void)like
{

}

#pragma mark - get comments from server
- (void)loadCommentsFromServer
{
    if (![[QYAcountInfo shareAcountInfo] isLogining]) {
        return;
    }
    NSString *commentUrlStr = [kBaseURL stringByAppendingPathComponent:@"comments/show.json"];
    NSString *tweetID = self.tweet.tweetData.tweetID;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[[QYAcountInfo shareAcountInfo] accessToken] forKey:kAccessToken];
    [parameters setObject:tweetID forKey:@"id"];
    [parameters setObject:@10 forKey:@"count"];
    if (self.commentsArray.count) {
        NSInteger commentID = [[self.commentsArray.firstObject sourComment] commentID];
        [parameters setObject:@(commentID) forKey:@"since_id"];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:commentUrlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object : %@",responseObject);
        NSArray *dataArray = [[NSArray alloc]initWithArray:responseObject[@"comments"]];
        self.commentsArray = [NSMutableArray array];
        for (NSDictionary *dic in dataArray) {
            QYComment *comment = [[QYComment alloc]initCommentWithDictionary:dic];
            if (comment) {
                [self.commentsArray addObject:comment];
            }
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [QYTweetDatabase saveCommentDataWithArray:dataArray andTweetID:self.tweet.tweetData.tweetID ];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@ \r responseString :%@",error,operation.responseString);
        [self.refreshControl endRefreshing];
    }];
}
@end
