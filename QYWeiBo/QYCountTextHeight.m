//
//  QYCountTextHeight.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/12.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYCountTextHeight.h"

static UILabel *label;

@implementation QYCountTextHeight

+ (void)initialize
{
    if (self == [QYCountTextHeight class]) {
        label = [[UILabel alloc]init];
        CGFloat defaultWidth = [UIScreen mainScreen].bounds.size.width - 16;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:defaultWidth];
        [label addConstraint:constraint];
    }
}

+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font andTextWidth:(CGFloat)width
{
    if (font == nil) {
        font = [UIFont systemFontOfSize:16];
    }
    label.font = font;
    NSArray *constraints = [NSArray array];
    //NSArray *constraints = nil;
    if (width != 0 && label.bounds.size.width != width) {
        constraints = label.constraints;
        [label removeConstraints:constraints];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width];
        [label addConstraint:constraint];
    }
    
    label.text = text;
    CGSize size = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    if (constraints) {
        [label removeConstraints:constraints];
    }
    return size.height;
}

@end
