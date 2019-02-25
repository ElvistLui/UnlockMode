//
//  ELUnlockViewController.h
//  UnlockModeDemo
//
//  Created by Elvist on 2019/1/3.
//  Copyright © 2019 elvist. All rights reserved.
//
/**
 *  解锁视图控制器
 */

#import <UIKit/UIKit.h>

@interface ELUnlockViewController : UIViewController

@property (nonatomic, strong) NSNumber *isCanEvaluatePolicy;    ///< 是否支持touchID/faceID
@property (nonatomic, copy) void (^unlockedBlock)(void);    ///< 解锁后的回调

@end
