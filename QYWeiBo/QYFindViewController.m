//
//  QYFindViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYFindViewController.h"
#import "QYAcountInfo.h"
#import "Common.h"
#import "QYLoginViewController.h"
#import "MBProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYWeiboCell.h"
#import "QYFooterView.h"
#import "QYTweet.h"
#import "QYTweetDatabase.h"
#import "QYSecondCell.h"


#define kQYWeiboCell                @"QYWeiboCell"
#define kQYFooterView                       @"QYFooterView"
#define kStaticAccessToken                  @"2.00zK2CTDL7PjsDcbf0652f1diZPlIE"
#define kSecondCell                         @"QYSecondCell"

@interface QYFindViewController ()<MBProgressHUDDelegate,UISearchBarDelegate>

@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,assign) long long expectedLength;
@property (nonatomic,assign) long long currentLength;

@property (nonatomic,strong) NSMutableArray *publictweets;
@property (nonatomic,strong) NSMutableArray *logingContent;

@end
static BOOL isLogining;
@implementation QYFindViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"发现";
        self.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"发现" image:[UIImage imageNamed:@"tabbar_discover"] selectedImage:[UIImage imageNamed:@"tabbar_discover_selected"]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@3 forKey:kLastSelectedIndex];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isLogining = [[QYAcountInfo shareAcountInfo] isLogining];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if (isLogining) {
        [self afterLogin];
    }else{
        [self preLogin];
    }
}

#pragma mark - login
- (void)afterLogin
{
    UISearchBar *search = [[UISearchBar alloc]init];
    search.showsSearchResultsButton = YES;
    search.showsCancelButton = YES;
    search.placeholder = @" 寻你所需";
    search.delegate = self;
    search.searchBarStyle = UISearchBarStyleProminent;
    self.navigationItem.titleView = search;
    [self.tableView registerNib:[UINib nibWithNibName:kSecondCell bundle:nil] forCellReuseIdentifier:kSecondCell];
    [self searchLists];
}

- (void)preLogin
{
    UIBarButtonItem *loginItem = [[UIBarButtonItem alloc]initWithTitle:@"登录" style:UIBarButtonItemStylePlain target:self action:@selector(login)];
    self.navigationItem.rightBarButtonItem = loginItem;
    
    self.refreshControl =  [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerNib:[UINib nibWithNibName:kQYWeiboCell bundle:nil] forCellReuseIdentifier:kQYWeiboCell];
    [self.tableView registerNib:[UINib nibWithNibName:kQYFooterView bundle:nil] forHeaderFooterViewReuseIdentifier:kQYFooterView];
    
    if (self.publictweets.count == 0) {
        [self loadPublicTweetFromServer];
    }
}

#pragma mark - searchLists
- (void)searchLists
{
    self.logingContent = [NSMutableArray array];
    NSArray *firstArr = @[@"热门微博",@"找人"];
    NSArray *secondArr = @[@"周边"];
    NSArray *thirdArr = @[@"微观世界杯",@"电影",@"音乐",@"发现兴趣"];
    [self.logingContent addObject:firstArr];
    [self.logingContent addObject:secondArr];
    [self.logingContent addObject:thirdArr];
}

#pragma mark - get public twitter
- (void)loadPublicTweetFromServer
{
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/public_timeline.json"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:kStaticAccessToken forKey:kAccessToken];
    [parameters setObject:@50 forKey:kCount];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object :%@",responseObject);
        if (self.publictweets == nil) {
            self.publictweets = [NSMutableArray array];
        }
        NSArray *tweets = responseObject[@"statuses"];
        for (NSDictionary *dic in tweets) {
            QYTweet *tweet = [[QYTweet alloc]initTweetWithDictionary:dic];
            if (tweet) {
                [self.publictweets addObject:tweet];
            }
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error :%@ responsesString :%@",error,operation.responseString);
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isLogining) {
        return self.logingContent.count + 2;
    }else{
        return self.publictweets.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLogining) {
        if (section == 0 || section == 1) {
            return 1;
        }else{
            return [self.logingContent[section - 2] count];
            return 3;
        }
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLogining) {
        if (indexPath.section == 1) {
            QYSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:kSecondCell forIndexPath:indexPath];
            return cell;
        }else{
            NSString *identifier = @"LoginingCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            if (indexPath.section == 0) {
                UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"grass"]];
                imageView.frame = CGRectMake(0, 0, CGRectGetWidth(cell.frame), 100);
                [cell.contentView addSubview:imageView];
            }else{
                cell.textLabel.text = self.logingContent[indexPath.section - 2][indexPath.row];
            }
            return cell;
        }
    }else{
        QYWeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:kQYWeiboCell];
        if (cell == nil) {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>cell is nil");
        }
        QYTweet *tweet = self.publictweets[indexPath.section];
        [cell cellWithTweet:tweet];
        return cell;
    }
}

#pragma mark - table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (isLogining) {
        return nil;
    }else{
        QYFooterView *footView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kQYFooterView];
        QYTweet *tweet = self.publictweets[section];
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
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLogining) {
        if (indexPath.section == 0){
            return 100;
        }else if(indexPath.section == 1) {
            return 80;
        }else{
            return 44;
        }
    }else{
        QYWeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:kQYWeiboCell];
        
        if (cell == nil) {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>cell is nil");
        }
        
        QYTweet *tweet = self.publictweets[indexPath.section];
        return [cell heightForCellWithTweet:tweet];
        return 300;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isLogining) {
        return 1;
    }else{
        return 30;
    }
}

#pragma mark - search bar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - action
- (void)repostTweet:(UIButton *)sender
{
}

- (void)commentTweet:(UIButton *)sender
{
}

- (void)attitudeTweet:(UIButton *)sender
{
}

- (void)refresh:(id)sender
{
    [self loadPublicTweetFromServer];
}

- (void)login
{
    QYLoginViewController *loginVC = [[QYLoginViewController alloc]init];
    UINavigationController *loginNVC = [[UINavigationController alloc]initWithRootViewController:loginVC];
    [self presentViewController:loginNVC animated:YES completion:nil];
}

@end
