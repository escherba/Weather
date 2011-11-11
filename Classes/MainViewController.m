//
//  MainViewController.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

@synthesize forecast;
@synthesize loadingActivityIndicator;
@synthesize location;

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (IBAction)refreshView:(id)sender {
	[loadingActivityIndicator startAnimating];
	[forecast queryService:@"Boston,MA" withParent:self];
}

- (void)updateView {
	
	// City and Date
	nameLabel.text = forecast.location;
	dateLabel.text = forecast.date;
	
	// Now
	nowTempLabel.text = forecast.temp;
	nowHumidityLabel.text = forecast.humidity;
	nowWindLabel.text = forecast.wind;
	nowConditionLabel.text = forecast.condition;
	NSURL *url = [NSURL URLWithString:(NSString *)forecast.icon];
	NSData *data = [NSData dataWithContentsOfURL:url];
	[nowImage.image release];
	nowImage.image = [[UIImage alloc] initWithData:data];
	
	// Day 1
	dayOneLabel.text = [forecast.days objectAtIndex:0];
	dayOneTempLabel.text = [forecast.temps objectAtIndex:0];
	dayOneChanceLabel.text = [forecast.conditions objectAtIndex:0];
	url = [NSURL URLWithString:(NSString *)[forecast.icons objectAtIndex:0]];
	data = [NSData dataWithContentsOfURL:url];
	[dayOneImage.image release];
	dayOneImage.image = [[UIImage alloc] initWithData:data];
	
	// Day 2
	dayTwoLabel.text = [forecast.days objectAtIndex:1];
	dayTwoTempLabel.text = [forecast.temps objectAtIndex:1];
	dayTwoChanceLabel.text = [forecast.conditions objectAtIndex:1];
	url = [NSURL URLWithString:(NSString *)[forecast.icons objectAtIndex:1]];
	data = [NSData dataWithContentsOfURL:url];
	[dayTwoImage.image release];
	dayTwoImage.image = [[UIImage alloc] initWithData:data];
	
	// Day 3
	dayThreeLabel.text = [forecast.days objectAtIndex:2];
	dayThreeTempLabel.text = [forecast.temps objectAtIndex:2];
	dayThreeChanceLabel.text = [forecast.conditions objectAtIndex:2];
	url = [NSURL URLWithString:(NSString *)[forecast.icons objectAtIndex:2]];
	data = [NSData dataWithContentsOfURL:url];
	[dayThreeImage.image release];
	dayThreeImage.image = [[UIImage alloc] initWithData:data];

	// Day 4
	dayFourLabel.text = [forecast.days objectAtIndex:3];
	dayFourTempLabel.text = [forecast.temps objectAtIndex:3];
	dayFourChanceLabel.text = [forecast.conditions objectAtIndex:3];
	url = [NSURL URLWithString:(NSString *)[forecast.icons objectAtIndex:3]];
	data = [NSData dataWithContentsOfURL:url];
	[dayFourImage.image release];
	dayFourImage.image = [[UIImage alloc] initWithData:data];
	
	[loadingActivityIndicator stopAnimating];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    location = [[NSString alloc] init];
	[self refreshView:self];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	
    [location release];
	[loadingActivityIndicator release];
	
	[nameLabel release];
	[dateLabel release];
	
	[nowImage release];
	[nowTempLabel release];
	[nowHumidityLabel release];
	[nowWindLabel release];
	[nowConditionLabel release];
	
	[dayOneLabel release];
	[dayOneImage release];
	[dayOneTempLabel release];
	[dayOneChanceLabel release];
	
	[dayTwoLabel release];
	[dayTwoImage release];
	[dayTwoTempLabel release];
	[dayTwoChanceLabel release];
	
	[dayThreeLabel release];
	[dayThreeImage release];
	[dayThreeTempLabel release];
	[dayThreeChanceLabel release];
	
	[dayFourLabel release];
	[dayFourImage release];
	[dayFourTempLabel release];
	[dayFourChanceLabel release];
    
	[super dealloc];
}

@end




