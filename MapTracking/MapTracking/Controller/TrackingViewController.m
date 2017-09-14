//
//  TrackingViewController.m
//  MapTracking
//
//  Created by hbj on 2017/9/1.
//  Copyright © 2017年 保健. All rights reserved.
//

#import "TrackingViewController.h"
#import "Tracking.h"

#define kH  [UIScreen mainScreen].bounds.size.height
#define kW  [UIScreen mainScreen].bounds.size.width

@interface TrackingViewController ()<AMapLocationManagerDelegate, MAMapViewDelegate, TrackingDelegate>


@property (nonatomic, strong) Tracking *tracking;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end
/*
 1. 定位
 2. 画轨迹
 3. 回放轨迹
 */
@implementation TrackingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArr = [NSMutableArray array];
    
    // Do any additional setup after loading the view from its nib.
    [self configSegment];
    [self initLabel];
    [self initMapView];
    [self configLocationManager];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}

- (void)initLabel {
    if (!self.detailLabel) {
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + 64, kW - 10 * 2, 100)];
        [self.view addSubview:_detailLabel];
        _detailLabel.numberOfLines = 0;
        [_detailLabel setBackgroundColor:[UIColor yellowColor]];
    }
    
}


- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.detailLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.detailLabel.frame) - 15 - 90)];
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
    }
}

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    self.locationManager.distanceFilter = 2;
    //    self.locationManager.locationTimeout
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:YES];
    
    [self.locationManager startUpdatingLocation];
    
}

- (void)configSegment {
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"开始定位", @"停止定位"]];
    segment.frame = CGRectMake(20, kH - 90 - 10, kW - 40, 70);
    [segment setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:segment];
    
    [segment addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)segmentedChanged:(UISegmentedControl*)sender
{
    //输出当前的索引值
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
        {
            //开始进行连续定位
            [self.locationManager startUpdatingLocation];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                /* Colored Polyline. */
                CLLocationCoordinate2D coloredPolylineCoords[5];
                coloredPolylineCoords[0].latitude = 30.339140;
                coloredPolylineCoords[0].longitude = 120.109537;
                
                coloredPolylineCoords[1].latitude = 30.339240;
                coloredPolylineCoords[1].longitude = 120.119537;
                
                coloredPolylineCoords[2].latitude = 30.334340;
                coloredPolylineCoords[2].longitude = 120.109537;
                
                coloredPolylineCoords[3].latitude = 30.341140;
                coloredPolylineCoords[3].longitude = 120.119537;
                
                coloredPolylineCoords[4].latitude = 30.339140;
                coloredPolylineCoords[4].longitude = 120.109537;
                
                MAPolyline *line = [MAPolyline polylineWithCoordinates:coloredPolylineCoords count:5];
                self.lines = @[line];
                
                [self.mapView addOverlays:self.lines];
                
                
                if (!self.animat) {
                    self.animat = [[MAAnimatedAnnotation alloc] init];
                }
                
                [self.animat setCoordinate:CLLocationCoordinate2DMake(30.339140, 120.109537)];
                [self.mapView addAnnotation:self.animat];
                
                
                [self.animat addMoveAnimationWithKeyCoordinates:coloredPolylineCoords count:5 withDuration:5.0 withName:@"跑" completeCallback:^(BOOL isFinished) {
                    NSLog(@"跑完了 哥哥");
                }];
                
            });
            
            
        }
            break;
        case 1:
            
        {
            //停止定位
            [self.locationManager stopUpdatingLocation];
            //移除地图上的annotation
            [self.mapView removeAnnotations:self.mapView.annotations];
            self.pointAnnotaiton = nil;
            //移除路径轨迹
            [self.mapView removeOverlays:self.lines];

            if (!self.tracking) {
                [self setupTracking];
            }
            [self.tracking execute];
        }
            break;
        default:
            break;
    }
    
}



/* 构建轨迹回放. */
- (void)setupTracking
{
    /* Colored Polyline. */
    CLLocationCoordinate2D coloredPolylineCoords[5];
    coloredPolylineCoords[0].latitude = 30.339140;
    coloredPolylineCoords[0].longitude = 120.109537;
    
    coloredPolylineCoords[1].latitude = 30.339240;
    coloredPolylineCoords[1].longitude = 120.119537;
    
    coloredPolylineCoords[2].latitude = 30.334340;
    coloredPolylineCoords[2].longitude = 120.109537;
    
    coloredPolylineCoords[3].latitude = 30.341140;
    coloredPolylineCoords[3].longitude = 120.119537;
    
    coloredPolylineCoords[4].latitude = 30.339140;
    coloredPolylineCoords[4].longitude = 120.109537;
  
    /* 构建tracking. */
    self.tracking = [[Tracking alloc] initWithCoordinates:coloredPolylineCoords count:5];
    self.tracking.delegate = self;
    self.tracking.mapView  = self.mapView;
    self.tracking.duration = 5.f;
    self.tracking.edgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
}


/*定位用户位置*/
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f; reGeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, reGeocode.formattedAddress);
    [self.dataArr addObject:location];
    
    //设置大头针的经纬度
    if (!self.pointAnnotaiton) {
        self.pointAnnotaiton = [[MAPointAnnotation alloc] init];
        [self.pointAnnotaiton setCoordinate:location.coordinate];
        [self.mapView addAnnotation:_pointAnnotaiton];
        
    }
    
    
    [self.pointAnnotaiton setCoordinate:location.coordinate];
    self.pointAnnotaiton.title = @"杭州市";
    self.pointAnnotaiton.subtitle = reGeocode.formattedAddress;
    //获取定位到的信息
    NSString *detailStr = [NSString stringWithFormat:@"latitude=%f longitude=%f  %@", location.coordinate.latitude, location.coordinate.longitude,reGeocode.formattedAddress];
    
    //    NSLog(@"%@---%@---%@--%@--%@---%@--%@", reGeocode.formattedAddress,  reGeocode.country, reGeocode.province ,reGeocode.city, reGeocode.district, reGeocode.number, reGeocode.street);
    
    self.detailLabel.text = detailStr;
    
    //重新设置地图中心点
    [self.mapView setCenterCoordinate:location.coordinate];
    [self.mapView setZoomLevel:15.1 animated:NO];
}



#pragma mark - MAMapViewDelegate
/*绘制路径*/
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.strokeColor = [UIColor  colorWithRed:0 green:1 blue:0 alpha:0.6];
        polylineRenderer.lineWidth   = 5.f;
        
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType  = kMALineCapRound;
      
        return polylineRenderer;
    }
    
    return nil;
}



/*大头针自定义代理*/
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        
        /*判断是带动画的大头针, 可以平移*/
        if ([annotation isKindOfClass:[MAAnimatedAnnotation class]]) {
            annotationView.image = [UIImage imageNamed:@"icon_location.png"];
        }
        
        /*轨迹回放大头针*/
        if (annotation == self.tracking.annotation)
        {
            annotationView.image = [UIImage imageNamed:@"ball"];
        }
        
        return annotationView;
    }
    return nil;
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
