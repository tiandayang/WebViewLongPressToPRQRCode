//
//  ViewController.m
//  WebViewLongPressToPRQRCode
//
//  Created by 田向阳 on 2017/11/6.
//  Copyright © 2017年 田向阳. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TestViewController *testVC = [TestViewController new];
    testVC.url = @"http://h5.hynh.cn";
    [self.view addSubview:testVC.view];
    testVC.view.frame = self.view.bounds;
    [self addChildViewController:testVC];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
