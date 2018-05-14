//
//  MKFileManager.m
//  imooc
//
//  Created by k12 on 2018/5/4.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import "MKHttpDownloadFileManager.h"
#import "MKHttpDownloadItem.h"
@implementation MKHttpDownloadFileManager
/// 删除 temp 目录下的 .tmp 临时文件
+ (void)deleteTempFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // background session 临时文件路径在 caches/com.apple.nsurlsessiond/Downloads/com.mukewang.mukewang 下面
    // default session 临时文件路径在 NSTemporaryDirectory() 下面
    //    NSString *cache = [[[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com.apple.nsurlsessiond"] stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:@"com.mukewang.mukewang"];
    NSString *cache = NSTemporaryDirectory();
    //    NSArray *subpaths = [fileManager subpathsAtPath:cache];
    NSArray *subpaths = [fileManager enumeratorAtPath:cache].allObjects;
    // 找到文件路径(文件名)
    NSArray *temps0 = [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension==%@", @"tmp"]];
    for (NSString *temp in temps0) {
        NSString *file = [cache stringByAppendingPathComponent:temp];
        if ([fileManager fileExistsAtPath:file]) {
            [fileManager removeItemAtPath:file error:nil];
        }
    }
}

/// 下载的文件 <1M 显示k; 大于1024M 显示G 小于1k 显示B
+ (NSString *)fileSizeStringWithSize:(int64_t)sectionSize {
    // 显示视频的大小
    NSString *fileSizeStr = nil;
    if (sectionSize / 1024. /1024 >= 1) {
        fileSizeStr = [NSString stringWithFormat:@"%.1fM", sectionSize/1024./1024];
    } else if (sectionSize / 1024. >= 1){
        fileSizeStr = [NSString stringWithFormat:@"%.fK", sectionSize/1024.];
    } else if (sectionSize  >= 0){
        fileSizeStr = [NSString stringWithFormat:@"%lldB", sectionSize];
    }
    if (sectionSize == 0 || !sectionSize || fileSizeStr == nil) {
        return @"0B";
    }
    return fileSizeStr;
}
+ (void)removeTempFileAtURL:(NSURL *)location{
    NSError *error = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:location.absoluteString]) {
        [manager removeItemAtPath:location.absoluteString error:nil];
    }
#warning 这里可能出错
    BOOL move = [manager moveItemAtURL:location toURL:location error:&error];
    if (error || move == NO) {
    }
}
/// item 下载完成, 移动文件
+ (void)moveDownloadedItemToFilePath:(MKHttpDownloadItem *)item atLocation:(NSURL*)location  {
    // 获得文件目标路径 self.file, 移动文件, 系统自动删除临时文件
    
//    NSURL *fileUrl = [NSURL fileURLWithPath:item.filePath];
//    if (item.totalBytesWritten > 0) {   // 如果是断点续传, 拼接文件, 如果 self.totalByteWritten > 0文件一定存在
//        NSData *data = [NSData dataWithContentsOfURL:location];
//        NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:fileUrl error:nil];
//        [handle seekToEndOfFile];
//        [handle writeData:data];
//        [handle closeFile];
//    } else {    // mp4 一直下载没有中断, 或者是 ts
//
//    }
    NSError *error = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:item.filePath]) {
        [manager removeItemAtPath:item.filePath error:nil];
    }
#warning 这里可能出错
    NSURL *fileUrl = [NSURL fileURLWithPath:item.filePath];

    BOOL move = [manager moveItemAtURL:location toURL:fileUrl error:&error];
    if (error || move == NO) {
    }
}
@end
