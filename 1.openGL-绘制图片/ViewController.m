//
//  ViewController.m
//  1.openGL-绘制图片
//
//  Created by 技术部mac1 on 2017/9/19.
//  Copyright © 2017年 技术部mac1. All rights reserved.
//

#import "ViewController.h"
#import "openGLView.h"


@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    openGLView * openV = [[openGLView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-50, 200, 100)];
    [self.view addSubview:openV];
    
}


@end
