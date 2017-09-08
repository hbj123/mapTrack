//
//  LocationViewController.m
//  MapTracking
//
//  Created by hbj on 2017/9/1.
//  Copyright © 2017年 保健. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()<AMapLocationManagerDelegate>
{
    UILabel *locationLable;
}
@property (nonatomic, strong) AMapLocationManager *locationManager;
/**
 *  持续定位是否返回逆地理信息，默认NO。
 */
@property (nonatomic, assign) BOOL locatingWithReGeocode;

@end

@implementation LocationViewController
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
    /******设置定位最小更新距离方法如下，单位米。当两次定位距离满足设置的最小更新距离时，SDK会返回符合要求的定位结果******/
    /******注意：在海外地区是没有地址描述返回的，地址描述只在中国国内返回。******/
    self.locationManager.distanceFilter = 5;
    
}

-(void)cofUI{
    locationLable = [[UILabel alloc] initWithFrame:self.view.bounds];
    locationLable.numberOfLines = 0;
    locationLable.textAlignment = NSTextAlignmentCenter;
    locationLable.text = @"";
    [self.view addSubview:locationLable];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self cofUI];
    [self configLocationManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /******如果需要持续定位返回逆地理编码信息，（自 V2.2.0版本起支持）需要做如下设置：******/
    [self.locationManager setLocatingWithReGeocode:YES];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    /******当不再需要定位时，调用AMapLocationManager提供的stopUpdatingLocation方法停止定位。代码如下：******/
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}
/******实现AMapLocationManagerDelegate代理的amapLocationManager:didUpdateLocation:reGeocode: 方法，处理位置更新。******/
/**
 *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param location 定位结果。
 *  @param reGeocode 逆地理信息。
 */

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    if (reGeocode)
    {
        NSLog(@"reGeocode:%@", reGeocode);
        locationLable.text = [reGeocode formattedAddress];
    }
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
