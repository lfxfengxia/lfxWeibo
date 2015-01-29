//
//  QYHomeTitleVC.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/24.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYHomeTitleVC.h"
#import "Common.h"
#import "QYAcountInfo.h"
#import "AFHTTPRequestOperationManager.h"

#define kCellIdentifier                   @"QYHomeTitleCell"

@interface QYHomeTitleVC ()

@property (nonatomic,strong) NSMutableArray *homeTitleLists;

@end

@implementation QYHomeTitleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    self.homeTitleLists = [NSMutableArray array];
    NSArray *array = @[@"首页",@"好友圈",@"我的微博",@"周边微博"];
    NSArray *fridentsLists = @[@"同学",@"同事",@"娱乐",@"新闻",@"英语"];
    [self.homeTitleLists addObject:array];
    [self.homeTitleLists addObject:fridentsLists];
    //[self loadFriendsListsFromServer];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.homeTitleLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.homeTitleLists[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.alpha = 0.2;
    cell.textLabel.text = self.homeTitleLists[indexPath.section][indexPath.row];
    return cell;
}

#pragma mark - table view delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"--@我的分组--";
    }else{
        return nil;
    }
}
#pragma mark - load lists from server
- (void)loadFriendsListsFromServer
{
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"/friendships/groups.json"];
    
    NSDictionary *parameters = @{
                                 kAccessToken:[[QYAcountInfo shareAcountInfo] accessToken]
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object : %@",responseObject);
        NSArray *lists = responseObject[@"lists"];
        [self.homeTitleLists addObject:lists];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@ responseString:%@",error,operation.responseString);
    }];
}

@end
