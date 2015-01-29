//
//  QYSinaDatabase.m
//  QYWeiBo
//
//  Created by qingyun on 14/12/15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTweetDatabase.h"
#import "Model.h"
#import "FMDB.h"
#import "QYTweet.h"
#import "QYUser.h"
#import "QYComment.h"

#define kSourceDataFilePath     @"TwitterData.sqlite"

#define kTweetTableName         @"tweet"
#define kTweetDataName          @"tweetdata"
#define kUserTableName          @"user"
#define kCommentTable           @"comment"
#define kCommentDataTable       @"commentdata"

static NSArray *tweetTableColumns;
static NSArray *tweetDataTableColumns;
static NSArray *userTableColumns;
static NSArray *commentTableColumns;
static NSArray *commentDataTableColumns;

@implementation QYTweetDatabase

/**
 *  初始化,拷贝mainBundle下的数据库文件到document目录下，并获取tweet,tweetData,user表的所有列名
 */
+(void)initialize
{
    if (self == [QYTweetDatabase class]) {
        //拷贝
        [QYTweetDatabase copyFile2DocumentDirectory];
        //获取三个表的列名
        tweetTableColumns = [QYTweetDatabase tableColumnsNameFromTable:kTweetTableName];
        tweetDataTableColumns = [QYTweetDatabase tableColumnsNameFromTable:kTweetDataName];
        userTableColumns = [QYTweetDatabase tableColumnsNameFromTable:kUserTableName];
        commentTableColumns = [QYTweetDatabase tableColumnsNameFromTable:kCommentTable];
        commentDataTableColumns = [QYTweetDatabase tableColumnsNameFromTable:kCommentDataTable];
    }
}
/**
 *  使用FMDB拷贝mainBundle文件到document路径下
 */
+ (void)copyFile2DocumentDirectory
{
    NSString *desPath = [QYTweetDatabase databasePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:desPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:kSourceDataFilePath ofType:nil];
        [fileManager copyItemAtPath:sourcePath toPath:desPath error:nil];
    }
}
/**
 *  获取数据库文件TwitterData.sqlite路径
 */
+ (NSString *)databasePath
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [docPath stringByAppendingPathComponent:kSourceDataFilePath];
}
/**
 *  获取表中得所有列名
 */
+ (NSArray *)tableColumnsNameFromTable:(NSString *)tableName
{
    NSMutableArray *columnsName = [NSMutableArray array];
    FMDatabase *database = [FMDatabase databaseWithPath:[QYTweetDatabase databasePath]];
    [database open];
    FMResultSet *result = [database getTableSchema:tableName];
    while ([result next]) {
        //获取表的所有列名
        NSString *columnName = [[result stringForColumn:@"name"] lowercaseString];
        [columnsName addObject:columnName];
    }
    [result close];
    [database close];
    return columnsName;
}
#pragma mark - 保存微博数据到数据库
/**
 *  保存微博数据到数据库
 *
 *  @param tweets 获取到的多组微博数据
 */
+ (void)saveTweetDataWithArray:(NSArray *)tweets
{
    //获取文件路径
    NSString *databasePath = [QYTweetDatabase databasePath];
    //创建队列，防止数据在保存时阻碍主线程（UI界面）
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    //在队列中串行完成三个表数据的保存
    [queue inDatabase:^(FMDatabase *db) {
        for (NSDictionary *tweet in tweets) {
            NSMutableDictionary *tweetInfo = [NSMutableDictionary dictionary];
            NSString *sourceTweetID = tweet[kID];
            [tweetInfo setObject:sourceTweetID forKey:kID];
            NSDictionary *transTweet = tweet[kRetweetStatus];
            if (transTweet) {
                NSString *transTweetID = transTweet[kID];
                [tweetInfo setObject:transTweetID forKey:kRetweetID];
            }
            //插入tweet
            [QYTweetDatabase insertIntotableTweetWithDictionary:tweetInfo atDataBase:db];
            //插入tweetdata
            [QYTweetDatabase insertIntoTableTweetdataWithDicitonary:tweet atDatabase:db];
            if (transTweet) {
                [QYTweetDatabase insertIntoTableTweetdataWithDicitonary:transTweet atDatabase:db];
            }
            //插入user
            [QYTweetDatabase insertIntoTableUserWithDicitonary:tweet[kUser] atDatabase:db];
            if (transTweet) {
                [QYTweetDatabase insertIntoTableUserWithDicitonary:transTweet[kUser] atDatabase:db];
            }
        }
     }];
}
/**
 *  插入tweet
 */
+ (void)insertIntotableTweetWithDictionary:(NSDictionary *)tweetInfo atDataBase:(FMDatabase *)database
{
    //编写sql语句
    NSString *sqlString = [QYTweetDatabase sqlString4InsertTable:kTweetTableName withKeys:tweetInfo.allKeys];
    //数据库更新
    [database executeUpdate:sqlString withParameterDictionary:tweetInfo];
}
/**
 *  插入tweetdata
 */
+ (void)insertIntoTableTweetdataWithDicitonary:(NSDictionary *)tweetdataInfo atDatabase:(FMDatabase *)database
{
    //从网络请求的数据字典的key中筛选对应表中包含的key
    NSMutableDictionary *tweetUsefulDic = [QYTweetDatabase dictionaryWithUserfulKeysFromDictionary:tweetdataInfo accordingToTable:tweetDataTableColumns];
    //将图片数组组合成字符串,若无图片将该键删除
    NSArray *images =  tweetdataInfo[kPicURLs];
    if (images.count) {
        NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:images.count];
        for (NSDictionary *dic in images) {
            //[imageUrls addObject:dic.allValues];
            NSString *imageUrl = dic[kThumbnailPic];
            [imageUrls addObject:imageUrl];
        }
        NSString *imagesString = [imageUrls componentsJoinedByString:@","];
        [tweetUsefulDic setObject:imagesString forKey:kPicURLs];
    }else{
        [tweetUsefulDic removeObjectForKey:kPicURLs];
    }
    //编写sql语句
    NSString *sqlString = [QYTweetDatabase sqlString4InsertTable:kTweetDataName withKeys:tweetUsefulDic.allKeys];
    //将tweetdata的user的key改为id
    NSDictionary *tweetData = tweetUsefulDic[kUser];
    [tweetUsefulDic setValue:tweetData[kID] forKey:kUser];
    //数据库更新
    [database executeUpdate:sqlString withParameterDictionary:tweetUsefulDic];
}
/**
 *  插入
 */
+ (void)insertIntoTableUserWithDicitonary:(NSDictionary *)userInfo atDatabase:(FMDatabase *)database
{
    //从网络请求的数据字典的key中筛选对应表中包含的key
    NSDictionary *userUsefulDic = [QYTweetDatabase dictionaryWithUserfulKeysFromDictionary:userInfo accordingToTable:userTableColumns];
    //编写sql语句
    NSString *sqlString = [QYTweetDatabase sqlString4InsertTable:kUserTableName withKeys:userUsefulDic.allKeys];
    //数据库更新
    [database executeUpdate:sqlString withParameterDictionary:userUsefulDic];
}

#pragma mark - 保存评论数据到数据库
+ (void)saveCommentDataWithArray:(NSArray *)comments andTweetID:(id)tweetID
{
    //获取数据库路径
    NSString *databasePath = [QYTweetDatabase databasePath];
    //创建线程
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    [queue inDatabase:^(FMDatabase *db) {
        for (NSDictionary *comment in comments) {
            //模拟外键（设置id键值为source comment的id,设置replay_comment的键值为对reply comment的id）
            NSMutableDictionary *usefulComments = [NSMutableDictionary dictionary];
            NSString *sourceCommentID = comment[kID];
            [usefulComments setObject:sourceCommentID forKey:kID];
            NSDictionary *replyComment = comment[kReplyComment];
            if (replyComment) {
                [usefulComments setObject:replyComment[kID] forKey:kReplyComment];
            }
            [usefulComments setObject:tweetID forKey:kTweetID];
            //插入comment
            [QYTweetDatabase insertIntoCommentWithDictionary:usefulComments atDatabase:db];
            //插入commentdata
            [QYTweetDatabase insertIntoCommentdataWithDictionary:comment atDatabase:db];
            if (replyComment) {
                [QYTweetDatabase insertIntoCommentdataWithDictionary:replyComment atDatabase:db];
            }
            NSDictionary *user = comment[kUser];
            [QYTweetDatabase insertIntoTableUserWithDicitonary:user atDatabase:db];
        }
    }];
}

+ (void)insertIntoCommentWithDictionary:(NSDictionary *)commentInfo atDatabase:(FMDatabase *)db
{
    
    //格式化SQL语句
    NSString *sqlString = [QYTweetDatabase sqlString4InsertTable:kCommentTable withKeys:commentInfo.allKeys];
    //执行SQL语句
    [db executeUpdate:sqlString withParameterDictionary:commentInfo];
}

+ (void)insertIntoCommentdataWithDictionary:(NSDictionary *)commentsData atDatabase:(FMDatabase *)db
{
    //获取有效的keys
    NSMutableDictionary *usefulDictionary = [QYTweetDatabase dictionaryWithUserfulKeysFromDictionary:commentsData accordingToTable:commentDataTableColumns];
    NSString *sqlString = [QYTweetDatabase sqlString4InsertTable:kCommentDataTable withKeys:usefulDictionary.allKeys];
    NSDictionary *user = usefulDictionary[kUser];
    [usefulDictionary setObject:user[kID] forKey:kUser];
    NSDictionary *tweet = usefulDictionary[kStatus];
    if (tweet) {
        [usefulDictionary setObject:tweet[kID] forKey:kStatus];
    }
    [db executeUpdate:sqlString withParameterDictionary:usefulDictionary];
}
#pragma mark - function
/**
 *  sql语句编写
 */
+ (NSString *)sqlString4InsertTable:(NSString *)tableName withKeys:(NSArray *)keys
{
    //sql格式 @"insert into table (key1,key2) values (:value1, :value2)";
    NSString *sqlString;
    //获取字典中键,并加以组合
    NSString *allKeys = [keys componentsJoinedByString:@", "];
    //获取字典中的值,并加以组合
    NSString *allValues = [keys componentsJoinedByString:@", :"];
    allValues = [@":" stringByAppendingString:allValues];
    //格式化sql语句
    sqlString = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",tableName,allKeys,allValues];
    return sqlString;
}
/**
 * 从网络请求的数据字典的key中筛选对应表中包含的key筛选网络请求的字典的keys
 */
+ (NSMutableDictionary *)dictionaryWithUserfulKeysFromDictionary:(NSDictionary *)networkInfo accordingToTable:(NSArray *)tableColumns
{
    NSMutableArray *allkeys = [NSMutableArray array];
    [allkeys addObjectsFromArray:networkInfo.allKeys];
    NSMutableDictionary *usefulDictonary = [NSMutableDictionary dictionary];
    for (NSString *key in allkeys) {
        if ([tableColumns containsObject:key]) {
            [usefulDictonary setObject:networkInfo[key] forKey:key];
        }
    }
    return usefulDictonary;
}
#pragma mark - 查询本地微博数据
/**
 *  查询本地微博数据
 */
+(NSArray *)selectTweetsFromLocal
{
    //打开数据库
    FMDatabase *db = [FMDatabase databaseWithPath:[QYTweetDatabase databasePath]];
    [db open];
    //格式化sql语句,完成从本地一次加载最新的20条微博记录
    NSString *sqlString = @"SELECT * FROM tweet ORDER BY id DESC LIMIT 20";
    //遍历查询结果并保存模型
    FMResultSet *set = [db executeQuery:sqlString];
    NSMutableArray *tweets = [NSMutableArray array];
    while ([set next]) {
        id tweetID = [set objectForColumnName:kID];
        QYTweet *tweet = [QYTweetDatabase selectTweetByTweetID:tweetID inDB:db];
        if (tweet) {
            [tweets addObject:tweet];
        }
    }
    [set close];
    //关闭数据库
    [db close];
    return tweets;
}
//返回某一台微博的信息
+ (QYTweet *)selectTweetByTweetID:(id)tweetID inDB:(FMDatabase *)db
{
    NSString *sqlString = @"SELECT * FROM tweet WHERE id = ?";
    FMResultSet *result = [db executeQuery:sqlString,tweetID];
    QYTweet *tweet;
    if ([result next]) {
        tweet = [[QYTweet alloc]init];
        tweet.tweetData = [QYTweetDatabase selectTweetDataByID:tweetID inDB:db];
        id retweetID = [result objectForColumnName:kRetweetID];
        if (retweetID) {
            tweet.retweetData = [QYTweetDatabase selectTweetDataByID:retweetID inDB:db];
        }
    }
    return tweet;
}

+ (QYTweetData *)selectTweetDataByID:(id)tweetID inDB:(FMDatabase *)db
{
    NSString *sqlString = @"SELECT * FROM tweetdata WHERE id = ?";
    FMResultSet *set = [db executeQuery:sqlString,tweetID];
    QYTweetData *tweetdata;
    if ([set next]) {
        tweetdata = [[QYTweetData alloc]init];
        id userID = [set objectForColumnName:kUser];
        tweetdata.user = [QYTweetDatabase selectUserIndoByID:userID inDB:db];
        
        NSString *dateStr = [set objectForColumnName:kCreateAt];
        NSString *dateFormater = @"EEE MMM dd HH:mm:ss zzz yyyy";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:dateFormater];
        tweetdata.createAt = [formatter dateFromString:dateStr];
        tweetdata.tweetID = [set stringForColumn:kID];
        tweetdata.text = [set stringForColumn:kText];
        NSString *sourceStr = [set stringForColumn:kSource];
        tweetdata.source = [tweetdata getSourceFromString:sourceStr];
        tweetdata.favorited = [set boolForColumn:kFavorited];
        tweetdata.repostsCount = [set intForColumn:kRepostsCount];
        tweetdata.commentsCount = [set intForColumn:kCommentsCount];
        tweetdata.attitudesCount =[set intForColumn:kCommentsCount];
        
        NSString *imageUrls = [set stringForColumn:kPicURLs];
        if (imageUrls && imageUrls.length != 0) {
            tweetdata.picURLs = [imageUrls componentsSeparatedByString:@","];
        }
    }
    [set close];
    return tweetdata;
}

+ (QYUser *)selectUserIndoByID:(id)userID inDB:(FMDatabase *)db
{
    NSString *sqlString = @"SELECT * FROM user WHERE id = %@";
    FMResultSet *set = [db executeQueryWithFormat:sqlString,userID];
    QYUser *user;
    if ([set next]) {
        user = [[QYUser alloc]init];
        user.userID = [userID integerValue];
        user.name = [set stringForColumn:kName];
        user.province = [set intForColumn:kProvince];
        user.followersCount = [set intForColumn:kFollowersCount];
        user.statusesCount = [set intForColumn:kStatusesCount];
        user.friendsCount = [set intForColumn:kFriendsCount];
        user.favouritesCount = [set intForColumn:kFavouritesCount];
        user.followMe = [set boolForColumn:kFollowMe];
        user.onlineStatus = [set intForColumn:kOnlinStatus];
        user.biFollowersCount = [set intForColumn:kBiFollowersCount];
        user.location = [set stringForColumn:kLocation];
        user.descriptions = [set stringForColumn:kDescriptions];
        user.blogURL = [set stringForColumn:kBlogURL];
        user.domain = [set stringForColumn:kDomain];
        user.weihao = [set stringForColumn:kWeihao];
        user.gender = [set stringForColumn:kGender];
        user.registerDate = [set objectForColumnName:kCreatedAt];
        user.remark = [set stringForColumn:KRemark];
        user.avatarHd = [set stringForColumn:kAvatarHd];
        user.lang = [set stringForColumn:kLang];
    }
    return user;
}

#pragma mark - 查询本地评论数据
+ (NSArray *)selectCommentsFromLocalByTweetID:(id)tweetID
{
    //打开数据库
    NSString *dbPath = [QYTweetDatabase databasePath];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    //格式化SQL语句
    NSString *sqlString = @"SELECT * FROM comment  WHERE tweet_id = ? ORDER BY id DESC LIMIT 20";
    //执行语句
    FMResultSet *result = [database executeQuery:sqlString,tweetID];
    QYComment *comment;
    NSMutableArray *commentsArray = [NSMutableArray array];
    while ([result next]) {
        comment = [[QYComment alloc]init];
        id sourCommentID = [result objectForColumnName:kID];
        comment.sourComment = [QYTweetDatabase selectCommentDataByCommentID:sourCommentID inDB:database];
        id replayCommentID = [result objectForColumnName:kReplyComment];
        if (replayCommentID) {
            comment.repalyComment = [QYTweetDatabase selectCommentDataByCommentID:replayCommentID inDB:database];
        }
        comment.tweet = [QYTweetDatabase selectTweetByTweetID:tweetID inDB:database];
        if (comment) {
            [commentsArray addObject:comment];
        }
    }
    [result close];
    [database close];
    return commentsArray;
}

+ (QYCommentData *)selectCommentDataByCommentID:(id)commentID inDB:(FMDatabase *)db
{
    NSString *sqlString = @"SELECT * FROM commentdata WHERE id = ?";
    FMResultSet *result = [db executeQuery:sqlString,commentID];
    QYCommentData *commentData;
    if ([result next]) {
        commentData = [[QYCommentData alloc]init];
        NSInteger commentID = [result intForColumn:kID];
        commentData.commentID = commentID;          
        id tweetID = [result objectForColumnName:kStatus];
        commentData.tweet = [QYTweetDatabase selectTweetByTweetID:tweetID inDB:db];
        NSString *dateStr = [result stringForColumn:kCreateAt];
        NSString *dateFormatterStr = @"EEE MMM dd HH:mm:ss zzz yyyy";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:dateFormatterStr];
        commentData.createAt = [dateFormatter dateFromString:dateStr];
        NSString *sourceString = [result stringForColumn:kSource];
        commentData.source = [[[QYTweetData alloc]init] getSourceFromString:sourceString];
        commentData.text = [result stringForColumn:kText];
        id userID = [result objectForColumnName:kUser];
        commentData.user = [QYTweetDatabase selectUserIndoByID:userID inDB:db];
    }
    return commentData;
}

@end
