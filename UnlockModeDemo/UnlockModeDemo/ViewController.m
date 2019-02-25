//
//  ViewController.m
//  UnlockModeDemo
//
//  Created by Elvist on 2019/1/3.
//  Copyright © 2019 elvist. All rights reserved.
//

#import "ViewController.h"

#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblMsg;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [NSDateFormatter new];
    [format setDateFormat:@"yyyyMMdd hhmmss"];
    _dateLabel.text = [format stringFromDate:date];
    _dateLabel.numberOfLines = 0;
}

@end
