//
//  QYSenderWordTweet.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/29.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYSenderTweet.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYLoginUserInfo.h"
#import "QYTweet.h"
#import "QYUser.h"
#import "Common.h"
#import "QYAcountInfo.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"

#define kImagesHeightAndWidth               60
#define kImageMargin                        5

@interface QYSenderTweet () <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic,strong) UILabel *placeHolder;
@property (nonatomic,strong) UITableViewCell *cell;
@property (nonatomic,strong) UIView *pictureBottomView;

@property (nonatomic,strong) NSString *accessToken;

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *content;


@end

@implementation QYSenderTweet

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        self.accessToken = [[QYAcountInfo shareAcountInfo] accessToken];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNavigationItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHiden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setupTextView];
    self.textView.delegate = self;
    [self setPlaceHolder];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSInteger usefulImagesCount = 0;
    usefulImagesCount = self.uploadImages.count;
    if (self.uploadImages.count > 9) {
        usefulImagesCount = 9;
    }
    [self pictureBottomViewHieghtAccordingToNumberOsImages:usefulImagesCount];
    if (self.uploadImages.count) {
        [self layoutUploadImagesByImages:self.uploadImages addToView:self.pictureBottomView];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - set navigation items
- (void)setNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendTweet)];
    [self setupTitleView];
}

- (void)setupTitleView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, 100, 20)];
    label.text = [[QYLoginUserInfo defaultLoginUser] getUserInfo].name;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    UILabel *staticLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 100, 20)];

    if (self.sendType == kComment) {
            staticLabel.text = @"发评论";
    }
    if (self.sendType == kRepost) {
        staticLabel.text = @"转发微博";
    }
    if (self.sendType == kWrite) {
        staticLabel.text = @"发微博";
    }
    
    staticLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:staticLabel];
    [view addSubview:label];
    self.navigationItem.titleView = view;
}

#pragma mark - set subviews
- (void)setupTextView
{
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(8, 0, kWidth - 16, kHeight - 300)];
    self.textView.delegate = self;
    [self.cell addSubview:self.textView];
}

- (void)setPlaceHolder
{
    self.placeHolder = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    if (self.sendType == kComment) {
        self.placeHolder.text = @"写评论......";
    }
    if (self.sendType == kRepost) {
        self.placeHolder.text = @"转发微博......";
    }
    if (self.sendType == kWrite) {
        self.placeHolder.text = @"分享新鲜事......";
    }
    self.placeHolder.adjustsFontSizeToFitWidth = YES;
    self.placeHolder.textColor = [UIColor grayColor];
    [self.textView addSubview:self.placeHolder];
}

- (void)pictureBottomViewHieghtAccordingToNumberOsImages:(NSInteger)numberOfImages
{
    if (self.sendType == kWrite) {
        NSInteger columns = (kWidth - 16) / (kImagesHeightAndWidth + kImageMargin);
        NSInteger rows = ceil((numberOfImages + 1) / (float)columns);
        CGFloat bottomHeight = rows * kImagesHeightAndWidth + (rows - 1) * kImageMargin;
        if (numberOfImages == 0) {
            bottomHeight = 0;
        }
        if (numberOfImages == 9) {
            bottomHeight = (9 / columns) * kImagesHeightAndWidth + (rows - 1) * kImageMargin;;
        }
        self.pictureBottomView = [[UIView alloc]initWithFrame:CGRectMake(8, 280, kWidth - 16,bottomHeight)];
        self.pictureBottomView.backgroundColor = [UIColor colorWithRed:247.0 green:247.0 blue:247.0 alpha:1];
        if (self.uploadImages.count == 0 && self.pictureBottomView) {
            [self.pictureBottomView removeFromSuperview];
        }else{
            [self.view addSubview:self.pictureBottomView];
        }
    }
    if (self.sendType == kRepost) {
        self.pictureBottomView = [[NSBundle mainBundle] loadNibNamed:@"QYRepostTwitterView" owner:self options:nil][0];
        self.pictureBottomView.frame = CGRectMake(0, 280, kWidth - 16, 70);
        self.pictureBottomView.backgroundColor = [UIColor colorWithRed:247.0 green:247.0 blue:247.0 alpha:1];
        [self.icon sd_setImageWithURL:[NSURL URLWithString:self.tweet.tweetData.user.avatarHd]];
        self.name.text = [NSString stringWithFormat:@"@%@",self.tweet.tweetData.user.name];
        self.content.text = self.tweet.tweetData.text;
        [self.textView addSubview:self.pictureBottomView];
    }
    if (self.sendType == kComment) {
        if (self.pictureBottomView) {
            [self.pictureBottomView removeFromSuperview];
        }
    }
}

#pragma mark - text view delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeHolder.hidden = YES;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        self.placeHolder.hidden = NO;
    }
    return YES;
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.textView.bounds.size.height;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([self.textView isFirstResponder])
    {
        [self.textView resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark - action
- (void)keyboardWillShow:(NSNotification *)sender
{
    NSDictionary *userInfo = sender.userInfo;
    CGRect frame  = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.textView.frame = CGRectMake(8, 0, kWidth - 16, kHeight - frame.size.height - 30);
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)keyboardWillHiden:(NSNotification *)sender
{
    self.textView.frame = CGRectMake(8, 0, kWidth, kHeight - 300);
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark send twitter
- (void)sendTweet
{
    if (self.sendType == kRepost) {
        [self repostTwitter];
    }
    if (self.sendType == kComment) {
        [self commentTwitter];
    }
    if (self.sendType == kWrite) {
        [self writeTwitter];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)repostTwitter
{
    [SVProgressHUD showErrorWithStatus:@"转发中..."];
    NSString *repostUrlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/repost.json"];
    NSDictionary *repsParamters = @{
                                    kAccessToken:self.accessToken,
                                    @"id":self.tweet.tweetData.tweetID,
                                    @"status":self.textView.text,
                                    @"is_comment":@1
                                    };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:repostUrlStr parameters:repsParamters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"response object : %@",responseObject);
        //[self promptAfterSendWithText:@"转发成功"];
        [SVProgressHUD showSuccessWithStatus:@"转发成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@",error);
        //[self promptAfterSendWithText:@"转发失败"];
        [SVProgressHUD showErrorWithStatus:@"转发失败"];
    }];
    [SVProgressHUD dismiss];
    [self cancel];
}

- (void)commentTwitter
{
    NSString *urlStr = [kBaseURL stringByAppendingPathComponent:@"comments/create.json"];
    NSDictionary *paramters = @{
                                kAccessToken:self.accessToken,
                                @"id":self.tweet.tweetData.tweetID,
                                @"comment":self.textView.text,
                                @"comment_ori":@1
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlStr parameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object : %@",responseObject);
        [self promptAfterSendWithText:@"发送成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@,responseString :%@",error,operation.responseString);
        [self promptAfterSendWithText:@"发送失败"];
    }];

}

- (void)writeTwitter
{
    [SVProgressHUD showWithStatus:@"上传中..." maskType:SVProgressHUDMaskTypeClear];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.accessToken forKey:kAccessToken];
    if (self.textView.text.length == 0) {
        self.textView.text = @"发微博";
        if (self.uploadImages.count) {
            self.textView.text = @"上传图片";
        }
    }
    [parameters setObject:self.textView.text forKey:@"status"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if (self.uploadImages.count) {
        NSString *pictureUrlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/upload.json"];
        [manager POST:pictureUrlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            int i = 0;
            for (UIImage *image in self.uploadImages) {
                i++;
                NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                [formData appendPartWithFileData:imageData name:@"pic" fileName:[NSString stringWithFormat:@"picture_%d",i] mimeType:@"image/jpeg"];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"respose object :%@",responseObject);
            //[self promptAfterSendWithText:@"上传成功"];
            [SVProgressHUD showSuccessWithStatus:@"上传成功" maskType:SVProgressHUDMaskTypeGradient];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ ",operation.responseString);
            [self promptAfterSendWithText:@"上传失败"];
            [SVProgressHUD showInfoWithStatus:@"上传失败" maskType:SVProgressHUDMaskTypeBlack];
        }];
        [SVProgressHUD dismiss];
        [self cancel];
        
    }else{
        NSString *wordUrlStr = [kBaseURL stringByAppendingPathComponent:@"statuses/update.json"];
        [manager POST:wordUrlStr parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"response oject :%@",responseObject);
                  [self promptAfterSendWithText:@"发送成功"];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"%@",operation.responseObject);
                  [self promptAfterSendWithText:@"发送失败"];
              }];
    }
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)layoutUploadImagesByImages:(NSMutableArray *)images addToView:(UIView *)view
{
    if (self.pictureBottomView.subviews.count) {
        [self.pictureBottomView.subviews makeObjectsPerformSelector:@selector(removeObject:)];
    }
    int i = 0;
    for (; i < images.count; i ++) {
        NSInteger columns = (kWidth - 16)/(kImageMargin + kImagesHeightAndWidth);
        NSInteger column = i % columns;
        NSInteger row = i / columns;
        UIImage *image = images[i];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(column * (kImagesHeightAndWidth + kImageMargin), row * (kImagesHeightAndWidth + kImageMargin), kImagesHeightAndWidth, kImagesHeightAndWidth)];
        imageView.image = image;
        [view addSubview:imageView];
    }
    if (i == images.count && images.count <= 9) {
        [self setupButtonAddToView:view byLastImagesCount:i];
    }
}

- (void)setupButtonAddToView:(UIView *)view byLastImagesCount:(NSInteger)count
{
    NSInteger columns = (kWidth - 16)/(kImageMargin + kImagesHeightAndWidth);
    NSInteger column = count % columns;
    NSInteger row = count / columns;
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(column *(kImagesHeightAndWidth + kImageMargin), row *(kImagesHeightAndWidth + kImageMargin), kImagesHeightAndWidth, kImagesHeightAndWidth)];
    [btn setImage:[UIImage imageNamed:@"compose_pic_add"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"compose_pic_add_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addPictureFromPhoto) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
}

- (void)addPictureFromPhoto
{
    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc]init];
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerVC.delegate = self;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)promptAfterSendWithText:(NSString *)text
{
    UILabel *prompt = [[UILabel alloc]initWithFrame:CGRectMake(110, 150, 100, 40)];
    prompt.text = @"发送中。。。";
    prompt.textColor = [UIColor whiteColor];
    prompt.backgroundColor = [UIColor blackColor];
    prompt.layer.cornerRadius = 10;
    prompt.layer.masksToBounds = YES;
    prompt.alpha = 0;
    [self.view addSubview:prompt];
    [UIView animateWithDuration:1.0 animations:^{
        prompt.alpha = 0.6;
    } completion:^(BOOL finished) {
        prompt.text = text;
        [UIView animateWithDuration:2.0 animations:^{
            prompt.alpha = 0;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } completion:^(BOOL finished) {
            [prompt removeFromSuperview];
            NSString *regx = @"^..*(成功)$";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self MATCHES %@",regx];
            if([predicate evaluateWithObject:text])
            {
                [self cancel];
            }
        }];
    }];
}

#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.uploadImages addObject:image];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
