//
//  FlipsideViewController.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "WeatherAppDelegate.h"
#import "MainViewController.h"
#import "FlipsideViewController.h"
#import "RSAddGeo.h"
#import "JSONKit.h"

@implementation FlipsideViewController

@synthesize delegate;
@synthesize modelDict;

#pragma mark - Lifecycle
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nibBundle]) {
        // we need to initialize modelDict early so that we can operate on it
        // from the parent controller before this class' viewDidLoad is called.
        modelDict = [[NSMutableDictionary alloc] init];
        
        theURL = nil;
        responseData = nil;
        apiConnection = nil;
        _requestedLocalityId = nil;
    }
    return self;
}

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

    // switch to toggle whether current location page is showed
    switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    [switchView setOn:self.delegate.showCurrentLocation animated:NO];
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    // temperature units control
	NSArray *itemArray = [NSArray arrayWithObjects: @"F/miles", @"C/km", nil];
	segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
	segmentedControl.frame = CGRectMake(0, 0, 100, 20); //CGRectZero;
	segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedControl.selectedSegmentIndex = (self.delegate.useImperial == YES) ? 0 : 1;
	[segmentedControl addTarget:self
	                     action:@selector(unitsChanged:)
	           forControlEvents:UIControlEventValueChanged];
    
    // table listing cities/locations selected by user
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setEditing:YES animated:NO];
    [self.view addSubview:_tableView];
    //[_tableView release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    // private variables
    [theURL release],               theURL = nil;
    [apiConnection release],        apiConnection = nil;
    [responseData release],         responseData = nil;
    [modelDict release],            modelDict = nil;
    [geoAddController release],     geoAddController = nil;
    [switchView release],           switchView = nil;
    [segmentedControl release],     segmentedControl = nil;
    [_tableView release],           _tableView = nil;
    [_requestedLocalityId release], _requestedLocalityId = nil;
    [super dealloc];
}

#pragma mark - Internals
- (void)geoAddControllerDidFinish:(RSAddGeo *)controller
{
    // capture controller.selectedLocation
    RSLocality* selectedLocality = controller.selectedLocality;
    if (!selectedLocality) {
        // simply dismiss view controller and exit
        [responseData release];
        responseData = [[NSMutableData data] retain];
        
        //[self dismissModalViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    // We keep _requestedLocalityId as a temporary variable to be reused when
    // the new connection finishes
    [_requestedLocalityId release];
    _requestedLocalityId = [[selectedLocality apiId] retain];
    RSLocality* currentLocality = [modelDict objectForKey:_requestedLocalityId];
    if (currentLocality) {
        [currentLocality updateFrom:selectedLocality];
    } else {

        // if locality id not in the dictionary,
        // append it there as well as to the array
        [modelDict setObject:selectedLocality forKey:_requestedLocalityId];
        [self.delegate addPageWithLocality:selectedLocality];
        currentLocality = selectedLocality;
        
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_tableView numberOfRowsInSection:1] inSection:1]];
        [_tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
        [_tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    }

    [responseData release];
    responseData = [[NSMutableData data] retain];

    if (!currentLocality.haveCoord) {
        // Perform a details request to get Latitude and Longitude data
        [theURL release];
        theURL = [[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc", [currentLocality reference]]] retain];
        
        [apiConnection release];
        apiConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self startImmediately: YES];
    }
    
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - actions

- (void) switchChanged:(id)sender
{
    //self.delegate.showCurrentLocation = switchView.on;
    UISwitch *switchFromSender = (UISwitch*)sender;
    [self.delegate locationSwitchSetTo:switchFromSender.on];
}

//Action method executes when user touches the button
- (void) unitsChanged:(id)sender
{
	UISegmentedControl *segmentedControlFromSender = (UISegmentedControl *)sender;
    NSInteger selectedIndex = [segmentedControlFromSender selectedSegmentIndex];
    [self.delegate unitsChangedSetToImperial:(selectedIndex == 0)];
}

- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)addCityTouchDown {
    // with animated:NO, the view loads a bit faster
    [self presentViewController:geoAddController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    switch (section) {
        case 0:
            // first section only displays switch to toggle location tracking
            return 1;
            break;
        case 1:
            return [delegate permanentLocalityCount];
            break;
        case 2:
            return 1; // temperature control
            break;
        default:
            break;
    }
    [NSException raise:@"Invalid section value" format:@"section of %d is invalid", section];
    return -1;
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
                    cell.textLabel.text = @"Current Location:";
                    cell.accessoryView = switchView;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                break;
            case 1:
                
                // Other locations
                locality = [self.delegate getPermanentLocalityByRow:indexPath.row];
                cell.textLabel.text = [locality description];
                break;
            case 2:
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"Units:";
                    segmentedControl.frame = CGRectMake(0, 0, 200, cell.frame.size.height - 8);
                    cell.accessoryView = segmentedControl;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                break;
            default:
                [NSException raise:@"Invalid section value" format:@"section of %d is invalid", indexPath.section];
                break;
        }
    } else {
        if (indexPath.section == 1) {
            locality = [self.delegate getPermanentLocalityByRow:indexPath.row];
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
    if (indexPath.section == 1 && editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"Asking MVC delegate to remove page at index %u", indexPath.row);
        [self.delegate removePage:indexPath.row];

        // remove the row
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1) 
    ? UITableViewCellEditingStyleDelete 
    : UITableViewCellEditingStyleNone;
}

// Row reordering
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // whether a given row is eligible for reordering
    return (indexPath.section == 1) ? YES : NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section == 1 && toIndexPath.section == 1) {
        // update controller view
        [self.delegate insertViewFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // Limit record reordering to the source section. Also snap the record to
    // the first or last row of the section, depending on where the drag went.
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    return proposedDestinationIndexPath;
}

#pragma mark - NSURLConnection delegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Deal with result returned by autocomplete API
    JSONDecoder* parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *data = nil;
    @try {
        data = [parser objectWithData:responseData];
    }
    @catch (NSException *e) {
        data = nil;
        NSLog(@"Exception caught while parsing JSON");
    }
    NSString *status  = [data objectForKey:@"status"];
    if (!status || ![status isEqualToString:@"OK"]) {
        return;
    }
    NSDictionary *result = [data objectForKey:@"result"];
    if (!result) {
        return;
    }
    
    // At this point we simply add extra fields to existing locality object
    
    // update locality object in modelDict
    RSLocality *locality = [modelDict objectForKey:_requestedLocalityId];
    [_requestedLocalityId release];
    _requestedLocalityId = nil;
    if (locality) {
        locality.formatted_address = [result objectForKey:@"formatted_address"];
        locality.name = [result objectForKey:@"name"];
        locality.vicinity = [result objectForKey:@"vicinity"];
        locality.url = [result objectForKey:@"url"];
        NSDictionary *location = [[result objectForKey:@"geometry"] objectForKey:@"location"];
        CLLocationCoordinate2D coord2d;
        coord2d.latitude = [[location objectForKey:@"lat"] doubleValue];
        coord2d.longitude = [[location objectForKey:@"lng"] doubleValue];
        locality.coord = coord2d;
        
        // save model array
        [self.delegate saveSettings];
    }
    
    //cleanup
    [responseData release];
    responseData = nil;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse
{
	[theURL release]; //[theURL autorelease];
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

#pragma mark - Screen orientation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // lock to portrait
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
