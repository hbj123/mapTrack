//
//  Lo_SystemRequest.h
//  MapTracking
//
//  Created by hbj on 2017/9/6.
//  Copyright © 2017年 保健. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AMPBlock)(CLLocation *userLocation, AMapLocationReGeocode *userRegeocode);
@interface Lo_SystemRequest : NSObject <AMapLocationManagerDelegate>
//地图定位
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
@property (nonatomic, retain) NSString *displayAddress;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, retain) AMapLocationReGeocode *userRegeocode;
/*回调定位信息*/
@property (nonatomic, copy) AMPBlock ampBlock;

/**
 *  单利类创建
 */
+ (Lo_SystemRequest *)shareLo_SystemRequest;
//进行单次带逆地理定位请求
- (void)reGeocodeAction;


@end
