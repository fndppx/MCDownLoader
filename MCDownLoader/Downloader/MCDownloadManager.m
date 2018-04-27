//
//  MCDownloaderManager.m
//  MCDownLoader
//
//  Created by k12 on 2018/4/26.
//  Copyright © 2018年 k12. All rights reserved.
//

#import "MCDownloadManager.h"
#define kVODDownloadDirectoryName   @"VODDownloads"

#define kHttpDownloadItemKey        @"kHttpDownloadItemKey"
@interface MCDownloadManager()
@property (nonatomic, strong) NSMutableArray *mVodItemsList;
@property (nonatomic, strong) NSString *dcPlayUUID;           //TODO:   下载时的uuid取值逻辑不确定，目前定为每一个下载会刷新一个uuid
@property (nonatomic, strong) NSLock *vodItemsListLock;
@property (nonatomic, strong) NSString *vodStorageDirectory;
@end
@implementation MCDownloadManager
static MCDownloadManager *sharedManager;

+ (id) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[MCDownloadManager alloc] init];
    });
    return sharedManager;
}

- (id) init {
    if (self = [super init]) {
//        _dataEngine = [[TVPlayerDataEngine alloc] init];
        _mVodItemsList = [[NSMutableArray alloc] init];
        _vodItemsListLock = [[NSLock alloc] init];
        
        [self loadVodStorageDirectory];
        [self loadVodItemsListFromStorage];
    }
    return self;
}
- (void) loadVodStorageDirectory {
    NSString* dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *subPath = [dir stringByAppendingPathComponent:kVODDownloadDirectoryName];
    NSFileManager *fileManagre = [NSFileManager defaultManager];
    [fileManagre createDirectoryAtPath:subPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    _vodStorageDirectory = subPath;
}

- (void) loadVodItemsListFromStorage {
//    NSFetchRequest* request=[[NSFetchRequest alloc] init];
//    NSEntityDescription* categoryListDesc=[NSEntityDescription entityForName:@"LECVODDownloadEntity" inManagedObjectContext:self.managedObjectContext];
//    [request setEntity:categoryListDesc];
//    
//    NSArray* fetchResultList = [self.managedObjectContext executeFetchRequest:request error:nil];
//    
//    for (LECVODDownloadEntity *vodDownloadEntity in fetchResultList) {
//        LECVODDownloadItem *item = [[LECVODDownloadItem alloc] init];
//        item.fileStorageDirectory = _vodStorageDirectory;
//        
//        //将初始化、错误、下载中等状态统一设定为暂停
//        LECVODDownloadEntityStatus downloadStatus = (LECVODDownloadEntityStatus)[vodDownloadEntity.status integerValue];
//        if (downloadStatus != LECVODDownloadEntityStatusDownloadFinish) {
//            vodDownloadEntity.status = [NSNumber numberWithInt:LECVODDownloadEntityStatusDownloadPause];
//        }
//        
//        [item loadPropertiesFromVODDownloadEntity:vodDownloadEntity];
//        [_vodItemsListLock lock];
//        [_mVodItemsList insertObject:item atIndex:0];
//        [_vodItemsListLock unlock];
//    }
}

@end
