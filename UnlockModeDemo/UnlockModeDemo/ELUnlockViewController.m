//
//  ELUnlockViewController.m
//  UnlockModeDemo
//
//  Created by Elvist on 2019/1/3.
//  Copyright © 2019 elvist. All rights reserved.
//

#import "ELUnlockViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define kELUnlock_color_nor [UIColor colorWithRed:69/255.0 green:133/255.0 blue:245/255.0 alpha:1.0f]
#define kELUnlock_color_sel [UIColor colorWithRed:99/255.0 green:163/255.0 blue:255/255.0 alpha:1.0f]

// 设备识别类型
typedef NS_ENUM(NSUInteger, ELUnlockSryleCode) {
    ELUnlockSryleUnknow,    ///< 无法判别，iOS11以下
    ELUnlockSryleTouchID,   ///< 指纹解锁
    ELUnlockSryleFaceID,    ///< 面部解锁
};

@interface ELUnlockViewController ()

@property (nonatomic, strong) LAContext *unlockContext;     ///< 解锁上下文
@property (nonatomic, assign) ELUnlockSryleCode styleCode;  ///< 解锁方式
@property (nonatomic, copy) NSString *styleMessage;         ///< 解锁方式描述

@end

@implementation ELUnlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 执行
    [self didClickUnlockButton:nil];
}

#pragma mark -
- (void)setupView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    _styleCode = ELUnlockSryleUnknow;
    _styleMessage = @"使用指纹/面部解锁";
    
    if (@available(iOS 11.0, *)) {
        
        switch (self.unlockContext.biometryType) {
            case LABiometryTypeNone:
            {
                _isCanEvaluatePolicy = @10;
            }
                break;
            case LABiometryTypeTouchID:
            {
                _styleCode = ELUnlockSryleTouchID;
                _styleMessage = @"使用TouchID解锁";
            }
                break;
            case LABiometryTypeFaceID:
            {
                _styleCode = ELUnlockSryleFaceID;
                _styleMessage = @"使用FaceID解锁";
            }
                break;
            default:
                break;
        }
    }
    
    //
    CGRect imgFrame = CGRectZero;
    imgFrame.size = CGSizeMake(100, 100);
    imgFrame.origin.x = ([UIScreen mainScreen].bounds.size.width - imgFrame.size.width)/2.f;
    imgFrame.origin.y = [UIScreen mainScreen].bounds.size.height*0.35;
    
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = imgFrame;
    imageButton.contentMode = UIViewContentModeScaleAspectFit;
    [imageButton addTarget:self action:@selector(didClickUnlockButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    //
    CGRect titleFrame = CGRectZero;
    titleFrame.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
    titleFrame.origin.y = CGRectGetMaxY(imgFrame) + 20;
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = titleFrame;
    titleButton.contentMode = UIViewContentModeScaleAspectFit;
    [titleButton setTitleColor:kELUnlock_color_nor forState:UIControlStateNormal];
    [titleButton setTitleColor:kELUnlock_color_sel forState:UIControlStateHighlighted];
    [titleButton addTarget:self action:@selector(didClickUnlockButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:titleButton];
    
    //
    if ([_isCanEvaluatePolicy isEqual:@10] ||
        [self.isCanEvaluatePolicy isEqual:@0]) {
        
        // 设备不再支持解锁，显示关闭按钮
        [titleButton setTitle:@"点击关闭本页面" forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0f] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0f] forState:UIControlStateHighlighted];
        [titleButton addTarget:self action:@selector(didClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [imageButton setImage:[UIImage imageNamed:@"img_unlock_close"] forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(didClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    //
    [titleButton setTitle:[NSString stringWithFormat:@"点击%@", _styleMessage] forState:UIControlStateNormal];
    switch (_styleCode) {
        case ELUnlockSryleUnknow:
        case ELUnlockSryleTouchID:
            
            [imageButton setImage:[UIImage imageNamed:@"img_unlock_touchid_nor"] forState:UIControlStateNormal];
            [imageButton setImage:[UIImage imageNamed:@"img_unlock_touchid_sel"] forState:UIControlStateHighlighted];
            break;
        case ELUnlockSryleFaceID:
            
            [imageButton setImage:[UIImage imageNamed:@"img_unlock_faceid_nor"] forState:UIControlStateNormal];
            [imageButton setImage:[UIImage imageNamed:@"img_unlock_faceid_sel"] forState:UIControlStateHighlighted];
            break;
            
        default:
            break;
    }
}

#pragma mark - 按钮点击事件
- (void)didClickUnlockButton:(UIButton *)sender
{
    [self.unlockContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:_styleMessage reply:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_unlockedBlock) { _unlockedBlock(); }
            });
        } else {
            
            // 做特定的错误判断处理逻辑。
            NSLog(@"身份验证失败！ \nerrorCode : %ld, errorMsg : %@",(long)error.code, error.localizedDescription);
        }
    }];
}
- (void)didClickCloseButton:(UIButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_unlockedBlock) { _unlockedBlock(); }
    });
}

#pragma mark - 懒加载
- (LAContext *)unlockContext
{
    if (!_unlockContext) {
        
        _unlockContext = [[LAContext alloc] init];
    }
    return _unlockContext;
}
- (NSNumber *)isCanEvaluatePolicy
{
    if (!_isCanEvaluatePolicy) {
        
        NSError *authError = nil;
        _isCanEvaluatePolicy = [self.unlockContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError] ? @1 : @0;
        if (authError) {
            
            if (@available(iOS 11.0, *)) {
                
                switch (authError.code) {
                    case LAErrorBiometryLockout:
                        
                        _isCanEvaluatePolicy = @1;
                        break;
                        
                    default:
                        _isCanEvaluatePolicy = @0;
                        break;
                }
            } else {
                
                switch (authError.code) {
                    case LAErrorTouchIDLockout:
                        
                        _isCanEvaluatePolicy = @1;
                        break;
                        
                    default:
                        _isCanEvaluatePolicy = @0;
                        break;
                }
            }
        } else {
            
            _isCanEvaluatePolicy = @1;
        }
    }
    return _isCanEvaluatePolicy;
}

/*
 typedef NS_ENUM(NSInteger, LAError)
 {
 //身份验证不成功，因为用户无法提供有效的凭据。
 LAErrorAuthenticationFailed = kLAErrorAuthenticationFailed,
 
 //认证被用户取消(例如了取消按钮)。
 LAErrorUserCancel = kLAErrorUserCancel,
 
 //认证被取消了,因为用户利用回退按钮(输入密码)。
 LAErrorUserFallback = kLAErrorUserFallback,
 
 //身份验证被系统取消了(如另一个应用程序去前台)。
 LAErrorSystemCancel = kLAErrorSystemCancel,
 
 //身份验证无法启动,因为设备没有设置密码。
 LAErrorPasscodeNotSet = kLAErrorPasscodeNotSet,
 
 //身份验证无法启动,因为触摸ID不可用在设备上。
 LAErrorTouchIDNotAvailable NS_ENUM_DEPRECATED(10_10, 10_13, 8_0, 11_0, "use LAErrorBiometryNotAvailable") = kLAErrorTouchIDNotAvailable,
 
 //身份验证无法启动,因为没有登记的手指触摸ID。
 LAErrorTouchIDNotEnrolled NS_ENUM_DEPRECATED(10_10, 10_13, 8_0, 11_0, "use LAErrorBiometryNotEnrolled") = kLAErrorTouchIDNotEnrolled,
 
 //验证不成功,因为有太多的失败的触摸ID尝试和触///摸现在ID是锁着的。
 //解锁TouchID必须要使用密码，例如调用LAPolicyDeviceOwnerAuthenti//cationWithBiometrics的时候密码是必要条件。
 //身份验证不成功，因为有太多失败的触摸ID尝试和触摸ID现在被锁定。
 LAErrorTouchIDLockout NS_ENUM_DEPRECATED(10_11, 10_13, 9_0, 11_0, "use LAErrorBiometryLockout")
 __WATCHOS_DEPRECATED(3.0, 4.0, "use LAErrorBiometryLockout") __TVOS_DEPRECATED(10.0, 11.0, "use LAErrorBiometryLockout") = kLAErrorTouchIDLockout,
 
 //应用程序取消了身份验证（例如在进行身份验证时调用了无效）。
 LAErrorAppCancel NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorAppCancel,
 
 //LAContext传递给这个调用之前已经失效。
 LAErrorInvalidContext NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorInvalidContext,
 
 //身份验证无法启动,因为生物识别验证在当前这个设备上不可用。
 LAErrorBiometryNotAvailable NS_ENUM_AVAILABLE(10_13, 11_0) __WATCHOS_AVAILABLE(4.0) __TVOS_AVAILABLE(11.0) = kLAErrorBiometryNotAvailable,
 
 //身份验证无法启动，因为生物识别没有录入信息。
 LAErrorBiometryNotEnrolled NS_ENUM_AVAILABLE(10_13, 11_0) __WATCHOS_AVAILABLE(4.0) __TVOS_AVAILABLE(11.0) = kLAErrorBiometryNotEnrolled,
 
 //身份验证不成功，因为太多次的验证失败并且生物识别验证是锁定状态。此时，必须输入密码才能解锁。例如LAPolicyDeviceOwnerAuthenticationWithBiometrics时候将密码作为先决条件。
 LAErrorBiometryLockout NS_ENUM_AVAILABLE(10_13, 11_0) __WATCHOS_AVAILABLE(4.0) __TVOS_AVAILABLE(11.0) = kLAErrorBiometryLockout,
 
 //身份验证失败。因为这需要显示UI已禁止使用interactionNotAllowed属性。  据说是beta版本
 LAErrorNotInteractive API_AVAILABLE(macos(10.10), ios(8.0), watchos(3.0), tvos(10.0)) = kLAErrorNotInteractive,
 } NS_ENUM_AVAILABLE(10_10, 8_0) __WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0);
 */

@end
