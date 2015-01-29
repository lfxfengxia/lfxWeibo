//
//  QYMoreFunctionViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/10.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYMoreFunctionViewController.h"
#import "QYAppDelegate.h"
#import "QYMainViewController.h"

#define kWidth          [UIScreen mainScreen].bounds.size.width
#define kHeight         [UIScreen mainScreen].bounds.size.height

@interface QYMoreFunctionViewController ()
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation QYMoreFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark geture action
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.4 animations:^{
        self.bottomView.frame = CGRectMake(0, kHeight, kWidth, self.bottomView.bounds.size.height);
    }completion:^(BOOL finished) {
        [self returnMain:nil];
    }];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)returnMain:(id)sender {
    QYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    QYMainViewController *mainVC = (QYMainViewController *)appDelegate.window.rootViewController;
    [mainVC dismissViewControllerAnimated:NO completion:^{
        mainVC.selectedIndex = 0;
    }];
}

@end
