//
//  MCHttpDownloadItem.h
//  MCDownLoader
//
//  Created by k12 on 2018/4/27.
//  Copyright © 2018年 k12. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCHttpDownloadItem : NSObject
@property (nonatomic, strong) NSString * videoName;     // video Name

@property (nonatomic, retain) NSString * fileStorageDirectory;
@property (nonatomic, strong) NSString *downloadURL;     //  地址
@property (nonatomic, strong) NSString *cacheFilePath;   //  缓存地址
@property (nonatomic, strong) NSString *filePath;        //  文件地址

@property (nonatomic, strong) NSString *fileUrlName;
@property (nonatomic, strong) NSString *tmpFileUrlName;


@property (nonatomic, strong) NSString *lastCacheFilePath;
@property (nonatomic, strong) NSString *lastFilePath;
@property (nonatomic, assign) float percent;


@property (nonatomic, assign) NSUInteger totalRead; // 辅助
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSString * speed;         //下载速度  kb,MB
@property (nonatomic, strong) NSString *fileSize;       //单位 long long -> string
@property (nonatomic, strong) NSString *downLoad_size;  // 单位 long long -> string
- (NSString*)formatByteCount:(long long)size;

- (void)configureDownLoadItemWithUrl:(NSString *)url;
@end
