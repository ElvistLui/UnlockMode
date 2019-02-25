//
//  ELUnlockManager.h
//  UnlockModeDemo
//
//  Created by Elvist on 2019/1/5.
//  Copyright © 2019 elvist. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LAContext;

typedef NS_ENUM(NSUInteger, ELUnlockErrorCode) {
    ELUnlockErrorNone,          ///< 无措
    ELUnlockErrorNotAvailable,  ///< 设备不支持ID解锁
    ELUnlockErrorNotEnrolled,   ///< 设备未开启ID解锁
    ELUnlockErrorUnkwon,        ///< 未知
};

#warning 尝试了封装，但不太成功
@interface ELUnlockManager : NSObject

/// 判断设备是否支持开启TouchID/FaceID
+ (void)isDeviceSupportTouchFaceID:(void (^)(LAContext *unlockContext, NSString *styleString, BOOL isSupport, ELUnlockErrorCode errorCode))completion;

/// 验证TouchID/FaceID
+ (void)evaluateDeviceTouchFaceIDSuccess:(void (^)(LAContext *unlockContext))success
                                 failure:(void (^)(LAContext *unlockContext, NSString *styleString, ELUnlockErrorCode errorCode))failure;

@end
