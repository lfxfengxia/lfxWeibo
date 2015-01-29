//
//  QYMainViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

//初始化控制器
//tabbarItem
//做一个加号按钮，
//moreController的展示方式

#import "QYMainViewController.h"
#import "QYHomeViewController.h"
#import "QYMessageViewController.h"
#import "QYMoreViewController.h"
#import "QYFindViewController.h"
#import "QYMeViewController.h"
#import "Common.h"
#import "QYAcountInfo.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYTabar.h"

#define kStatus             @"status"


@interface QYMainViewController ()


@end

@implementation QYMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    QYHomeViewController *homeVC = [[QYHomeViewController alloc]init];
//    [homeVC addObserver:self forKeyPath:@"isHiden" options:NSKeyValueObservingOptionNew context:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidenMoreBtn) name:@"hidenMoreBtn" object:nil];
    
    [self installViewController];
    
    [self.tabBar addSubview:self.moreBtn];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self setSelectedIndex];
    
    //NSLog(@"%@", self.tabBar.subviews);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    self.moreBtn.hidden = change[@"new"];
}


#pragma mark - add subview controllers
-(void)installViewController{
    QYHomeViewController *homeVC = [[QYHomeViewController alloc] init];
    UINavigationController *homeNVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    QYMessageViewController *messageVC = [[QYMessageViewController alloc] init];
    UINavigationController *messageNVC = [[UINavigationController alloc] initWithRootViewController:messageVC];
    UIViewController *tempVC = [[UIViewController alloc] init];
    QYFindViewController *findVC = [[QYFindViewController alloc] init];
    UINavigationController *findNVC = [[UINavigationController alloc] initWithRootViewController:findVC];
    
    QYMeViewController *meVC = [[QYMeViewController alloc] init];
    UINavigationController *meNVC = [[UINavigationController alloc] initWithRootViewController:meVC];
    
    self.viewControllers = @[homeNVC, messageNVC, tempVC, findNVC, meNVC];
    self.tabBar.tintColor = [UIColor orangeColor];
}

#pragma mark - add addition button
- (UIButton *)moreBtn
{
    UIButton *moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50,40)];
    moreBtn.backgroundColor = [UIColor orangeColor];
    moreBtn.tag = 1000;
    [moreBtn setImage:[UIImage imageNamed:@"tabbar_compose_icon_add"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"tabbar_compose_icon_add"] forState:UIControlStateHighlighted];
    moreBtn.center = CGPointMake(self.tabBar.center.x, self.tabBar.frame.size.height/2);
    [moreBtn addTarget:self action:@selector(modalAnotherView) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    return moreBtn;
}

- (void)hidenMoreBtn:(NSNotification *)object
{
    self.moreBtn.hidden = object;
}

#pragma mark - action
- (void)modalAnotherView
{
    QYMoreViewController *moreVc = [[QYMoreViewController alloc]init];
    [self presentViewController:moreVc animated:YES completion:^{
        
    }];
}

- (void)setSelectedIndex
{
    [super viewWillAppear:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.selectedIndex = [defaults integerForKey:kLastSelectedIndex];
}

//- (void)dealloc
//{
//    [self removeObserver:self forKeyPath:@"isHiden" context:nil];
//}

@end
