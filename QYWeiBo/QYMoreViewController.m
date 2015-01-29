//
//  QYMoreViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYMoreViewController.h"
#import "QYMoreFunctionViewController.h"
#import "QYSenderTweet.h"
#import "Common.h"

@interface QYMoreViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *allBtns;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allLabels;


@end

@implementation QYMoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view = [[NSBundle mainBundle] loadNibNamed:@"QYMoreViewController" owner:self options:nil][0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self allViewsAppearAnimatingWithArray:self.allBtns];
    [self allViewsAppearAnimatingWithArray:self.allLabels];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self allViewsDisappearWithArray:self.allBtns];
    [self allViewsDisappearWithArray:self.allLabels];
}

#pragma mark - all buttons animation 
//视图出现时的动画
- (void)allViewsAppearAnimatingWithArray:(NSArray *)views
{
    int i = 0;
    self.bottomView.hidden = YES;
    for (UIView *subview in views) {
        i += 0.5;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGRect frame = subview.frame;
            subview.frame = CGRectOffset(frame, 0, self.bottomView.frame.size.height - frame.origin.y);
            [UIView animateWithDuration:0.3 animations:^{
                self.bottomView.hidden = NO;
                subview.frame = CGRectOffset(frame, 0, -20);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.1 animations:^{
                    subview.frame = frame;
                }];
            }];
        });
    }
}

//视图消失时的动画
- (void)allViewsDisappearWithArray:(NSArray *)views
{
    int i = 0;
    for (UIView *subview in views) {
        i += 0.5;
        CGRect frame = subview.frame;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                subview.frame = CGRectOffset(frame, 0, self.bottomView.frame.size.height - 20);
            } completion:^(BOOL finished) {
                subview.frame = CGRectOffset(frame, 0, self.bottomView.frame.size.height);
            }];
        });
    }
    
}

#pragma mark - button action
- (IBAction)sendWordTweet {
    QYSenderTweet *senderVC = [[QYSenderTweet alloc]init];
    UINavigationController *senderNVC = [[UINavigationController alloc]initWithRootViewController:senderVC];
    [self showViewController:senderNVC sender:nil];
    senderVC.sendType = kWrite;
}

- (IBAction)sendPictureTweet {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    QYSenderTweet *sendeVC = [[QYSenderTweet alloc]init];
    UINavigationController *sendNVC = [[UINavigationController alloc]initWithRootViewController:sendeVC];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:sendNVC animated:YES completion:nil];
    sendeVC.uploadImages = [NSMutableArray array];
    [sendeVC.uploadImages  addObject:image];
    sendeVC.sendType = kWrite;
}

#pragma mark - gesture action
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [UIView animateWithDuration:0.4 animations:^{
//        self.bottomView.frame = CGRectMake(0, kHeight, kWidth, self.bottomView.bounds.size.height);
//    }completion:^(BOOL finished) {
//        [self dismiss:nil];
//    }];
    [self dismiss:nil];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)moreFunction:(id)sender {
    QYMoreFunctionViewController *funcVC = [[QYMoreFunctionViewController alloc]init];
    [self presentViewController:funcVC animated:YES completion:nil];
}

@end
