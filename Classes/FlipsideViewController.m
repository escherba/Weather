//
//  FlipsideViewController.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "WeatherAppDelegate.h"
#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        appDelegate = (WeatherAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    toggleSwitch.on = appDelegate.updateLocation;
}


- (IBAction)done:(id)sender {
    appDelegate.updateLocation = toggleSwitch.on;
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)switchThrown {
    if (!appDelegate) {
        appDelegate = (WeatherAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    if (appDelegate) {
        NSLog(@"ok");
        
        if (toggleSwitch.on) {
            NSLog(@"on");
            [appDelegate.locationManager startUpdatingLocation];
        } else {
            NSLog(@"off");
            [appDelegate.locationManager stopUpdatingLocation];
        }
    } else {
        NSLog(@"appDelegate evaluates to false");
    }
    NSLog(@"finished switch thrown");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
    [toggleSwitch release];
    [super dealloc];
}


@end
