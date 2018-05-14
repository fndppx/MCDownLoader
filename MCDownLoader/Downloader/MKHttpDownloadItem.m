



//
//  MKHttpDownloadItem.m
//  imooc
//
//  Created by k12 on 2018/5/3.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import "MKHttpDownloadItem.h"
#import <CommonCrypto/CommonDigest.h>
@interface MKHttpDownloadItem()
@property (nonatomic, strong) NSString *fileUrlName;
@property (nonatomic, strong) NSString *tmpFileUrlName;
@end
@implementation MKHttpDownloadItem

- (BOOL)isTs{
    NSString * url = self.downloadURL;
    
    NSURL *tmp = [NSURL URLWithString:url];
    
    BOOL isTs = NO;
    if (tmp.query) {
        if ([tmp.path.pathExtension isEqualToString:@"ts"]) {
            isTs = YES;
        }
    }else{
        if ([url.pathExtension isEqualToString:@"ts"]) {
            isTs = YES;
        }
    }
    return isTs;
}
////////////////////////////////////////////////////////////////////////
- (void)configureDownLoadItemWithUrl:(NSString *)url{
    _downloadURL = url;
    self.fileUrlName = [self fileNameWithURLString:url isTmpFile:NO];
//    self.tmpFileUrlName = [self fileNameWithURLString:url isTmpFile:YES];
    self.filePath = [self filePathWithFileName:_fileUrlName];
//    self.cacheFilePath = [self filePathWithFileName:_tmpFileUrlName];
}

- (NSString *) md5String:(NSString *) srcString {
    const char *cStr = [srcString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)fileStorageDirectory {
    // 所有下载的根目录
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DownloadFiles"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {  // 创建 m3u8 文件夹
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
- (NSString *) filePathWithFileName:(NSString *) fileName {
    if (self.filePath && fileName) {
        return [self.filePath stringByAppendingPathComponent:fileName];
    }
    return nil;
}

- (NSString *) fileNameWithURLString:(NSString *) url isTmpFile:(BOOL) isTmpFile {
    NSString * suffix = @"";
    
    NSURL *tmp = [NSURL URLWithString:url];
    
    if (tmp.query) {
        suffix =  tmp.path.pathExtension;
    }else{
        suffix =  url.pathExtension;
    }
    NSString *md5Value = [self md5String:url];
    NSString *fileName = [md5Value stringByAppendingString:[NSString stringWithFormat:@".%@",suffix]];
//    if (isTmpFile) {
//        fileName = [fileName stringByAppendingString:kDefaultTmpVODTypeSuffix];
//    }
    return fileName;
}
@end
