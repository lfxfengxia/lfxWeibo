//
//  QYString+Size.m
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYStringSize.h"

@implementation QYStringSize

+ (CGSize)calculateStringSizeWithString:(NSString *)string font:(UIFont *)font inSize:(CGSize)size
{
    NSMutableParagraphStyle *paragraphy = [[NSMutableParagraphStyle alloc]init];
    paragraphy.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attribute = @{
                                NSFontAttributeName:font,
                                NSParagraphStyleAttributeName:paragraphy
                                };
    CGSize attributeSize = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    return attributeSize;
}

@end
