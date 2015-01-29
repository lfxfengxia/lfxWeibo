//
//  QYMentionMe.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/23.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYMentionMe.h"
#import "Common.h"
#import "QYAcountInfo.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYMentionCell.h"
#import "QYTweet.h"
#import "QYTweetDatabase.h"
#import "TSPopoverController.h"
#import "QYMentionTitle.h"
#import "QYTweetDatabase.h"
#import "QYFooterView.h"

#define kCellIdentifier                 @"MentionCell"

#define kMetionFootView                 @"QYFooterView"

@interface QYMentionMe ()

@property (nonatomic,strong) NSMutableArray *mentionData;

@end

static BOOL notLogin = 0;

@implementation QYMentionMe

- (instancetype)init
{
    if (self = [super init]) {
       
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[QYAcountInfo shareAcountInfo] isLogining]) {
        [self setupNotLoginImage];
        return;
    }
    [self removeImage];
    
    self.title = @"所有微博";

    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"QYMentionCell2" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kMetionFootView bundle:nil] forHeaderFooterViewReuseIdentifier:kMetionFootView];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(setting)];
    [self setupButtonAsTitle];
    [self loadMentionDataFromServer];
}

#pragma mark - setup subviews
- (void)setupButtonAsTitle
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(160, 2, 400, 40)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"所有微博" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showWeiocatagory:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = btn;
}

- (void)setupNotLoginImage
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(00, 0, 200, 200)];
    imageView.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    UIImage *image = [UIImage imageNamed:@"empty_at"];
    imageView.image = image;
    [self.view addSubview:imageView];
}

- (void)removeImage
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:600];
    if (imageView) {
        [imageView removeFromSuperview];
    }
}

#pragma mark - load mention data
- (void)loadMentionDataFromServer
{
    if (![[QYAcountInfo shareAcountInfo] isLogining]) {
        return;
    }
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/mentions.json"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    id accessToken = [[QYAcountInfo shareAcountInfo] accessToken];
    [parameters setObject:accessToken forKey:kAccessToken];
    [parameters setObject:@20 forKey:kCount];
    if (self.mentionData.count) {
        id firstID = [self.mentionData.firstObject tweetData].tweetID;
        [parameters setObject:firstID forKey:@"since_id"];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *array = responseObject[@"statuses"];
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:array.count];
        if (self.mentionData == nil) {
            self.mentionData = [NSMutableArray array];
        }
        for (NSDictionary *dic in array) {
            QYTweet *tweet = [[QYTweet alloc]initTweetWithDictionary:dic];
            if (tweet) {
                [tmpArray addObject:tweet];
            }
        }
        if (tmpArray) {
            [self.mentionData addObjectsFromArray:tmpArray];
        }
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error :%@ responseString :%@",error,operation.responseString);
        [self.refreshControl endRefreshing];
    }];
}

- (void)loadPreMentionDataFromServer
{
    if (!notLogin) {
        return;
    }
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/mentions.json"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[[QYAcountInfo shareAcountInfo] accessToken] forKey:kAccessToken];
    [parameters setObject:@5 forKey:kCount];
    if (self.mentionData.count) {
        id lastID = [self.mentionData.lastObject tweetData].tweetID;
        [parameters setObject:lastID forKey:@"max_id"];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *array = responseObject[@"statuses"];
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *dic in array) {
            QYTweet *tweet = [[QYTweet alloc]initTweetWithDictionary:dic];
            if (tweet) {
                [tmpArray addObject:tweet];
            }
        }
        if (tmpArray) {
            NSInteger lastID = [[self.mentionData.firstObject tweetData].tweetID integerValue];
            NSInteger firstID = [[tmpArray.firstObject tweetData].tweetID integerValue];
            if (lastID == firstID) {
                [tmpArray removeObjectAtIndex:0];
            }
            if (self.mentionData == nil) {
                self.mentionData = [NSMutableArray array];
            }
            [self.mentionData addObjectsFromArray:tmpArray];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error :%@ responseString :%@",error,operation.responseString);
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mentionData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QYMentionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    QYTweet *mention = self.mentionData[indexPath.section];
    [cell setCellDataWithMentionTweet:mention];
    return cell;
}
#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYMentionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    QYTweet *tweet = self.mentionData[indexPath.section];
    CGFloat cellHeight = [cell cellHeightWithMentionTweet:tweet];
    return cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    QYFooterView *footView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kMetionFootView];
    QYTweet *tweet = self.mentionData[section];
    NSInteger repostsCount = tweet.tweetData.repostsCount;
    footView.retweedBtn.tag = section;
    [footView.retweedBtn setTitle:[@(repostsCount) stringValue] forState:UIControlStateNormal];
    if (repostsCount == 0) {
        [footView.retweedBtn setTitle:@"转发" forState:UIControlStateNormal];
    }
    [footView.retweedBtn addTarget:self action:@selector(repostTweet:) forControlEvents:UIControlEventTouchUpInside];
    NSInteger commentsCount = tweet.tweetData.commentsCount;
    footView.commentBtn.tag = section;
    [footView.commentBtn setTitle:[@(commentsCount) stringValue] forState:UIControlStateNormal];
    if (commentsCount == 0) {
        [footView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    }
    [footView.commentBtn addTarget:self action:@selector(commentTweet:) forControlEvents:UIControlEventTouchUpInside];
    NSInteger attitudesCount = tweet.tweetData.attitudesCount;
    footView.likeBtn.tag = section;
    [footView.likeBtn setTitle:[@(attitudesCount) stringValue] forState:UIControlStateNormal];
    if (attitudesCount == 0) {
        [footView.likeBtn setTitle:@"赞" forState:UIControlStateNormal];
    }
    [footView.likeBtn addTarget:self action:@selector(attitudeTweet:) forControlEvents:UIControlEventTouchUpInside];
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}


- (void)tableView:(UITableView *)tableView willADisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mentionData.count - indexPath.section < 5) {
        [self loadPreMentionDataFromServer];
    }
}

#pragma mark - action
-  (void)repostTweet:(UIButton *)sender
{
}

- (void)commentTweet:(UIButton *)sender
{
}

- (void)attitudeTweet:(UIButton *)sender
{
}

- (void)refresh:(UIRefreshControl *)sender
{
    [self loadMentionDataFromServer];
}

- (void)setting
{
    
}

- (void)showWeiocatagory:(UIButton *)sender withEvent:(UIEvent *)event
{
    QYMentionTitle *tableViewController = [[QYMentionTitle alloc]initWithStyle:UITableViewStylePlain];
    tableViewController.view.frame = CGRectMake(0, 0, 150, 200);
    TSPopoverController *popoVerController = [[TSPopoverController alloc]initWithContentViewController:tableViewController];
    popoVerController.popoverBaseColor = [UIColor lightGrayColor];
    popoVerController.popoverGradient = NO;
    [popoVerController showPopoverWithRect:sender.frame];
}


@end
