//
//  QYUserInfoTableViewController.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/26.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYUserInfoTableViewController.h"
#import "QYUser.h"
#import "QYUserHeaderView.h"
#import "UIImageView+WebCache.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYAcountInfo.h"
#import "QYTweet.h"
#import "QYWeiboCell.h"
#import "Common.h"
#import "QYUserBaseInfo.h"

#define kTableHeader                        @"QYUserInfoTableHader"
#define kQYUserHeaderView                   @"QYUserHeaderView"
#define kQYWeiboCell                        @"QYWeiboCell"

static NSInteger indexNum = 1;

@interface QYUserInfoTableViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImg;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *sexImg;
@property (weak, nonatomic) IBOutlet UIImageView *leveImg;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UIButton *fansBtn;
@property (weak, nonatomic) IBOutlet UILabel *weiboLabel;
@property (weak, nonatomic) IBOutlet UIButton *editInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *selfMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *attentedBtn;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *personalTweets;
@property (nonatomic,strong) NSMutableArray *homeInfo;
@property (nonatomic,strong) QYUserHeaderView *headerView;
@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UIImageView *bottomImageView;

@end

@implementation QYUserInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.user.name;
    self.headerView = [[QYUserHeaderView alloc]init];
    [self setupBottomImageView];
    NSArray *homelabel = @[
                      @"所在地",
                      @"简介"
                      ];
    NSMutableArray *homeDeatial = [NSMutableArray array];
    [homeDeatial addObject:self.user.location];
    [homeDeatial addObject:self.user.descriptions];
    self.homeInfo = [NSMutableArray array];
    [self.homeInfo addObject:homelabel];
    [self.homeInfo addObject:homeDeatial];
    
    [self setNavigationBar];
    self.navigationController.navigationBar.clipsToBounds = NO;
    [self setupImageView];
    self.navigationController.navigationBar.translucent = NO;
    UIView *header = [[NSBundle mainBundle] loadNibNamed:kTableHeader owner:self options:nil][0];
   
    [self setupTableViewWith:header];
    [self setView:self.iconBtn WithcornerRadius:40];
    [self headerWithData:self.user];
    
    [self.tableView registerNib:[UINib nibWithNibName:kQYWeiboCell bundle:nil] forCellReuseIdentifier:kQYWeiboCell];
    
    //[self loadPersonalTweetsFromServerByUserID:@(self.user.userID)];
    [self loadPersonalTweetsFromServer];
}

- (void)setupBottomImageView
{
    self.bottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(145, 26, 30, 2)];
    self.bottomImageView.image = [UIImage imageNamed:@"timeline_new_status_background"];
    [self.headerView addSubview:self.bottomImageView];
}

#pragma mark - load data
- (void)loadPersonalTweetsFromServer//ByUserID:(id)userID
{
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/user_timeline.json"];
    NSDictionary *parameters = @{
                                 kAccessToken:[[QYAcountInfo shareAcountInfo] accessToken],
                                 //@"uid":userID
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object :%@",responseObject);
        if (self.personalTweets == nil) {
            self.personalTweets = [NSMutableArray array];
        }
        NSArray *array = responseObject[@"statuses"];
        for (NSDictionary *dic in array) {
            QYTweet *tweet = [[QYTweet alloc]initTweetWithDictionary:dic];
            if (tweet) {
                [self.personalTweets addObject:tweet];
            }
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response string :%@",operation.responseString);
    }];
}

#pragma mark - add tablView
- (void)setupTableViewWith:(UIView *)header
{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = header;
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

#pragma mark - set table header subviews
- (void)setView:(UIView *)view WithcornerRadius:(CGFloat)cornerRaduis
{
    view.layer.cornerRadius = cornerRaduis;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2;
}

- (void)setupImageView
{
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -150, CGRectGetWidth([UIScreen mainScreen].bounds), 400)];
    NSString *loginUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSString *currentUserID = [@(self.user.userID) stringValue];
    if ([loginUserID isEqualToString:currentUserID]) {
        self.imageView.image = [UIImage imageNamed:@"me_background"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"other_background"];
    }
    [self.view addSubview:self.imageView];
}

#pragma mark - set navigationBar
- (void)setNavigationBar
{
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [self setupBtnWithImage:@"userinfo_tabicon_more" highlitedImage:@"userinfo_tabicon_more_highlighted" inRect:CGRectMake(width - 20, 11.5, 21, 21) inView:self.navigationController.navigationBar];
    [self setupBtnWithImage:@"userinfo_tabicon_search" highlitedImage:@"userinfo_tabicon_search_highlighted" inRect:CGRectMake(width - 70, 11.5, 21, 21) inView:self.navigationController.navigationBar];
}

- (void)setupBtnWithImage:(NSString *)imageName highlitedImage:(NSString *)highlitedName inRect:(CGRect)rect inView:(UIView *)view
{
    UIButton *btn = [[UIButton alloc]initWithFrame:rect];
    btn.backgroundColor = [UIColor redColor];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlitedName] forState:UIControlStateHighlighted];
    [view addSubview:btn];
    NSLog(@"%@",NSStringFromCGRect(rect));
    NSLog(@"navigation bar subviews :%@",self.navigationController.navigationBar.subviews);
}

#pragma mark - set header value
- (void)headerWithData:(QYUser *)user
{
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarHd]];
    [self.iconBtn setImage:imageView.image forState:UIControlStateNormal];
    [self.nameBtn setTitle:self.user.name forState:UIControlStateNormal];
    self.nameBtn.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:17];
    [self.attentionBtn setTitle:[NSString stringWithFormat:@"关注：%ld",self.user.statusesCount] forState:UIControlStateNormal];
    self.attentionBtn.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:13];
    [self.fansBtn setTitle:[NSString stringWithFormat:@"粉丝： %ld",self.user.followersCount] forState:UIControlStateNormal];
    self.fansBtn.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:13];
    self.weiboLabel.text = [NSString stringWithFormat:@"简介：%@",self.user.descriptions];
    NSString *loginUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSString *currentUserID = [@(self.user.userID) stringValue];
    if ([loginUserID isEqualToString:currentUserID]) {
        self.selfMsgBtn.hidden = YES;
        self.attentedBtn.hidden = YES;
        self.editInfoBtn.hidden = NO;
    }else{
        self.selfMsgBtn.hidden = NO;
        self.attentedBtn.hidden = NO;
        self.editInfoBtn.hidden = YES;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (indexNum == 0) {
        return 3;
    }
    if (indexNum == 2) {
        return 6;
    }
    return self.personalTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexNum == 0) {
        cell = [self homeCell:tableView atIndexPath:indexPath];
    }else if (indexNum == 1){
        cell = [self tweetCell:tableView atIndexPath:indexPath];
    }else{
        cell = [self photosCell:tableView atIndexPath:indexPath];
    }
    cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"square_card_bg"]];
    cell.alpha = 1;
    return cell;
}

- (UITableViewCell *)homeCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *homeCellIdentifier = @"homeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:homeCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:homeCellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"基本信息";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.row < 3){
        cell.textLabel.text = self.homeInfo[0][indexPath.row - 1];
        cell.detailTextLabel.text = self.homeInfo[1][indexPath.row - 1];
        cell.textLabel.textColor = [UIColor redColor];
    }else {
        cell.textLabel.text = nil;
    }
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    return cell;
}

- (UITableViewCell *)tweetCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    QYWeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:kQYWeiboCell forIndexPath:indexPath];
    QYTweet *tweet = self.personalTweets[indexPath.row];
    [cell cellWithTweet:tweet];
    return cell;
}

- (UITableViewCell *)photosCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *photosCellIdentifier = @"photosCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:photosCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:photosCellIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"icon"];
    return cell;
}

#pragma mark - table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [self.headerView.homeBtn addTarget:self action:@selector(translateBottomImg:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.tweetBtn addTarget:self action:@selector(translateBottomImg:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.photosBtn addTarget:self action:@selector(translateBottomImg:) forControlEvents:UIControlEventTouchUpInside];
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexNum == 0) {
        return 44;
    }
    if (indexNum == 2) {
        return 44;
    }
    QYTweet *tweet = self.personalTweets[indexPath.row];
    QYWeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:kQYWeiboCell];
    CGFloat height = [cell heightForCellWithTweet:tweet];
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"全部微博";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexNum == 0 && indexPath.row == 0) {
        QYUserBaseInfo *userBaseInfoVC = [[QYUserBaseInfo alloc]init];
        UINavigationController *userBaseInfoNVC = [[UINavigationController alloc]initWithRootViewController:userBaseInfoVC];
        [self showViewController:userBaseInfoNVC sender:nil];
    }
}

#pragma mark - scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.imageView.frame = CGRectOffset(self.imageView.frame, 0, 100);
    }];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [UIView animateWithDuration:0.1 animations:^{
        self.imageView.frame = CGRectOffset(self.imageView.frame, 0, -100);
    }];
}

#pragma mark - action
- (void)translateBottomImg:(UIButton *)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        NSLog(@"center :%@",NSStringFromCGPoint(self.headerView.bottomImage.center));
        self.bottomImageView.center = CGPointMake(sender.center.x,self.bottomImageView.center.y);
    } completion:^(BOOL finished) {
        NSLog(@">>>center :%@",NSStringFromCGPoint(self.headerView.bottomImage.center));
        [self setIndexNumByView:sender];
        [self.tableView reloadData];
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
    }];
}

- (void)setIndexNumByView:(UIView *)view
{
    if (view.center.x == self.headerView.homeBtn.center.x) {
        indexNum = 0;
    }else if(view.center.x == self.headerView.tweetBtn.center.x){
        indexNum = 1;
    }else{
        indexNum = 2;
    }
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
