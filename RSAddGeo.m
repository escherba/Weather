//
//  RSAddGeo.m
//  SearchTut2
//
//  Created by Eugene Scherba on 11/14/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import "JSONKit.h"
#import "RSAddGeo.h"

@implementation RSAddGeo

@synthesize delegate;
@synthesize searchDisplayController;
@synthesize selectedLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Type City, State or Zip code:", @"Type City, State or Zip code:");
        static NSString *titleString = @"Type City, State or Zip code:";
        self.title = titleString;
    }
    return self;
}

- (void)dealloc
{
    // properties
    [apiData release];
    
    // private variables
    [apiConnection release];
    [responseData release];
    [theURL release];
    
    [self.selectedLocation release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    apiData = [[NSMutableArray alloc] initWithObjects:nil];
    [self.tableView reloadData];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.scrollEnabled = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [apiData release];
    apiData = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _cancelButtonClicked = NO;
    //if (!animated) {
    //    [searchDisplayController.searchBar resignFirstResponder];
    //}
    [searchDisplayController.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UISearchBarDelegate methods

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if (!self.selectedLocation && !_cancelButtonClicked) {
        [self.delegate geoAddControllerDidFinish:self];
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    _cancelButtonClicked = YES;
    [self.selectedLocation release];
    self.selectedLocation = nil;
    [self.delegate geoAddControllerDidFinish:self];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // acquire location name and dismiss modal view
    [self.selectedLocation release];
    self.selectedLocation = [[apiData objectAtIndex:indexPath.row] retain];
    [self.delegate geoAddControllerDidFinish:self];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [apiData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Configure the cell.
    if ([tableView isEqual:searchDisplayController.searchResultsTableView]) {
        //NSString *text = [apiData objectAtIndex:indexPath.row];
        cell.textLabel.text = [apiData objectAtIndex:indexPath.row]; //NSLocalizedString(text, text);
    }
    return cell;
}

#pragma mark - UISearchDisplayDelegate delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController*)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [apiConnection cancel];
    [apiConnection release];

    [responseData release];
	responseData = [[NSMutableData data] retain];
    _cancelButtonClicked = NO;
    
    [self.selectedLocation release];
    self.selectedLocation = nil;
    
    // Note: if you are using this code, please apply for your own id at Google Places API page
    theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&sensor=false&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc", [searchDisplayController.searchBar text]]];

    apiConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self startImmediately: YES];
    return NO;
}


-(BOOL)searchDisplayController:(UISearchDisplayController*)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [apiConnection cancel];
    [apiConnection release];
    
    [responseData release];
	responseData = [[NSMutableData data] retain];
    _cancelButtonClicked = NO;
    
    [self.selectedLocation release];
    self.selectedLocation = nil;
    
    // Note: if you are using this code, please apply for your own id at Google Places API page
    theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&sensor=false&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc", [searchDisplayController.searchBar text]]];
    
    apiConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self startImmediately: YES];
    return NO;
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
    JSONDecoder* parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *data = [parser objectWithData:responseData];
    if (!data) {
        return;
    }
    NSString *status = [data objectForKey:@"status"];
    if (!status || ![status isEqualToString:@"OK"]) {
        return;
    }
    NSArray *predictions = [data objectForKey:@"predictions"];
    if (!predictions || ![predictions count]) {
        return;
    }
    
    [apiData release];
    apiData = [[NSMutableArray alloc] init];
    for (NSDictionary *item in predictions){
        // data in the table are search results
        [apiData addObject:[item objectForKey:@"description"]];
    }
    
    // this is key here -- reload table view
    if (searchDisplayController.searchResultsTableView.hidden == YES){
        searchDisplayController.searchResultsTableView.hidden = NO;
    }
    [searchDisplayController.searchResultsTableView reloadData];
}

@end
