//
//  WeatherAppDelegate.h
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDLocationManager.h"
#import "FindNearbyPlace.h"

@class MainViewController;

@interface WeatherAppDelegate : NSObject <UIApplicationDelegate, CDLocationManagerDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
    
    FindNearbyPlace *findNearby;
    CLLocation *currentLocation;
    CDLocationManager *locationManager;
    NSDate *locationManagerStartDate;
    
    id callbackObject;
    SEL callBackselector;
}

-(void)startUpdatingLocation:(id)obj withCallback:(SEL)selector;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) FindNearbyPlace* findNearby;
@property (nonatomic, retain, readonly) CLLocation *currentLocation;
@property (nonatomic, retain, readonly) NSMutableDictionary *wsymbols;
@property (nonatomic, retain, readonly) NSCalendar *calendar;
//@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end
