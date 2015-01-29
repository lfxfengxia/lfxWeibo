//
//  QYSetViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/9.
//  Copyright (c) 2014年 河南青云. All rights reserved.


#import "QYSetViewController.h"
#import "QYAcountMagViewController.h"
#import "QYAcountInfo.h"
#import "QYLoginUserInfo.h"
#import "QYLoginViewController.h"

@interface QYSetViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation QYSetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
    self.dataArray = @[
                       @[@"账号管理"],
                       @[@"提醒和通知",@"通用设置",@"隐私与安全"],
                       @[@"意见反馈",@"关于微博"],
                       @[@"夜间模式",@"清除缓存"],
                       @[@""]
                       ];
}

#pragma mark - table view datasource
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
    NSString *identifier = @"setCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.section == self.dataArray.count - 1) {
        cell.textLabel.text = nil;
        UIButton *btn = [self setupButton];
        [cell.contentView addSubview:btn];
    }else{
        cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - addBtn
- (UIButton *)setupButton
{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(120, 2, 100, 40)];
    if (![[QYAcountInfo shareAcountInfo] isLogining]) {
        button.userInteractionEnabled = NO;
    }
    [button setTitle:@"退出微博" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        QYAcountMagViewController *acountVC = [[QYAcountMagViewController alloc]init];
        UINavigationController *acountNVC = [[UINavigationController alloc]initWithRootViewController:acountVC];
        [self presentViewController:acountNVC animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

#pragma mark - action
- (void)logout
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"退出账号将中断当前未发送完的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出" otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        QYLoginViewController *loginVC = [[QYLoginViewController alloc]init];
        [self showViewController:loginVC sender:self];
        [[QYAcountInfo shareAcountInfo] deleteAcountInfo];
        [[QYLoginUserInfo defaultLoginUser] deleteUserInfo];
    }
}
@end
