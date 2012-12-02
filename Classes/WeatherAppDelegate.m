//
//  WeatherAppDelegate.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//
//  Also serves as a delegate to CDLocationManager

#import "WeatherAppDelegate.h"
#import "MainViewController.h"
#import "WeatherForecast.h"
#include "sunriset.h"

@implementation WeatherAppDelegate

@synthesize window;
@synthesize mainViewController;
@synthesize findNearby;
@synthesize currentLocation;
@synthesize wsymbols;
@synthesize calendar;
//@synthesize operationQueue;

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // important initialization done here
    currentLocation = nil;
    
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // initialize table of weather conditions
    NSBundle* bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"icons" ofType:@"plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSLog(@"file %@ does not exist", path);
    }
    wsymbols = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    for (id key in wsymbols) {
        NSMutableArray *arr = (NSMutableArray *)[wsymbols objectForKey:key];
        NSString *dayIconName = [arr objectAtIndex:1];
        NSString *nightIconName = [arr objectAtIndex:2];
        NSString *dayIconPath64 = [bundle pathForResource:dayIconName ofType:@"png" inDirectory:@"wsymbols01_png_64"];
        NSString *nightIconPath64 = [bundle pathForResource:nightIconName ofType:@"png" inDirectory:@"wsymbols01_png_64"];
        NSString *dayIconPath128 = [bundle pathForResource:dayIconName ofType:@"png" inDirectory:@"wsymbols01_png_128"];
        NSString *nightIconPath128 = [bundle pathForResource:nightIconName ofType:@"png" inDirectory:@"wsymbols01_png_128"];
        [arr addObject:dayIconPath64];
        [arr addObject:nightIconPath64];
        [arr addObject:dayIconPath128];
        [arr addObject:nightIconPath128];
    }
    
    // Create operation queue
    //operationQueue = [NSOperationQueue new];
    // set maximum operations possible
    //[operationQueue setMaxConcurrentOperationCount:3];
    
    findNearby = [[FindNearbyPlace alloc] init];
    findNearby.delegate = mainViewController;
    
    // Create instance of LocationManager object
    locationManager = [[CDLocationManager alloc] init];
    locationManager.delegate = self;
    locationManagerStartDate = [[NSDate date] retain];
    
    // Add the main view controller's view to the window and display.
    // http://stackoverflow.com/a/12398777/597371
    // In order to prevent the error in debug area, "Applications are expected to have
    // root view controller at the end of application launch", replacing the line below
    // with the following:
    //[self.window addSubview:mainViewController.view];
    [self.window setRootViewController:mainViewController];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [locationManager stopUpdatingLocation];
    NSLog(@"UIApplication applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    //TODO: invalidate timer here?
    NSLog(@"UIApplication applicationDidEnterBackground");
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    NSLog(@"UIApplication applicationWillEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [locationManager startUpdatingLocation];
    NSLog(@"UIApplication applicationDidBecomeActive");
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    NSLog(@"UIApplication applicationWillTerminate");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    NSLog(@"UIApplication applicationDidReceiveMemoryWarning");
}

- (void)dealloc
{
    //[operationQueue release],           operationQueue = nil;
    [calendar release],                 calendar = nil;
    [wsymbols release],                 wsymbols = nil;
    [currentLocation release],          currentLocation = nil;
    [findNearby release],               findNearby = nil;
    [locationManager release],          locationManager = nil;
    [locationManagerStartDate release], locationManagerStartDate = nil;
    [mainViewController release],       mainViewController = nil;
    [window release],                   window = nil;
    [super dealloc];
}

#pragma mark - wrappers for CDLocationManagerDelegate methods

// wrapper with callback
//-(void)startUpdatingLocation:(id)obj withCallback:(SEL)selector
//{
//    NSLog(@"....Starting location tracking");
//    callbackObject = obj;
//    callBackselector = selector;
//    [locationManager startUpdatingLocation];
//}

#pragma mark - CDLocationManager methods

- (void)locationManager:(CDLocationManager *) manager
    didUpdateToLocation:(CLLocation *)location
{
    NSLog(@"locationManager didUpdateToLocation");
    if ([self isValidLocation:location withOldLocation:currentLocation]) {
        [currentLocation release];
        currentLocation = [location retain];
        NSLog(@"Got coord: lat=%f, long=%f", location.coordinate.latitude, location.coordinate.longitude);
        [mainViewController currentLocationDidUpdate:location];
    } else {
        NSLog(@"Bad location: lat=%f, long=%f", location.coordinate.latitude, location.coordinate.longitude);
    }
}

-(void)locationManager:(CDLocationManager *) manager
      didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError: %@", [error description]);
}

#pragma mark - internals
/*
 * validating location data according to:
 * http://troybrant.net/blog/2010/02/detecting-bad-corelocation-data/
 */
- (BOOL)isValidLocation:(CLLocation *)newLocation
        withOldLocation:(CLLocation *)oldLocation
{
    // Filter out nil locations
    if (!newLocation) {
        return NO;
    }
    
    // Filter out points by invalid accuracy
    if (newLocation.horizontalAccuracy < 0) {
        return NO;
    }
    
    // Filter out points that are out of order
    NSTimeInterval secondsSinceLastPoint =
    [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    if (secondsSinceLastPoint < 0) {
        return NO;
    }
    
    // Filter out points created before the manager was initialized
    NSTimeInterval secondsSinceManagerStarted =
    [newLocation.timestamp timeIntervalSinceDate:locationManagerStartDate];
    if (secondsSinceManagerStarted < 0) {
        return NO;
    }
    
    // The newLocation is good to use
    return YES;
}

- (NSDate*)dateFromHour:(double)rise_set components:(NSDateComponents*)argComps
{
    // used by getSunPositionWithCoord
    NSDateComponents *comps = [argComps copy];
    NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [comps setTimeZone:utc];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate* date_begin = [calendar dateFromComponents:comps];
    [comps release];
    
    NSDate* date_rise_set = [date_begin dateByAddingTimeInterval:(rise_set * 3600.0f)];
    
    // for debugging
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setLocale:[NSLocale currentLocale]];
    //[formatter setDateStyle:NSDateFormatterMediumStyle];
    //[formatter setTimeStyle:NSDateFormatterMediumStyle];
    //NSLog(@"~~ Sunrise/sunset at: %@", [formatter stringFromDate:date_rise_set]);
    //[formatter release];
    //end debugging
    
    return date_rise_set;
}

-(NSInteger)getSunPositionWithCoord:(CLLocationCoordinate2D)coord
{
    double rise = 0.0f;
    double set = 0.0f;
    
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    NSInteger day = [dateComponents day];
    int result = sun_rise_set(year, month, day, coord.longitude, coord.latitude, &rise, &set);
    
    NSInteger intSunPosition;
    if (result == 0) {
        //  0 - sun rises/sets this day, times stored in rise and set
        //double dayLength = (set - rise) * 3600.0f;
        double dayLength = day_length(year, month, day, coord.longitude, coord.latitude) * 3600.0f;
        
        NSDate *sunrise = [self dateFromHour:rise components:dateComponents];
        NSDate *sunset = [self dateFromHour:set components:dateComponents];
        NSTimeInterval sunriseSinceNow = [sunrise timeIntervalSinceNow];
        NSTimeInterval sunsetSinceNow = [sunset timeIntervalSinceNow];
        NSLog(@"Sunrise at %f, sunset at %f", rise, set);
        NSLog(@"sunriseSinceNow at %f, sunsetSinceNow at %f", sunriseSinceNow, sunsetSinceNow);
        
        if (sunriseSinceNow < 0.0f) {
            // find remainder of the time since last sunset (when divided by 24*3600) and
            // compare it with the length of day.
            double secondsSinceSunrise = fmod(fabs(sunriseSinceNow), (double)(24*3600));
            intSunPosition = (secondsSinceSunrise <= dayLength) ? 1 : -1;
        } else {
            // we are asserting that sunset always follows sunrise, so when sunrise is
            // positive, sunset should be an even larger number. We find remainder of that
            // number when divided by (24 * 3600) and compare it with day length.
            double secondsTilSunset = fmod(fabs(sunsetSinceNow), (double)(24*3600));
            intSunPosition = (secondsTilSunset <= dayLength) ? 1 : -1;
        }
    } else {
        // +1 - sun above ground all day (polar summer)
        // -1 - sun below ground all day (polar winter)
        intSunPosition = result;
    }
    return intSunPosition;
}

@end
