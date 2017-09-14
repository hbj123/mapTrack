//
//  TrackingViewController.h
//  MapTracking
//
//  Created by hbj on 2017/9/1.
//  Copyright © 2017年 保健. All rights reserved.
//

#import "BJ_BaseViewController.h"

@interface TrackingViewController : BJ_BaseViewController
/*地图创建*/
@property (nonatomic, strong) MAMapView *mapView;
/*定位助手类创建*/
@property (nonatomic, strong) AMapLocationManager *locationManager;
/*大头针 标记当前位置*/
@property (nonatomic, strong) MAPointAnnotation *pointAnnotaiton;
/*
 详细地址展示
 */
@property (nonatomic, strong) UILabel *detailLabel;
/*逆地理编码*/
@property (nonatomic, strong) AMapLocationReGeocode *geocode;
/*轨迹路线数组*/
@property (nonatomic, strong) NSArray *lines;

@property (nonatomic, strong) MAAnimatedAnnotation *animat;

@end
