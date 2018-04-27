
//
//  MCDownloadDBManager.m
//  MCDownLoader
//
//  Created by k12 on 2018/4/27.
//  Copyright © 2018年 k12. All rights reserved.
//

#import "MCDownloadDBManager.h"
#import "MCDownloadItem.h"
#import <FMDB.h>

//***********************************************
#ifdef DEBUG
#define LSLog(...) NSLog(__VA_ARGS__)
#else
#define LSLog(...)
#endif

#pragma mark ---- db  table
NSString * const MCDownloadItemTable      = @"kDownloadItemTable";
@interface MCDownloadDBManager()
/// 加载数据库中  完成的任务      --> kDownloadCompleteTable

@property (assign, nonatomic, getter=isUpdateCourseType) BOOL updateCourseType;

#pragma mark -- 保存数据库的字段名(和Item字段一样), 初始化时创建.  不想使用static的字符串
/// 文件唯一标识Id, MCSectionModel 的 Id (sectionId)
@property (copy,   nonatomic, readonly) NSString *videoId;
/// 该视频在第几章, MCChapterModel 的 Id (sectionId) == section.chapterID, 实战课程使用
@property (copy,   nonatomic, readonly) NSString *chapterId;
/// 下载地址
@property (copy,   nonatomic, readonly) NSString *url;
/// 下载状态
@property (copy,   nonatomic, readonly) NSString *state;
/// 文件已经下载的大小
@property (copy,   nonatomic, readonly) NSString *totalBytesWritten;
/// 总共写入的字节数
@property (copy,   nonatomic, readonly) NSString *fileSize;
/// m3u8 下载第 currentTs 个到 ts
@property (assign, nonatomic, readonly) NSString *currentTs;
/// m3u8 共有 totalTs 个到 ts
@property (assign, nonatomic, readonly) NSString *totalTs;
/// 文件名称, 这个视频的名字(从网络获取, 不是保存在本地的名字)
@property (copy,   nonatomic, readonly) NSString *name;
/// 视频所属课程的名称
@property (copy,   nonatomic, readonly) NSString *courseName;
/// 该视频所在的章名称
@property (copy,   nonatomic, readonly) NSString *chapterName;
/// 视频属于课程的缩略图
@property (copy,   nonatomic, readonly) NSString *coursePicUrlStr;
/// 视频所属课程的id
@property (copy,   nonatomic, readonly) NSString *courseId;
/// 该视频在第几章
@property (copy,   nonatomic, readonly) NSString *chapterSeq;
/// 该视频在第几节
@property (copy,   nonatomic, readonly) NSString *sectionSeq;
/// 章节的类型 (枚举MCSectionType)
@property (copy,   nonatomic, readonly) NSString *sectionType;
/// 视频是否学习完毕
@property (copy,   nonatomic, readonly) NSString *courseIsComplete;
/// 视频学习到的位置 (学习下载的视频进度)
@property (copy,   nonatomic, readonly) NSString *progressDate;

/// 是否是实战课程 --> 5.1.1 新增职业路径课程, 数据库字段修改比较麻烦, 所以就还使用这个字段标识课程的类型, 对应DownloadItem中的courseType字段
@property (copy,   nonatomic, readonly) NSString *courseType;
/// 是否正在学此节实战课程     finish = 7
@property (copy,   nonatomic, readonly) NSString *isStudyingAndNoStudyEnd;
/// 是否已经学完此节实战课程   finish = 8
@property (copy,   nonatomic, readonly) NSString *isStudyingAndStudyEnd;
/// 实战课程有值, 普通课程为空
@property (copy,   nonatomic, readonly) NSString *userId;

@property (strong,atomic) NSMutableArray<MCDownloadItem *> *itemsList;

@property (strong, nonatomic) FMDatabaseQueue *queue;

@end
@implementation MCDownloadDBManager
+ (instancetype)defaultManager {
    static MCDownloadDBManager *dbManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbManager = [[[self class] alloc] init];
    });
    return dbManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupConstString];
        // 初始化缓存数组
        self.itemsList = [NSMutableArray array];
        self.updateCourseType = NO;
        // 创建SQLite
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"imooc.sqlite"];
        self.queue = [FMDatabaseQueue databaseQueueWithPath:path];
        // 创建表
        [self createTable:MCDownloadItemTable];
        // 检查是否需要更新数据库字段 courseType 5.1.1
        [self checkNeedUpdate];
    }
    return self;
}

/// 创建表
- (void)createTable:(NSString *)table {
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            if (![db tableExists:table]) {
                NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement, %@ integer, %@ integer, %@ integer, %@ integer, %@ integer, %@ text, %@ text, %@ text, %@ text, %@ text, %@ integer, %@ integer, %@ integer, %@ integer, %@ integer, %@ double, %@ integer, %@ integer, %@ integer, %@ integer, %@ integer, %@ text);", table, wself.videoId, wself.chapterId, wself.state, wself.totalBytesWritten, wself.fileSize, wself.url, wself.name, wself.courseName, wself.chapterName, wself.coursePicUrlStr, wself.courseId, wself.chapterSeq, wself.sectionSeq, wself.sectionType, wself.courseIsComplete, wself.progressDate, wself.currentTs, wself.totalTs, wself.courseType, wself.isStudyingAndNoStudyEnd, wself.isStudyingAndStudyEnd, wself.userId];
                BOOL result = [db executeUpdate:sql];
                if (!result) {
                    LSLog(@"创建表%@失败", table);
                }
            }
        } else {
            LSLog(@"数据库打开失败");
        }
    }];
}


/// 获得table表中的Item数据, 返回的数据如果有 m3u8 类型的 item, 在 setUrl: 中就加载了所有的 child
- (void)loadItemsCompletion:(void(^)(void))completion {
    if (self.itemsList.count > 0) {
        [self.itemsList removeAllObjects];
    }
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.queue inDatabase:^(FMDatabase *db) {
            if ([db open]) {
                NSString * sql = [NSString stringWithFormat:@"select * from %@;", MCDownloadItemTable];
                FMResultSet *set = [db executeQuery:sql];
                while ([set next]) {    // 将set转成字典, 然后再转成模型
                    MCDownloadItem *item = [MCDownloadItem itemWithDict:[wself dictWithSet:set]];
                    if (wself.isUpdateCourseType) {
                        item.courseType = (NSInteger)item.courseType + 1;   // 所有的item类型都加1
                        NSString *updateSql = [wself updateCourseTypeSqlWithItem:item];
                        [db executeUpdate:updateSql];  // 更新数据
                    }
                    [wself.items addObject:item];
                }
                [set close];
                [db close];
                if (completion) {
                    completion();
                }
            } else {
                LSLog(@"数据库打开失败");
            }
            wself.updateCourseType = NO;    // 更新完成
        }];
    });
}

/**
 *  items   : 传递进来需要执行操作的元素数组
 *  flag    : 操作标识(插入; 删除; 更新)  NO:删除, 更新操作; YES:插入操作;
 *  return  : 返回需要执行的新数组
 */
- (NSArray<MCDownloadItem *> *)newItems:(NSArray<MCDownloadItem *> *)items insert:(BOOL)flag {
    __block NSMutableArray<MCDownloadItem *> *newItems = [NSMutableArray array];
    if (flag == YES) {    // 插入
        [items enumerateObjectsUsingBlock:^(MCDownloadItem *obj, NSUInteger idx, BOOL *stop) {
            if ([self itemExists:obj.videoId courseType:obj.courseType] == -1) {  // obj 不存在数据库中
                [newItems addObject:obj];
            }
        }];
    } else {     // 删除 || 更新 操作 item 必须存在
        [items enumerateObjectsUsingBlock:^(MCDownloadItem *obj, NSUInteger idx, BOOL *stop) {
            if ([self itemExists:obj.videoId courseType:obj.courseType] != -1) {
                [newItems addObject:obj];
            }
        }];
    }
    return newItems;
}
#pragma mark --- private
/// 检查数据库更新, 5.1.1 使用枚举 MCCourseType 来映射 isActualCombat 字段, 因为新增加了 路径的课程, 也为了统一所有的课程类型在整个app中的使用
- (void)checkNeedUpdate {
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db columnExists:wself.courseType inTableWithName:MCDownloadItemTable]) { // 需要更新
            NSString *sql = [NSString stringWithFormat:@"alter table '%@' add '%@' integer", MCDownloadItemTable, wself.courseType];
            if ([db executeUpdate:sql]) {   // 插入字段成功
                [db close];
                wself.updateCourseType = YES;
            }
        } else {    // 不需要更新
            wself.updateCourseType = NO;
            [db close];
        }
    }];
}

/// 这个判断条件不能使用courseType, 因为这次更新就是要修改 courseType
- (NSString *)updateCourseTypeSqlWithItem:(MCDownloadItem *)item {
    return [NSString stringWithFormat:@"update %@ set %@ = '%d',%@ = '%ld', %@ = '%lld', %@ = '%lld', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%d', %@ = '%d', %@ = '%d', %@ = '%ld', %@ = '%d', %@ = '%f', %@ = '%ld', %@ = '%ld', %@ = '%d', %@ = '%d', %@ = '%@', %@ = '%ld' where %@ = '%d' and isActualCombat = '%ld';", DownloadItemTable, self.chapterId, item.chapterId, self.state, (long)item.state, self.totalBytesWritten, item.totalBytesWritten, self.fileSize, item.fileSize, self.url, item.url, self.name, item.name, self.courseName, item.courseName, self.chapterName, item.chapterName, self.coursePicUrlStr, item.coursePicUrlStr, self.courseId, item.courseId, self.chapterSeq, item.chapterSeq, self.sectionSeq, item.sectionSeq, self.sectionType, (long)item.sectionType, self.courseIsComplete, item.courseIsComplete, self.progressDate, item.progressDate, self.currentTs, (long)item.currentTs, self.totalTs, (long)item.totalTs, self.isStudyingAndNoStudyEnd, item.isStudyingAndNoStudyEnd, self.isStudyingAndStudyEnd, item.isStudyingAndStudyEnd, self.userId, item.userId, self.courseType, (long)item.courseType,  self.videoId, item.videoId, (long)(item.courseType - 1)];
}
/// 初始化常量字符串
- (void)setupConstString {
    _videoId            = @"videoId";                   // int
    _chapterId          = @"chapterId";                 // int
    
    _state              = @"state";                     // NSInteger
    _totalBytesWritten  = @"totalBytesWritten";         // int64_t
    _fileSize           = @"fileSize";                  // int64_t
    
    _url                = @"url";                       // NSString
    _name               = @"name";                      // NSString
    _courseName         = @"courseName";                // NSString
    _chapterName        = @"chapterName";               // NSString
    _coursePicUrlStr    = @"coursePicUrlStr";           // NSString
    
    _courseId           = @"courseId";                  // int
    _chapterSeq         = @"chapterSeq";                // int
    _sectionSeq         = @"sectionSeq";                // int
    _sectionType        = @"sectionType";               // NSInteger
    _courseIsComplete   = @"courseIsComplete";          // BOOL
    _progressDate       = @"progressDate";              // double
    
    _currentTs          = @"currentTs";                 // NSInteger
    _totalTs            = @"totalTs";                   // NSInteger
    _courseType         = @"courseType";                // NSInteger 替换 isActualCombat
    
    _isStudyingAndNoStudyEnd = @"isStudyingAndNoStudyEnd";   // BOOL
    _isStudyingAndStudyEnd   = @"isStudyingAndStudyEnd";     // BOOL
    _userId             = @"userId";                    // NSString
}
/// 将set 对象转换成字典, 方便DownloadItem使用,
/// 5.1.1 版本删除 isActualCombat, 使用courseType  self.isUpdate == YES, 使用isActualCombat字段读取原有课程类型信息
- (NSDictionary *)dictWithSet:(FMResultSet *)set {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[self.videoId] = [NSString stringWithFormat:@"%d", [set intForColumn:self.videoId]];
    dict[self.chapterId] = [NSString stringWithFormat:@"%d", [set intForColumn:self.chapterId]];
    dict[self.state] = [NSString stringWithFormat:@"%ld", [set longForColumn:self.state]];
    dict[self.totalBytesWritten] = [NSString stringWithFormat:@"%lld", [set longLongIntForColumn:self.totalBytesWritten]];
    dict[self.fileSize] = [NSString stringWithFormat:@"%lld", [set longLongIntForColumn:self.fileSize]];
    dict[self.url] = [set stringForColumn:self.url];
    dict[self.name] = [set stringForColumn:self.name];
    dict[self.courseName] = [set stringForColumn:self.courseName];
    dict[self.chapterName] = [set stringForColumn:self.chapterName];
    dict[self.coursePicUrlStr] = [set stringForColumn:self.coursePicUrlStr];
    dict[self.courseId] = [NSString stringWithFormat:@"%d", [set intForColumn:self.courseId]];
    dict[self.chapterSeq] = [NSString stringWithFormat:@"%d", [set intForColumn:self.chapterSeq]];
    dict[self.sectionSeq] = [NSString stringWithFormat:@"%d", [set intForColumn:self.sectionSeq]];
    dict[self.sectionType] = [NSString stringWithFormat:@"%ld", [set longForColumn:self.sectionType]];
    dict[self.courseIsComplete] = [NSString stringWithFormat:@"%d", [set intForColumn:self.courseIsComplete]];
    dict[self.progressDate] = [NSString stringWithFormat:@"%f", [set doubleForColumn:self.progressDate]];
    dict[self.currentTs] = [NSString stringWithFormat:@"%ld", [set longForColumn:self.currentTs]];
    dict[self.totalTs] = [NSString stringWithFormat:@"%ld", [set longForColumn:self.totalTs]];
    if (self.isUpdateCourseType) {
        dict[self.courseType] = [NSString stringWithFormat:@"%d", [set intForColumn:@"isActualCombat"]];
    } else {
        dict[self.courseType] = [NSString stringWithFormat:@"%d", [set intForColumn:self.courseType]];
    }
    dict[self.isStudyingAndNoStudyEnd] = [NSString stringWithFormat:@"%d", [set intForColumn:self.isStudyingAndNoStudyEnd]];
    dict[self.isStudyingAndStudyEnd] = [NSString stringWithFormat:@"%d", [set intForColumn:self.isStudyingAndStudyEnd]];
    dict[self.userId] = [set stringForColumn:self.userId];
    return dict;
}

@end
