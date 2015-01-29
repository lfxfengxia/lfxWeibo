//
//  QYMentionTitle.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/24.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYMentionTitle.h"

#define kCellIndentifier            @"QYMentionTableViewCell"

@interface QYMentionTitle ()

@property (nonatomic,strong) NSArray *mentionArray;

@end

@implementation QYMentionTitle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mentionArray = @[
                          @[@"所有微博",@"关注人得微博",@"原创微博"],
                          @[@"所有评论",@"关注人的评论"]
                          ];
    self.tableView.backgroundColor = [UIColor grayColor];
    self.tableView.alpha = 0.3;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIndentifier];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mentionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mentionArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentifier forIndexPath:indexPath];
    cell.textLabel.text = self.mentionArray[indexPath.section][indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"--@我的评论--";
    }else{
        return nil;
    }
}

@end
