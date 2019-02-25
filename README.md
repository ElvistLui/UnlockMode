## 使用touchID、faceID解锁

简化后的使用代码：
```
__weak typeof(self) weakSelf = self;
ELUnlockViewController *unlockVC = [ELUnlockViewController new];
unlockVC.unlockedBlock = ^{
        
	// 获取主视图控制器
	UIViewController *tabbarCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MainTabbarCtrl"];
        
	// 切换window的根视图
	weakSelf.window.rootViewController = tabbarCtrl;
};
if ([unlockVC.isCanEvaluatePolicy isEqual:@1]) {
        
	// 设备支持解锁，并且app内设置了启用touchID、faceID解锁
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[_window makeKeyAndVisible];
	_window.rootViewController = unlockVC;
} else {
        
	// 设备不支持解锁，关闭app内解锁设置  
}
```

ps:尝试了将解锁逻辑封装起来，但不太成功。。。


## 毛玻璃效果
向AppDelegate中添加一个属性 `UIVisualEffectView *effectView`，使用懒加载的方式初始化该属性。

```
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 显示遮罩视图，
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.effectView];
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
```