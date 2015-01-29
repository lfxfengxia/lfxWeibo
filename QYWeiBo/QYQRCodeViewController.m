//
//  QYQRCodeViewController.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/22.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QYQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;

@property (nonatomic,strong) UIView *qrView;
@property (nonatomic,strong) UIImageView *animationView;
@property (nonatomic,strong) CALayer *animationLayer;

@end

@implementation QYQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.barTintColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:nil];
    [self setupLabel];

    self.qrView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.qrView];
    
}

#pragma mark - add  subviews
- (void)readingQRCode
{
    self.session = [[AVCaptureSession alloc]init];
    NSError *error;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (self.input) {
        [self.session addInput:self.input];
    }else{
        NSLog(@"error :%@",error);
        return;
    }
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.session addOutput:self.output];
    dispatch_queue_t queue = dispatch_queue_create("outQueue", nil);
    [self.output setMetadataObjectsDelegate:self queue:queue];
    NSArray *types = [self.output availableMetadataObjectTypes];
    [self.output setMetadataObjectTypes:types];
    
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    layer.frame = self.view.layer.bounds;
    
    UIGraphicsBeginImageContextWithOptions(self.qrView.frame.size, NO, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.95);
    CGContextAddRect(context, self.qrView.bounds);
    CGContextFillPath(context);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextAddRect(context, CGRectMake(50, 40, 220, 220));
    CGContextFillPath(context);
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *masLayer = [CALayer layer];
    masLayer.bounds = self.qrView.bounds;
    masLayer.position = self.qrView.center;
    masLayer.contents = (__bridge id)maskImage.CGImage;
    layer.mask = masLayer;
    layer.masksToBounds = YES;
    [self.qrView.layer addSublayer:layer];
    [self.session startRunning];
}

- (void)setQRCodeUI
{
    UIImageView *bottomView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 40, 220, 220)];
    UIImage *image = [UIImage imageNamed:@"qrcode_border"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 26, 26)];
    bottomView.image = image;
    bottomView.clipsToBounds = YES;
    [self.qrView addSubview:bottomView];
    
    self.animationView = [[UIImageView alloc]initWithFrame:bottomView.bounds];
    self.animationView.image = [UIImage imageNamed:@"qrcode_scanline_barcode"];
    [bottomView addSubview:self.animationView];
    
    [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(animationQRcode) userInfo:nil repeats:YES];
}

- (void)setupLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 100, 40)];
    label.text = @"二维码";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
}

#pragma mark - view controller delegate

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self readingQRCode];
    [self setQRCodeUI];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjects delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"%@",[[metadataObjects firstObject] stringValue]);
    [self performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:YES];
}

#pragma mark - action
- (void)animationQRcode
{
    CGRect rect = self.animationView.frame;
    CGFloat y = self.animationView.frame.origin.y;
    self.animationView.frame = CGRectOffset(rect, 0, 3);
    if (y > rect.size.height - 100) {
        y = -rect.size.height;
        self.animationView.frame = CGRectMake(0, y, rect.size.width, rect.size.height);
    }
    
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
