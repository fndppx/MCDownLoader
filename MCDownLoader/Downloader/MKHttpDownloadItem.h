//
//  MKHttpDownloadItem.h
//  imooc
//
//  Created by k12 on 2018/5/3.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKHttpDownloadItem : NSObject
//必传
@property (nonatomic, strong) NSString *downloadURL;     //  地址
@property (nonatomic, strong) NSString *filePath;        //  文件地址

/// 文件已经下载的大小
@property (assign, nonatomic) int64_t totalBytesWritten;

@property (assign, nonatomic, readonly) BOOL isTs;
+ (NSString *)fileStorageDirectory;
@end
