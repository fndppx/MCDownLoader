//
//  MKFileManager.m
//  imooc
//
//  Created by k12 on 2018/5/4.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import "MKHttpDownloadFileManager.h"

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
@end
