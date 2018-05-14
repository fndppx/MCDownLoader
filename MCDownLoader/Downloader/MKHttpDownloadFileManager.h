//
//  MKFileManager.h
//  imooc
//
//  Created by k12 on 2018/5/4.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MKHttpDownloadItem;
@interface MKHttpDownloadFileManager : NSObject
/// 删除 temp 目录下的 .tmp 临时文件
+ (void)deleteTempFiles;
/// 下载的文件 <1M 显示k; 大于1024M 显示G 小于1k 显示B
+ (NSString *)fileSizeStringWithSize:(int64_t)sectionSize;
//转移到目标文件路径
+ (void)moveDownloadedItemToFilePath:(MKHttpDownloadItem *)item atLocation:(NSURL*)location;
//移除临时文件
+ (void)removeTempFileAtURL:(NSURL *)location;
@end
