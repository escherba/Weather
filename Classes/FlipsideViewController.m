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
#import "JSONKit.h"

@implementation FlipsideViewController

@synthesize addCity;
@synthesize delegate;
@synthesize tableContents;

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    if (!appDelegate) {
        appDelegate = (WeatherAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    //toggleSwitch.on = [[appDelegate.defaults objectForKey:@"checkLocation"] boolValue];
    
    // add City view controller
    geoAddController = [[RSAddGeo alloc] initWithNibName:@"RSAddGeo" bundle:nil];
    geoAddController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    geoAddController.delegate = self;

    // initialize model dictionary by using model array in the delegate object
    modelDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *modelArray = self.delegate.modelArray;
    for (RSLocality* locality in modelArray) {
        [modelDict setObject:locality forKey:[locality apiId]];
    }

    tableContents = [[NSMutableDictionary alloc] init];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setEditing: YES];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)dealloc
{
    // private variables
    [theURL release];
    [apiConnection release];
    [responseData release];
    [modelDict release];
    [theURL release];
    
    [geoAddController release];
    [_tableView release];
    [tableContents release];

    [super dealloc];
}

#pragma mark - Internals
- (void)geoAddControllerDidFinish:(RSAddGeo *)controller
{
    // capture controller.selectedLocation
    RSLocality* selectedLocality = controller.selectedLocality;
    if (selectedLocality) {
        
        // setting empty string for now
        [tableContents setObject:@"" forKey:[selectedLocality description]];
        
        // add location to model array and also append a page to the view
        // TODO: consider joining the two methods into one delegate call
        [self.delegate.modelArray addObject:selectedLocality];
        [self.delegate addPageWithLocality:selectedLocality];
        [self.delegate syncDefaults];
        
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_tableView numberOfRowsInSection:1] inSection:1]];
        [_tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
        [_tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
        
        // Also place selectedLocality into a mutable dictionary
        _currentLocalityId = [selectedLocality apiId];
        [modelDict setObject:selectedLocality forKey:_currentLocalityId];
        
        [responseData release];
        responseData = [[NSMutableData data] retain];
        
        // Perform a details request to get Latitude and Longitude data
        theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc", [selectedLocality reference]]];
        apiConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self startImmediately: YES];
    }
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - actions

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    //    if (toggleSwitch.on) {
    //        [appDelegate.locationManager startUpdatingLocation];
    //    } else {
    //        [appDelegate.locationManager stopUpdatingLocation];
    //    }
}

- (IBAction)done:(id)sender {
    //[appDelegate.defaults setObject:[NSNumber numberWithBool:toggleSwitch.on] forKey:@"checkLocation"];
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)addCityTouchDown {
    // present modal view controller
    //[self presentModalViewController:geoAddController animated:YES];
    [self presentViewController:geoAddController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == 0) {
        // first section only displays switch to toggle location tracking
        return 1;
    } else {
        return [self.delegate.modelArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RSLocality *locality;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch(indexPath.section) {
            case 0:
                // Current location
                if (indexPath.row == 0) {
                    
                    // add a UISwitch control on the right
                    cell.textLabel.text = @"Use Current Location:";
                    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [switchView setOn:NO animated:NO];
                    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = switchView;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [switchView release];
                }
                break;
            case 1:
                
                // Other locations
                locality = [self.delegate.modelArray objectAtIndex:indexPath.row];
                cell.textLabel.text = [locality description];
                break;
        }
    } else {
        if (indexPath.section == 1) {
            locality = [self.delegate.modelArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [locality description];
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1) ? YES : NO;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && editingStyle == UITableViewCellEditingStyleDelete) {
        // remove the row
        NSInteger row = indexPath.row;
        RSLocality *locality = [self.delegate.modelArray objectAtIndex:indexPath.row];
        [tableContents removeObjectForKey:[locality description]];
        
        // modify main model and view
        [self.delegate.modelArray removeObjectAtIndex:row];
        [self.delegate removePage:row];
        [self.delegate syncDefaults];
        
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1) 
    ? UITableViewCellEditingStyleDelete 
    : UITableViewCellEditingStyleNone;
}


#pragma mark - NSURLConnection delegate methods

- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse
{
	[theURL autorelease];
	theURL = [[request URL] retain];
	return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Deal with result returned by autocomplete API
    JSONDecoder* parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *data = [parser objectWithData:responseData];
    if (!data) {
        return;
    }
    NSString *status = [data objectForKey:@"status"];
    if (!status || ![status isEqualToString:@"OK"]) {
        return;
    }
    NSDictionary *result = [data objectForKey:@"result"];
    if (!result) {
        return;
    }
    
    // id: _currentLocalityId
    RSLocality *locality = [modelDict objectForKey:_currentLocalityId];
    locality.formatted_address = [result objectForKey:@"formatted_address"];
    locality.name = [result objectForKey:@"name"];
    locality.vicinity = [result objectForKey:@"vicinity"];
    locality.url = [result objectForKey:@"url"];
    NSDictionary *location = [[result objectForKey:@"geometry"] objectForKey:@"location"];
    CLLocationCoordinate2D coord2d;
    coord2d.latitude = [[location objectForKey:@"lat"] doubleValue];
    coord2d.longitude = [[location objectForKey:@"lng"] doubleValue];
    locality.coord = coord2d;
    
    //cleanup
    [responseData release];
    responseData = nil;
}

@end
