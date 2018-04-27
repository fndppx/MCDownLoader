

//
//  MCHttpDownloadItem.m
//  MCDownLoader
//
//  Created by k12 on 2018/4/27.
//  Copyright © 2018年 k12. All rights reserved.
//

#import "MCHttpDownloadItem.h"
#import <CommonCrypto/CommonDigest.h>

#define kDefaultVODTypeSuffix       @".mp4"
#define kDefaultTmpVODTypeSuffix    @".tmp"
@implementation MCHttpDownloadItem
- (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
- (void)configureDownLoadItemWithUrl:(NSString *)url{
    _downloadURL = url;
    self.fileUrlName = [self fileNameWithURLString:url isTmpFile:NO];
    self.tmpFileUrlName = [self fileNameWithURLString:url isTmpFile:YES];
    self.filePath = [self filePathWithFileName:_fileUrlName];
    self.cacheFilePath = [self filePathWithFileName:_tmpFileUrlName];
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

- (NSString *) filePathWithFileName:(NSString *) fileName {
    if (_fileStorageDirectory && fileName) {
        return [_fileStorageDirectory stringByAppendingPathComponent:fileName];
    }
    return nil;
}

- (NSString *) fileNameWithURLString:(NSString *) url isTmpFile:(BOOL) isTmpFile {
    NSString *md5Value = [self md5String:url];
    NSString *fileName = [md5Value stringByAppendingString:kDefaultVODTypeSuffix];
    if (isTmpFile) {
        fileName = [fileName stringByAppendingString:kDefaultTmpVODTypeSuffix];
    }
    return fileName;
}
@end
