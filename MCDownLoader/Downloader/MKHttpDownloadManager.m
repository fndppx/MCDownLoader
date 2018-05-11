


//
//  MKHttpDownloadManager.m
//  imooc
//
//  Created by k12 on 2018/5/3.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import "MKHttpDownloadManager.h"
@interface MKHttpDownloadManager()<NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property (nonatomic,strong)MKHttpDownloadItem * downloadItem;
@property (nonatomic,copy)void(^downloadingHandler)(long long downloadBytes,long long totalBytes);
@property (nonatomic,copy)void(^startHandler)(void);
@property (nonatomic,copy)void(^finishHandler)(NSURLSessionDownloadTask*downloadTask,NSURL*location);
@property (nonatomic,copy)void(^failHandler)(NSError*error,NSURLSessionTask*downloadTask);


@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDownloadTask *task;

@end
static MKHttpDownloadManager *sharedManager;

@implementation MKHttpDownloadManager
+ (id) sharedDownloadManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[MKHttpDownloadManager alloc] init];
    });
    return sharedManager;
}
#pragma mark - 下载任务
- (NSURLSession*)session{
    if (_session==nil) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
//        cfg.allowsCellularAccess = [[NSUserDefaults standardUserDefaults] boolForKey:MKWwanDownloadEnableKey];
        cfg.allowsCellularAccess = YES;
        _session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (BOOL) downloadItem:(MKHttpDownloadItem *) downloadItem
     withStartHandler:(void(^)(void)) startHandler
withDownloadingHandler:(void(^)(long long, long long)) downloadingHandler
    withFinishHandler:(void(^)(NSURLSessionDownloadTask*downloadTask,NSURL*location)) finishHandler
      withFailHandler:(void(^)(NSError*error,NSURLSessionTask*downloadTask)) failHandler{
    if (downloadItem==nil) {
        return NO;
    }
    //setblock
    self.startHandler = startHandler;
    self.downloadingHandler = downloadingHandler;
    self.finishHandler = finishHandler;
    self.failHandler = failHandler;
    
    
    self.downloadItem = downloadItem;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadItem.downloadURL]];
    BOOL isTs = self.downloadItem.isTs;
    if (self.downloadItem.totalBytesWritten > 0&&!isTs) {
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", self.downloadItem.totalBytesWritten];
        [request setValue:range forHTTPHeaderField:@"Range"];
    }
    self.task = [self.session downloadTaskWithRequest:request];
    self.task.taskDescription = self.downloadItem.downloadURL;
    [self.task resume];
    
    
    !self.startHandler?:self.startHandler();
    
    return YES;
}


#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    !self.finishHandler?:self.finishHandler(downloadTask,location);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        !self.failHandler?:self.failHandler(error,task);
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    !self.downloadingHandler?:self.downloadingHandler(totalBytesWritten,totalBytesExpectedToWrite);
}


- (void) stopDownloadTaskCompleted:(void(^)(void))completed{
    BOOL isTs = self.downloadItem.isTs;
    
    void(^cancelCompletedBlcok)(NSData * _Nullable resumeData) = ^(NSData * _Nullable resumeData){
        if (resumeData.length > 0) {
            CFPropertyListRef plist = CFPropertyListCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)resumeData, kCFPropertyListImmutable, NULL, nil);
            NSDictionary *dict = (__bridge NSDictionary *)plist;
            NSArray *allKeys = dict.allKeys;
            NSString *path = @"";
            if ([allKeys containsObject:@"NSURLSessionResumeInfoLocalPath"]) {
                path = dict[@"NSURLSessionResumeInfoLocalPath"];
            } else if ([allKeys containsObject:@"NSURLSessionResumeInfoTempFileName"]) {
                NSString *fileName = dict[@"NSURLSessionResumeInfoTempFileName"];
                path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            } else {
                for (id obj in dict.allValues) {
                    if ([obj isKindOfClass:[NSString class]] && [obj containsString:@".tmp"]) {
                        path = [NSTemporaryDirectory() stringByAppendingPathComponent:obj];
                    }
                }
            }
            if (path.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
                if (!isTs) {  // 保存已下载的mp4
                    [self writeTmpFile:path withFilePath:self.downloadItem.filePath];
                } else {    // 不是MP4文件, 删除临时文件
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                }
            }
            CFRelease(plist);
        }
        !completed?:completed();
        [MKHttpDownloadFileManager deleteTempFiles];
    };
    
    __weak typeof(self) wself = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        !cancelCompletedBlcok?:cancelCompletedBlcok(resumeData);
        wself.task = nil;
    }];
}

- (void)cancelsAllOutstandingTasks{
    [self.session invalidateAndCancel];     // 之前的 session 失效
    self.session = nil;
}

- (void)writeTmpFile:(NSString *)absolutePath withFilePath:(NSString*)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [fileManager contentsAtPath:absolutePath];
    // 采用拼接文件方法
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [writeHandle seekToEndOfFile];
    if (data.length > 0) {
        [writeHandle writeData:data];
        [writeHandle closeFile];
    } else {

    }
    // 删除临时文件, 重新开始下载时, 系统会创建一个新的临时文件
    if ([fileManager fileExistsAtPath:absolutePath]) {
        [fileManager removeItemAtPath:absolutePath error:nil];
    }
}

@end


