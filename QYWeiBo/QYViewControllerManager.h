//
//  QYViewControllerManager.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//


//管理标示位
//1.第一次打开应用，引导页面
//2.引导结束切换根控制器
//3.非第一次打开，tabbarController


#import <Foundation/Foundation.h>

@interface QYViewControllerManager : NSObject

//返回打开应用的根控制器
+(id)getRootViewController;

//引导结束，切换根控制器
+(void)guideEnd;

@end
