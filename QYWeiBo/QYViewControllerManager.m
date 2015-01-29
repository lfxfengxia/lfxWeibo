//
//  QYViewControllerManager.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYViewControllerManager.h"
#import "QYGuideViewController.h"
#import "QYMainViewController.h"
#import "Common.h"
#import "QYAppDelegate.h"

//第一次打开用标示
static BOOL FirstLaunch = NO;

@implementation QYViewControllerManager

+(void)initialize{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL notFirstLaunch = [defaults boolForKey:kNotFirstLaunch];
    FirstLaunch = !notFirstLaunch;
    
}

+(id)getRootViewController{
    if (FirstLaunch) {
        QYGuideViewController *guideViewController = [[QYGuideViewController alloc]init];
        return guideViewController;
    }else{
        QYMainViewController *mainViewController = [[QYMainViewController alloc] init];
        return mainViewController;
    }
}

+(void)guideEnd{
    QYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    QYMainViewController *mainViewController = [[QYMainViewController alloc] init];
    appDelegate.window.rootViewController = mainViewController;
    mainViewController.selectedIndex = 3;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kNotFirstLaunch];
    [defaults synchronize];
    
}

@end
