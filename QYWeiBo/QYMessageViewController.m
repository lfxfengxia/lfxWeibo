//
//  QYMessageViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYMessageViewController.h"
#import "Common.h"
#import "QYMentionMe.h"
#import "QYCommentsToMe.h"
#import "QYAcountInfo.h"
#import "QYLoginViewController.h"

#define kMessegeCell        @"messageCell"

@interface QYMessageViewController ()

@property (nonatomic,strong) QYAcountInfo *accountInfo;

@end

@implementation QYMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"消息";
        self.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"消息" image:[UIImage imageNamed:@"tabbar_message_center"] selectedImage:[UIImage imageNamed:@"tabbar_message_center_highlighted"]];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountInfo = [QYAcountInfo shareAcountInfo];
    if (![self.accountInfo isLogining]) {
        [self setButton];
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMessegeCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@1 forKey:kLastSelectedIndex];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发起聊天" style:UIBarButtonItemStyleDone target:self action:nil];
    if (![self.accountInfo isLogining]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - set notlogin UI
- (void)setupNotLoginImage
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(00, 0, 200, 200)];
    imageView.center = CGPointMake(self.view.center.x, self.view.center.y - 140);
    UIImage *image = [UIImage imageNamed:@"visitordiscover_image_message"];
    imageView.image = image;
    [self.view addSubview:imageView];
    [self setupLabel];
}

- (void)setupLabel
{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2 - 120, kHeight - 350, 240, 80)];
    lable.backgroundColor = self.view.backgroundColor;
    lable.numberOfLines = 0;
    lable.text = [NSString stringWithFormat:@" 登录后，别人评论你的微博，给你发消息，都会在这里收到通知"];
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
    if (![[QYAcountInfo shareAcountInfo] isLogining]) {
        [self setupNotLoginImage];
        return 0;
    }
    [self removeImage];

    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessegeCell forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"messagescenter_at"];
            cell.textLabel.text = @"@我的";
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"messagescenter_comments"];
            cell.textLabel.text = @"评论";
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"messagescenter_good"];
            cell.textLabel.text = @"赞";
            break;
        case 3:
            cell.imageView.image = [UIImage imageNamed:@"messagescenter_messagebox"];
            cell.textLabel.text = @"未关注人私信";
        default:
            break;
    }
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        QYMentionMe *mentionVC = [[QYMentionMe alloc]init];
        UINavigationController *mentionNVC = [[UINavigationController alloc]initWithRootViewController:mentionVC];
        [self showViewController:mentionNVC sender:self];
    }else if (indexPath.row == 1){
        QYCommentsToMe *comments2Me = [[QYCommentsToMe alloc]init];
        UINavigationController *comments2MeNa = [[UINavigationController alloc]initWithRootViewController:comments2Me];
        [self.navigationController showViewController:comments2MeNa sender:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - action
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
