//
//  QYUser.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYUser.h"
#import "Model.h"


@implementation QYUser

- (instancetype)initUserWithDictionary:(NSDictionary *)userInfo
{
    if (self = [super init]) {
        self.userID = [userInfo[kID] integerValue];
        self.name = userInfo[kName];
        self.province = [userInfo[kProvince] integerValue];
        self.followersCount = [userInfo[kFollowersCount] integerValue];
        self.friendsCount = [userInfo[kFriendsCount] integerValue];
        self.statusesCount = [userInfo[kStatusesCount] integerValue];
        self.favouritesCount = [userInfo[kFavouritesCount] integerValue];
        self.followMe = [userInfo[kFollowMe] boolValue];
        self.onlineStatus = [userInfo[kOnlinStatus] integerValue];
        self.biFollowersCount = [userInfo[kBiFollowersCount] integerValue];
        self.location = userInfo[kLocation];
        self.descriptions = userInfo[kDescriptions];
        self.blogURL = userInfo[kBlogURL];
        self.domain = userInfo[kDomain];
        self.weihao = userInfo[kWeihao];
        self.gender = userInfo[kGender];
        self.registerDate = userInfo[kCreatedAt];
        self.remark = userInfo[KRemark];
        self.avatarHd = userInfo[kAvatarHd];
        self.lang = userInfo[kLang];
    }
    return self;
}

@end
