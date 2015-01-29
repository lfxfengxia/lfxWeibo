//
//  QYAcountMagViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/10.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYAcountMagViewController.h"
#import "QYMainViewController.h"
#import "QYLoginViewController.h"
#import "QYSetViewController.h"
#import "QYAcountInfo.h"
#import "QYAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "Common.h"
#import "QYLoginUserInfo.h"
#import "QYUser.h"

@interface QYAcountMagViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UIAlertView *alertView;
@property (nonatomic,strong) NSArray *rowsArray;
@property (nonatomic,strong) QYUser *user;
@property (nonatomic,strong) NSUserDefaults *defaults;

@end

@implementation QYAcountMagViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"账号管理";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.rowsArray = @[@"个人资料",@""];
    self.user = [[QYLoginUserInfo defaultLoginUser] getUserInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"userinfo_tabicon_back_highlighted"] style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss:)];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
}

#pragma mark - item action
- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rowsArray.count;
}

-  (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"acountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        UIImageView *imgView = [self addIcon];
        [cell.contentView addSubview:imgView];
        UILabel *label = [self setupLabel];
        [cell.contentView addSubview:label];
    }else{
        UIButton *button = [self setupButton];
        [cell.contentView addSubview:button];
    }
    return cell;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    }else{
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    QYMainViewController *mainVc = [[QYMainViewController alloc]init];
    appDelegate.window.rootViewController = mainVc;
    mainVc.selectedIndex = 0;
}

#pragma mark - setup alertView
- (void)setupAlertView
{
    self.alertView = [[UIAlertView alloc]initWithTitle:@"退出登录" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[QYLoginUserInfo defaultLoginUser] deleteUserInfo];
        QYLoginViewController *loginVC = [[QYLoginViewController alloc]init];
        UINavigationController *loginNVC = [[UINavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:loginNVC animated:NO completion:^{
            [[QYAcountInfo shareAcountInfo] deleteAcountInfo];
        }];
    }
}

#pragma mark - action
- (void)showAlert
{
    [self setupAlertView];
    [self.alertView show];
}

#pragma mark - set first cell contentView
- (UIImageView *)addIcon
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarHd] placeholderImage:nil];
    return imageView;
}
- (UILabel *)setupLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 240, 30)];
    label.text = self.user.name;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
- (UIButton *)setupButton
{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(110, 2, 120, 40)];
    if (![[QYAcountInfo shareAcountInfo] isLogining]) {
        button.enabled = NO;
    }else{
        button.enabled = YES;
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:@"退出当前账号" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
