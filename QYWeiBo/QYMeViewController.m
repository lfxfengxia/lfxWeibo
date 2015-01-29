//
//  QYMeViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYMeViewController.h"
#import "QYSetViewController.h"
#import "UIImageView+WebCache.h"
#import "Common.h"
#import "QYUserInfoTableViewController.h"
#import "QYLoginUserInfo.h"
#import "QYAcountInfo.h"
#import "QYUser.h"
#import "QYLoginViewController.h"

#define kCellIndentify          @"QYMeTableViewCell"

@interface QYMeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) NSUserDefaults *defaults;
@property (nonatomic,strong) QYUser *user;

@end

@implementation QYMeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我" image:[UIImage imageNamed:@"tabbar_profile"] selectedImage:[UIImage imageNamed:@"tabbar_profile_selected"]];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![[QYAcountInfo shareAcountInfo] isLogining]) {
        [self setupNotLoginImage];
        [self setButton];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        return;
    }
    [self removeImage];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.user = [[QYLoginUserInfo defaultLoginUser] getUserInfo];
    [self.defaults setObject:@4 forKey:kLastSelectedIndex];
    self.dataArray = @[
                       @[@"个人"],
                       @[@"新的好友",@"完善资料"],
                       @[@"我的相册",@"我的收藏",@"赞"],
                       @[@"微博支付",@"个性化"],
                       @[@"我的名片",@"草稿箱"]
                       ];
    self.tableView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIndentify];
}
#pragma mark - set not login UI
- (void)setupNotLoginImage
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    imageView.center = CGPointMake(self.view.center.x, self.view.center.y - 150);
    imageView.image = [UIImage imageNamed:@"visitordiscover_image_profile@2x"];
    imageView.tag = 600;
    [self.view addSubview:imageView];
    [self setupLabel];
}

- (void)setupLabel
{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2 - 120, kHeight - 350, 240, 80)];
    lable.backgroundColor = self.view.backgroundColor;
    lable.numberOfLines = 0;
    lable.text = [NSString stringWithFormat:@"登录后，你的微薄、相册、个人人资料会显示在这里，展示给别人"];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor lightGrayColor];
    lable.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:lable];
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

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = self.dataArray[section];
    return rows.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentify forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIndentify];
    }
    if (indexPath.section == 0) {
        UIImageView *imageView = [self addIcon];
        [cell.contentView addSubview:imageView];
        UIView *view = [self addDescriptionAndName];
        [cell.contentView addSubview:view];
        cell.backgroundColor = [UIColor lightTextColor];
    }else{
        cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.separatorInset = UIEdgeInsetsZero;
    return cell;
}

#pragma mark - set first cell contentView
- (UIImageView *)addIcon
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarHd] placeholderImage:nil];
    return imageView;
}

- (UIView *)addDescriptionAndName
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(65, 0, 260, 80)];
    [self setupLabelWithRect:CGRectMake(0, 0, 260, 25) text:self.user.name addToView:view];
    NSString *brife = [NSString stringWithFormat:@"简介: %@",self.user.descriptions];
    if ([self.defaults objectForKey:kAccessToken] == nil) {
            brife = @"无任何账号登录";
    }
    [self setupLabelWithRect:CGRectMake(0, 40, 260, 30) text:brife addToView:view];
    return view;
}

- (void)setupLabelWithRect:(CGRect)rect text:(NSString *)text addToView:(UIView *)view
{
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    label.text = text;
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont fontWithName:@"Snell Roundhand" size:13];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    }else{
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        QYUserInfoTableViewController *userInfoVC = [[QYUserInfoTableViewController alloc]init];
        UINavigationController *userInfoNVC = [[UINavigationController alloc]initWithRootViewController:userInfoVC];
        [self showViewController:userInfoNVC sender:nil];
        userInfoVC.user = self.user;
    }
}

#pragma mark - button action
- (void)setting
{
    QYSetViewController *setVC = [[QYSetViewController alloc]init];
    UINavigationController *setNVC = [[UINavigationController alloc]initWithRootViewController:setVC];
    [self.navigationController showViewController:setNVC sender:nil];
}

- (void)login:(UIButton *)sender
{
    QYLoginViewController *loginVC = [[QYLoginViewController alloc]init];
    UINavigationController *loginNVC = [[UINavigationController alloc]initWithRootViewController:loginVC];
    [self showViewController:loginNVC sender:nil];
}

- (void)registerAcount:(UIButton *)sender
{
    
}

@end
