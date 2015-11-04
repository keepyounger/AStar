//
//  ViewController.m
//  AXing
//
//  Created by lixy on 15/11/3.
//  Copyright © 2015年 lixy. All rights reserved.
//

#import "ViewController.h"
#import "MapView.h"

@interface ViewController ()
@property (nonatomic, strong) MapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mapView];
}

- (MapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MapView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
        _mapView.center = self.view.center;
    }
    return _mapView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
