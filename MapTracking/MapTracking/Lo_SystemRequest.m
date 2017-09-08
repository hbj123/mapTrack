//
//  Lo_SystemRequest.m
//  MapTracking
//
//  Created by hbj on 2017/9/6.
//  Copyright © 2017年 保健. All rights reserved.
//

#import "Lo_SystemRequest.h"

@implementation Lo_SystemRequest

+ (Lo_SystemRequest *)shareLo_SystemRequest {
    static Lo_SystemRequest *system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        system = [[Lo_SystemRequest alloc] init];
    });
    return system;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initCompleteBlock];
        [self configLocationManager];
    }
    return self;
}



#pragma mark - Initialization

- (void)initCompleteBlock
{
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error != nil && error.code == AMapLocationErrorLocateFailed)
        {
            //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"定位错误:{%ld - %@};", (long)error.code, error.localizedDescription);
            return;
        }
        else if (error != nil
                 && (error.code == AMapLocationErrorReGeocodeFailed
                     || error.code == AMapLocationErrorTimeOut
                     || error.code == AMapLocationErrorCannotFindHost
                     || error.code == AMapLocationErrorBadURL
                     || error.code == AMapLocationErrorNotConnectedToInternet
                     || error.code == AMapLocationErrorCannotConnectToHost))
        {
            //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
            NSLog(@"逆地理错误:{%ld - %@};", (long)error.code, error.localizedDescription);
        }
        else
        {
            //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
        }
        
        //取出用户位置
        self.userLocation = location;
        //取出用户的逆地理位置
        self.userRegeocode = regeocode;
        
        if (regeocode)
        {
            self.ampBlock(location, regeocode);
            self.displayAddress = [NSString stringWithFormat:@"%@ \n %@-%@-%.2fm", regeocode.formattedAddress,regeocode.citycode, regeocode.adcode, location.horizontalAccuracy];
        }
        else
        {
            self.ampBlock(location, nil);
            self.displayAddress = [NSString stringWithFormat:@"lat:%f;lon:%f \n accuracy:%.2fm", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy];
        }
    };
}



#pragma mark - Action Handle

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
    [self.locationManager setLocationTimeout:10];
    
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:5];
}


- (void)reGeocodeAction
{
    //进行单次带逆地理定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

@end
