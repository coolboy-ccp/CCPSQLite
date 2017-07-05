//
//  ViewController.m
//  CCPSQLite
//
//  Created by Ceair on 17/7/4.
//  Copyright © 2017年 ccp. All rights reserved.
//

#import "ViewController.h"
#import "AirportSQL.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AirportSQL alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
