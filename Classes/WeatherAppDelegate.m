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

@implementation WeatherAppDelegate

@synthesize window;
@synthesize mainViewController;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

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


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    [locationManager release];
    locationManager = nil;
    [locationManagerStartDate release];
    locationManagerStartDate = nil;
    [mainViewController release];
    mainViewController = nil;
    [window release];
    window = nil;
    [super dealloc];
}

#pragma mark - wrappers for CDLocationManagerDelegate methods

// wrapper with callback
-(void)startUpdatingLocation:(id)obj withCallback:(SEL)selector
{
    callbackObject = obj;
    callBackselector = selector;
    [locationManager startUpdatingLocation];
}

// this is a simple wrapper...
-(void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
}

#pragma mark - CDLocationManager methods

- (void)locationManager:(CDLocationManager *) manager
    didUpdateToLocation:(CLLocation *)location
{
    //if (![self isValidLocation:newLocation withOldLocation:oldLocation]) {
    //    return;
    //}
    [callbackObject performSelector:callBackselector withObject:location];
}

-(void)locationManager:(CDLocationManager *) manager
      didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
}

@end
