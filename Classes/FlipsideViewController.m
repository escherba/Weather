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
#import "RSAddGeo.h"

@implementation FlipsideViewController

@synthesize addCity;
@synthesize delegate;
@synthesize tableContents;
@synthesize sortedKeys;

- (void)geoAddControllerDidFinish:(RSAddGeo *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    if (!appDelegate) {
        appDelegate = (WeatherAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    toggleSwitch.on = [[appDelegate.defaults objectForKey:@"checkLocation"] boolValue];
    
    // add City view controller
    geoAddController = [[RSAddGeo alloc] initWithNibName:@"RSAddGeo" bundle:nil];
    geoAddController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    geoAddController.delegate = self;
}

- (IBAction)done:(id)sender {
    [appDelegate.defaults setObject:[NSNumber numberWithBool:toggleSwitch.on] forKey:@"checkLocation"];
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)switchThrown {
    if (toggleSwitch.on) {
        [appDelegate.locationManager startUpdatingLocation];
    } else {
        [appDelegate.locationManager stopUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [geoAddController release];
    geoAddController = nil;
}

- (IBAction)addCityTouchDown {
    // present modal view controller
    [self presentModalViewController:geoAddController animated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
    [geoAddController release];
    [toggleSwitch release];
    [super dealloc];
}


@end
