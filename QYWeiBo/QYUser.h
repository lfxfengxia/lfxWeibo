//
//  QYUser.h
//  QYWeiBo
//
//  Created by qingyun on 14/12/15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYUser : NSObject

@property (nonatomic) NSInteger userID;
@property (nonatomic,strong) NSString *name;
@property (nonatomic) NSInteger province;
@property (nonatomic) NSInteger city;
@property (nonatomic) NSInteger followersCount;
@property (nonatomic) NSInteger friendsCount;
@property (nonatomic) NSInteger statusesCount;
@property (nonatomic) NSInteger favouritesCount;
@property (nonatomic) BOOL followMe;
@property (nonatomic) NSInteger onlineStatus;
@property (nonatomic) NSInteger biFollowersCount;

@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *descriptions;
@property (nonatomic,strong) NSString *blogURL;
@property (nonatomic,strong) NSString *domain;
@property (nonatomic,strong) NSString *weihao;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSDate *registerDate;
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,strong) NSString *avatarHd;
@property (nonatomic,strong) NSString *lang;


- (instancetype)initUserWithDictionary:(NSDictionary *)userInfo;

@end
