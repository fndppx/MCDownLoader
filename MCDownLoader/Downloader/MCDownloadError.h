//
//  MCDownloadError.h
//  MCDownLoader
//
//  Created by k12 on 2018/4/27.
//  Copyright © 2018年 k12. All rights reserved.
//

#ifndef MCDownloadError_h
#define MCDownloadError_h

typedef NS_ENUM(NSInteger, MCDownloadErrorType) {
    
//
//    LECVODownloadErrorTypeUnkownError = 0,                      //未知错误
//    LECVODownloadErrorTypeGPCUnkownError = 1,                   //GPC未知错误
//    LECVODownloadErrorTypeGPCNotAllowDownload = 2,              //GPC不允许下载
//    LECVODownloadErrorTypeGPCEncryptionVideo = 3,               //GPC加密视频
//    LECVODownloadErrorTypeGPCNoAvaiableVideo = 4,               //GPC没有返回可用视频
//
//
//    LECVODownloadErrorTypeInvalidVideoId = 200,                 // 无效的视频Id
//
//
//    LECVODownloadErrorTypeGSLBUnkownError = 1000,               //GSLB未知错误
//    LECVODownloadErrorTypeGSLBNoAvaiableVideo = 1001,           //GSLB没有返回可用视频
//
//    LECVODownloadErrorTypeHTTPUnkownError = 2000,               //HTTP未知错误
//
//    LECVODownloadErrorTypeOtherDuplicateDownload = 3000,        //已存在相同下载
    LECVODownloadErrorTypeOtherInputError = 3001                //输入参数有误
};

#endif /* MCDownloadError_h */
