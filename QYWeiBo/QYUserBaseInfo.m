//
//  QYUserBaseInfo.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/28.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYUserBaseInfo.h"

#define kUserInfoCell               @"UserInfoCell"

@interface QYUserBaseInfo ()

@property (nonatomic,strong) NSArray *userInfo;

@end

@implementation QYUserBaseInfo

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userInfo = @[
                      @[@"登录名",@"昵称",@"性别",@"所在地",@"简介"],
                      @[@"添加工作信息"],
                      @[@"大学",@"添加教育信息"],
                      @[@"生日",@"邮箱",@"博客",@"QQ",@"MSN"],
                      @[@"勋章"],
                      @[@"注册时间"]
                      ];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kUserInfoCell];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.userInfo.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userInfo[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoCell forIndexPath:indexPath];
    cell.textLabel.text = self.userInfo[indexPath.section][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

@end
