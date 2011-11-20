//
//  MainViewController.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "WeatherAppDelegate.h"
#import "WeatherModel.h"
//#import "FlipsideViewController.h"

@implementation MainViewController

@synthesize forecast;
@synthesize loadingActivityIndicator;
@synthesize locationName;

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender {    
	[self presentModalViewController:flipsideController animated:YES];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (IBAction)refreshView:(id)sender {
	[loadingActivityIndicator startAnimating];
    if ( [appDelegate.defaults objectForKey:@"checkLocation"] ) {
        //[forecast queryService:[[appDelegate.locationManager location] coordinate] withParent:self];
        CLLocation* defaultLocation = [[CLLocation alloc] initWithLatitude:42.500453028125584 longitude:-71.0595703125];
        [forecast queryService:[defaultLocation coordinate] withParent:self];
        [defaultLocation release];
    } else {
        CLLocation* defaultLocation = [[CLLocation alloc] initWithLatitude:42.500453028125584 longitude:-71.0595703125];
        [forecast queryService:[defaultLocation coordinate] withParent:self];
        [defaultLocation release];
    }
}

- (void)updateView {
	
	// City and Date
	nameLabel.text = locationName;
	dateLabel.text = forecast.date;
   
	// Now
	nowTempLabel.text = [forecast.condition formatTemperature];
	nowHumidityLabel.text = forecast.condition.humidity;
	nowWindLabel.text = forecast.condition.wind;
	nowConditionLabel.text = forecast.condition.condition;
	nowImage.image = forecast.condition.iconData;

    [_tableView reloadData];

	[loadingActivityIndicator stopAnimating];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    locationName = [[NSString alloc] init];
    appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];

    // flipside controller
    flipsideController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	flipsideController.delegate = self;
	flipsideController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    weekdayFormatter = [[NSDateFormatter alloc] init];
    [weekdayFormatter setDateFormat: @"EEEE"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [flipsideController release];
    flipsideController = nil;
    
    [super viewDidUnload];
    [locationName release];
    [weekdayFormatter release];
    _tableView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self refreshView:self];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
    [flipsideController release];
    
    [weekdayFormatter release];
    [locationName release];
	[loadingActivityIndicator release];
	
	[nameLabel release];
	[dateLabel release];
	
	[nowImage release];
	[nowTempLabel release];
	[nowHumidityLabel release];
	[nowWindLabel release];
	[nowConditionLabel release];

    [_tableView release];

	[super dealloc];
}

#pragma mark - UITableViewDelegate methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.forecast.days count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Configure the cell.
    if ([tableView isEqual:_tableView]) {
        RSDay* day = [self.forecast.days objectAtIndex:indexPath.row];
        NSString *title = [[NSString alloc] initWithFormat:@"%@: %@", [weekdayFormatter stringFromDate:day.date], [day getHiLo]]; 
        cell.textLabel.text = title;
        [title release];
        
        cell.detailTextLabel.text = day.condition;
        cell.imageView.image = day.iconData;
    }
    return cell;
}

@end




