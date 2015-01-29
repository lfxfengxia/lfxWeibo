//
//  QYString+Size.h
//  XinXinWeiobo
//
//  Created by qingyun on 14/12/21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYStringSize : NSString

+ (CGSize)calculateStringSizeWithString:(NSString *)string font:(UIFont *)font inSize:(CGSize)size;
@end
