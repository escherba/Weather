//
//  WeatherAppDelegate.h
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MainViewController;

@interface WeatherAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
    
    NSUserDefaults *defaults;
    CLLocationManager *locationManager;
    NSDate *locationManagerStartDate;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) NSUserDefaults* defaults;
@property (nonatomic, retain) CLLocationManager* locationManager;
//@property (nonatomic, retain) NSString* nearbyLocationName;

- (BOOL)isValidLocation:(CLLocation *)newLocation
        withOldLocation:(CLLocation *)oldLocation;

@end

