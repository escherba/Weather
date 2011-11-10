//
//  WeatherAppDelegate.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import "WeatherAppDelegate.h"
#import "MainViewController.h"
#import "WeatherForecast.h"

@implementation WeatherAppDelegate


@synthesize window;
@synthesize mainViewController;
@synthesize updateLocation;
@synthesize locationManager;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    /*
	MainViewController *aController = 
	  [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];*/
	
    // Create instance of LocationManager object
    NSLog(@"Creating locationManager");
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    
    // Override point for customization after application launch.  
	WeatherForecast *forecast = [[WeatherForecast alloc] init];
	self.mainViewController.forecast = forecast;
	[forecast release];
	
    // Add the main view controller's view to the window and display.
    [self.window addSubview:mainViewController.view];
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


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    [locationManager release];
    [mainViewController release];
    [window release];
    [super dealloc];
}


# pragma mark CLLocationManager methods

- (void)locationManager:(CLLocationManager *) manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location: %@", [newLocation description]);
    if (newLocation != oldLocation) {
        [self.mainViewController.loadingActivityIndicator startAnimating];
    }
}

-(void)locationManager:(CLLocationManager *) manager
      didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
}

@end
