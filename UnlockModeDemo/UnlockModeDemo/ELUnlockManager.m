//
//  ELUnlockManager.m
//  UnlockModeDemo
//
//  Created by Elvist on 2019/1/5.
//  Copyright © 2019 elvist. All rights reserved.
//

#import "ELUnlockManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

static LAContext *unlockContext;

@implementation ELUnlockManager

//
+ (void)isDeviceSupportTouchFaceID:(void (^)(LAContext *, NSString *, BOOL, ELUnlockErrorCode))completion
{
    BOOL isSupport = NO;
    NSString *styleString = @"指纹/面部";
    ELUnlockErrorCode errorCode = ELUnlockErrorUnkwon;
    
    LAContext *unlockContext = [[LAContext alloc] init];
    NSError *authError = nil;
    
    BOOL isCanEvaluatePolicy = [unlockContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError];
    if (isCanEvaluatePolicy) {
        
        isSupport = YES;
        errorCode = ELUnlockErrorNone;
    } else {
        
        if (@available(iOS 11.0, *)) {
            
            switch (authError.code) {
                case LAErrorBiometryLockout:
                    
                    isSupport = YES;
                    errorCode = ELUnlockErrorNone;
                    break;
                case LAErrorBiometryNotAvailable:
                    
                    errorCode = ELUnlockErrorNotAvailable;
                    break;
                case LAErrorBiometryNotEnrolled:
                    
                    errorCode = ELUnlockErrorNotEnrolled;
                    break;
                    
                default:
                    break;
            }
        } else {
            
            switch (authError.code) {
                case LAErrorTouchIDLockout:

                    isSupport = YES;
                    errorCode = ELUnlockErrorNone;
                    break;
                case LAErrorTouchIDNotAvailable:
                    
                    errorCode = ELUnlockErrorNotAvailable;
                    break;
                case LAErrorTouchIDNotEnrolled:
                    
                    errorCode = ELUnlockErrorNotEnrolled;
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    if (isSupport) {
        
        if (@available(iOS 11.0, *)) {
            
            // iOS11后支持查看具体解锁方式
            switch (unlockContext.biometryType) {
                case LABiometryTypeNone:
                    break;
                case LABiometryTypeTouchID:
                {
                    styleString = @"TouchID";
                }
                    break;
                case LABiometryTypeFaceID:
                {
                    styleString = @"FaceID";
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    if (completion) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(unlockContext, styleString, isSupport, errorCode);
        });
    }
}

//
+ (void)evaluateDeviceTouchFaceIDSuccess:(void (^)(LAContext *))success
                                 failure:(void (^)(LAContext *, NSString *, ELUnlockErrorCode))failure
{
    [self isDeviceSupportTouchFaceID:^(LAContext *unlockContext, NSString *styleString, BOOL isSupport, ELUnlockErrorCode errorCode) {
        
        if (isSupport) {
            
            typeof(success) ELSuccess = success;
            [unlockContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:[NSString stringWithFormat:@"使用%@解锁", styleString] reply:^(BOOL success, NSError * _Nullable error) {
                
                if (success) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (success) { ELSuccess(unlockContext); }
                    });
                } else {
                    
                    // 做特定的错误判断处理逻辑。
                    NSLog(@"身份验证失败！ \nerrorCode : %ld, errorMsg : %@",(long)error.code, error.localizedDescription);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (failure) { failure(unlockContext, styleString, errorCode); }
                    });
                }
            }];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (failure) { failure(unlockContext, styleString, errorCode); }
            });
        }
    }];
}

@end
