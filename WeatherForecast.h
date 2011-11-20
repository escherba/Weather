//
//  WeatherForecast.h
//  Weather
//
//  Created by Eugene Scherba on 1/14/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherModel.h"

@class MainViewController;


@interface WeatherForecast : NSObject {

	// Parent View Controller
	MainViewController *viewController;
	
	// Google Weather Service
	NSMutableData *responseData;
	NSURL *theURL;
}

@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *date;

@property (nonatomic, retain) RSCondition *condition;
@property (nonatomic, retain) NSMutableArray *days;

- (void)queryService:(CLLocationCoordinate2D)coord
        withParent:(UIViewController *)controller;

@end
