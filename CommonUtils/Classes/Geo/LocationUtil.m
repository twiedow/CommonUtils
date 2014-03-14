//
//  LocationUtil.m
//  CommonUtils
//
//  Created by twiedow on 14.03.14.
//  Copyright (c) 2014 twiedow. All rights reserved.
//

#import "LocationUtil.h"


@interface LocationUtil () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastCurrentLocation;

@end


@implementation LocationUtil


+ (instancetype)sharedLocationUtil {
	static dispatch_once_t onceToken;
	static LocationUtil *sharedLocationUtil;

	dispatch_once(&onceToken, ^{
		sharedLocationUtil = [[LocationUtil alloc] init];
	});

	return sharedLocationUtil;
}


- (void)startLocationUpdates {
	if (self.locationManager == nil && [CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.pausesLocationUpdatesAutomatically = YES;
		self.locationManager.distanceFilter = 100.0;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
		self.locationManager.delegate = self;
		[self.locationManager startUpdatingLocation];
	}
}


- (void)stopLocationUpdates {
	if (self.locationManager != nil) {
		[self.locationManager stopUpdatingLocation];
		self.locationManager = nil;
	}
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = locations.lastObject;

	if (location.horizontalAccuracy >= 0)
		self.lastCurrentLocation = location;
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self stopLocationUpdates];
}

@end
