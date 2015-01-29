//
//  QYTabar.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/26.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTabar.h"

@implementation QYTabar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    if (self = [super init]) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _btn.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _btn.center = self.center;
    [self addSubview:_btn];
    
}

@end
