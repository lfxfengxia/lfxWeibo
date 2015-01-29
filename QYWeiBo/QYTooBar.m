//
//  QYTooBar.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/28.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTooBar.h"

@implementation QYTooBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"QYTooBar" owner:self options:nil][0];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
