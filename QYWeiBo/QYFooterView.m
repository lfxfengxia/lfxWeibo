//
//  QYFooterView.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/13.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYFooterView.h"

@implementation QYFooterView

- (void)awakeFromNib
{
    self.backgroundView = [[UIView alloc]init];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
}
@end
