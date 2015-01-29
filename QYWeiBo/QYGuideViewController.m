//
//  QYGuidViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYGuideViewController.h"
#import "QYViewControllerManager.h"
#import "QYMainViewController.h"
#import "QYAppDelegate.h"

//uiScrollView + 3张图片；
//pageControl;
//跳过；
//进入微博；

#define kWidth          [UIScreen mainScreen].bounds.size.width
#define kHeight         [UIScreen mainScreen].bounds.size.height

@interface QYGuideViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation QYGuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *imageArray = @[@"guide_background", @"guide_c_feed", @"guide_c_video_pause"];
    for (int i = 0; i < imageArray.count; i++) {
        NSString *imageName;
        CGSize size = [[UIScreen mainScreen] currentMode].size;
        if (CGSizeEqualToSize(size, CGSizeMake(640, 960))) {
            imageName = [NSString stringWithFormat:@"%@%@",imageArray[i], @"_960"];
        }else{
            imageName = [NSString stringWithFormat:@"%@%@",imageArray[i], @"_1136"];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectOffset([[UIScreen mainScreen] bounds], kWidth * i, 0)];
        
        [imageView setImage:[UIImage imageNamed:imageName]];
        [self.scrollView addSubview:imageView];
        if (i == 2) {
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"进入微博" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(guideEnd:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(imageView.center.x - 50, kHeight - 100, 100, 50);
            [self.scrollView addSubview:button];
        }

    }
    self.scrollView.contentSize = CGSizeMake(kWidth * 3, kHeight);
    self.scrollView.delegate = self;
    self.pageControl.pageIndicatorTintColor = [UIColor redColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)guideEnd:(id)sender {
    
    [QYViewControllerManager guideEnd];
}

#pragma mark - UIScroll View Deklegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        self.pageControl.currentPage = scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x / self.scrollView.bounds.size.width;
}


@end
