//
//  WeatherAppDelegate.h
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDLocationManager.h"

@class MainViewController;

@interface WeatherAppDelegate : NSObject <UIApplicationDelegate, CDLocationManagerDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
    
    CDLocationManager *locationManager;
    NSDate *locationManagerStartDate;
    
    id callbackObject;
    SEL callBackselector;
}

-(void)startUpdatingLocation:(id)obj withCallback:(SEL)selector;
-(void)stopUpdatingLocation;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end

