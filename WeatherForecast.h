//
//  WeatherForecast.h
//  Weather
//
//  Created by Eugene Scherba on 1/14/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WeatherModel.h"
#import "WeatherAppDelegate.h"

@class WeatherForecast;

@protocol WeatherForecastDelegate
- (void)weatherForecastDidFinish:(WeatherForecast *)sender;
@end

@interface WeatherForecast : NSObject {
	// Google Weather Service
	NSMutableData *responseData;
	NSURL *theURL;
    NSURLConnection *apiConnection;

    WeatherAppDelegate *appDelegate;
    BOOL pendingRequest;
    NSInteger operationCount;
}

//@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSDate* timestamp;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) RSCurrentCondition *condition;
@property (nonatomic, retain) NSMutableArray *days;
@property (nonatomic, assign) id <WeatherForecastDelegate> delegate; // don't retain delegates

// Public method: queryService
- (void)queryService:(CLLocationCoordinate2D)coord;

@end
