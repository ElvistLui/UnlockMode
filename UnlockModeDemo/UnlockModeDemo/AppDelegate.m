//
//  AppDelegate.m
//  UnlockModeDemo
//
//  Created by Elvist on 2019/1/3.
//  Copyright © 2019 elvist. All rights reserved.
//

#import "AppDelegate.h"

#import "ELUnlockViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIVisualEffectView *effectView;   ///< 毛玻璃

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    __weak typeof(self) weakSelf = self;
    ELUnlockViewController *unlockVC = [ELUnlockViewController new];
    unlockVC.unlockedBlock = ^{
        
        // 获取主视图控制器
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *tabbarCtrl = [sb instantiateViewControllerWithIdentifier:@"MainTabbarCtrl"];
        
        // 切换window的根视图
        // 方式1：动画转场
        tabbarCtrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [UIView transitionWithView:weakSelf.window
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            weakSelf.window.rootViewController = tabbarCtrl;
                            [UIView setAnimationsEnabled:oldState];
                        } completion:nil];
        
        // 方式2：直接切换
//        weakSelf.window.rootViewController = tabbarCtrl;
    };
    if ([unlockVC.isCanEvaluatePolicy isEqual:@1]) {
        
        // 设备支持解锁，并且app内设置了启用touchID、faceID解锁
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor whiteColor];
        [_window makeKeyAndVisible];
        _window.rootViewController = unlockVC;
    } else {
        
        // 设备不支持解锁，关闭app内解锁设置
        
    }
    
    return YES;
}

- (UIVisualEffectView *)effectView
{
    if (!_effectView) {
        
        // 毛玻璃view 视图
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        // 设置模糊透明度
        _effectView.alpha = 1.f;
        _effectView.frame = [UIScreen mainScreen].bounds;
    }
    _effectView.alpha = 1.f;
    return _effectView;
}

#pragma mark -
- (void)applicationWillResignActive:(UIApplication *)application
{
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 显示遮罩视图
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.effectView];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 移除遮罩视图
    [UIView animateWithDuration:0.15f animations:^{
        
        _effectView.alpha = 0.f;
    } completion:^(BOOL finished) {
        
        [_effectView removeFromSuperview];
    }];
}
- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
