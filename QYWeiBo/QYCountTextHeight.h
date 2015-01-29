//
//  QYCountTextHeight.h
//  QYWeiBo
//
//  Created by qingyun on 14/12/12.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYCountTextHeight : NSObject

+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font andTextWidth:(CGFloat)width;

@end
