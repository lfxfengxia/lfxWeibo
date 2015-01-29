//
//  QYUserFootView.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/26.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYUserHeaderView.h"

#define kQYUserHeaderView                      @"QYUserHeaderView"

@implementation QYUserHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:kQYUserHeaderView owner:self options:nil][0];
    }
    return self;
}
@end
