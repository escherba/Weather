//
//  RSAddGeo.m
//  SearchTut2
//
//  Created by Eugene Scherba on 11/14/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//
//  Implementation goal: a dictionary of objects:
//  {
//     "44145598158d9d5d6bcd0b78ca77361b541fdde8" = {
//        reference         = "CjQuAAAAi3jddRbuA6DNsXwmX761aVJenxxBBG-1Eyge6_y6CRh-raxieJTnuP6p9i9vBAB_EhAxaJvm0fndzhlaaZGFo8LdGhS1OQPrQhgBAVrCyenxh5MatKT_CA";
//        lat               = -12.06666670;
//        lng               = -75.21666669999999;
//        url               = "https://maps.google.com/maps/place?q=Huancayo&ftid=0x910e964104fb82f1:0xf8e45b61c55982fa";
//        description       = "Huancayo, Jun\U00edn, Peru";
//        formatted_address = "Huancayo, Peru";
//        name              = "Huancayo";
//        vicinity          = "Huancayo";
//     };
//  }

#import "JSONKit.h"
#import "RSAddGeo.h"

#pragma mark - RSLocality
@implementation RSLocality

@synthesize apiId;
@synthesize reference;
//@synthesize coord; // have custom accessors written for this property
@synthesize url;
@synthesize description;
@synthesize formatted_address;
@synthesize name;
@synthesize vicinity;
@synthesize haveCoord;
@synthesize forecastTimestamp;
@synthesize trackLocation;

#pragma mark - Lifecycle

- (id) init
{
    self = [super init];
    if (self) {
        haveCoord     = NO;
        trackLocation = NO;
    }
    return self;
}

- (id) initWithId:(NSString *)id1
           reference: (NSString *) ref1
           description:(NSString *)desc1;
{
    self = [super init];
    if (self) {
        apiId         = [id1 retain];
        reference     = [ref1 retain];
        description   = [desc1 retain];
        haveCoord     = NO;
        trackLocation = NO;
    }
    return self;
}

- (void)dealloc
{
    [apiId release],             apiId = nil;
    [reference release],         reference = nil;
    [url release],               url = nil;
    [description release],       description = nil;
    [formatted_address release], formatted_address = nil;
    [name release],              name = nil;
    [vicinity release],          vicinity = nil;
    [forecastTimestamp release], forecastTimestamp = nil;
    [super dealloc];
}

- (void) updateFrom: (RSLocality *)locality
{
    if ([locality.vicinity length] > 0) {
        if (vicinity != locality.vicinity) {
            [vicinity release];
            vicinity = [locality.vicinity retain];
        }
    }
    if (locality.haveCoord == YES) {
        haveCoord = YES;
        coord = locality.coord;
    }
    if ([locality.name length] > 0) {
        if (name != locality.name) {
            [name release];
            name = [locality.name retain];
        }
    }
    if ([locality.formatted_address length] > 0) {
        if (formatted_address != locality.formatted_address) {
            [formatted_address release];
            formatted_address = [locality.formatted_address retain];
        }
    }
    if ([locality.description length] > 0) {
        if (description != locality.description) {
            [description release];
            description = [locality.description retain];
        }
    }
    if ([locality.url length] > 0) {
        if (url != locality.url) {
            [url release];
            url = [locality.url retain];
        }
    }
    if ([locality.reference length] > 0) {
        if (reference != locality.reference) {
            [reference release];
            reference = [locality.reference retain];
        }
    }
    if ([locality.apiId length] > 0) {
        if (apiId != locality.apiId) {
            [apiId release];
            apiId = [locality.apiId retain];
        }
    }
}

-(void) setCoord:(CLLocationCoordinate2D)coordValue
{
    coord = coordValue;
    haveCoord = YES;
}

-(CLLocationCoordinate2D)coord
{
    return coord;
}

#pragma mark - NSCoding delegate methods
- (id) initWithCoder: (NSCoder *)coder
{
    self = [[RSLocality alloc] init];
    if (self != nil)
    {
        CLLocationCoordinate2D coord2d;
        coord2d.latitude =       [coder decodeDoubleForKey:@"lat"];
        coord2d.longitude =      [coder decodeDoubleForKey:@"lng"];
        self.coord = coord2d;
        self.haveCoord =         [coder decodeBoolForKey:@"haveCoord"];
        self.trackLocation =     [coder decodeBoolForKey:@"trackLocation"];
        
        self.name =              [coder decodeObjectForKey:@"name"];
        self.vicinity =          [coder decodeObjectForKey:@"vicinity"];
        self.formatted_address = [coder decodeObjectForKey:@"formatted_address"];
        self.description =       [coder decodeObjectForKey:@"description"];
        self.url =               [coder decodeObjectForKey:@"url"];
        self.reference =         [coder decodeObjectForKey:@"reference"];
        self.apiId =             [coder decodeObjectForKey:@"apiId"];
        self.forecastTimestamp = [coder decodeObjectForKey:@"forecastTimestamp"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    CLLocationDegrees lat = coord.latitude;
    CLLocationDegrees lng = coord.longitude;
    [coder encodeDouble:lng               forKey:@"lng"];
    [coder encodeDouble:lat               forKey:@"lat"];
    [coder encodeBool:haveCoord           forKey:@"haveCoord"];
    [coder encodeBool:trackLocation       forKey:@"trackLocation"];
    
    [coder encodeObject:name              forKey:@"name"];
    [coder encodeObject:vicinity          forKey:@"vicinity"];
    [coder encodeObject:formatted_address forKey:@"formatted_address"];
    [coder encodeObject:description       forKey:@"description"];
    [coder encodeObject:url               forKey:@"url"];
    [coder encodeObject:reference         forKey:@"reference"];
    [coder encodeObject:apiId             forKey:@"apiId"];
    [coder encodeObject:forecastTimestamp forKey:@"forecastTimestamp"];
}
@end

#pragma mark - RSAddGeo
@implementation RSAddGeo

@synthesize delegate;

#pragma mark - Controller lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        static NSString *titleString = @"Type City, State or Zip code:";
        self.title = titleString;
        apiConnection = nil;
    }
    return self;
}

- (void)dealloc
{
    // private variables
    [theURL release],            theURL = nil;
    [apiConnection release],     apiConnection = nil;
    [responseData release],      responseData = nil;
    [processedData release],     processedData = nil;
    [_selectedLocality release], _selectedLocality = nil;
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

    processedData = [[NSMutableArray alloc] initWithObjects:nil];
    //[self.tableView setEditing:NO animated:NO];
    [self.tableView reloadData];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.scrollEnabled = YES;
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
    [self.searchDisplayController.searchBar becomeFirstResponder];
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
    if (!_selectedLocality && !_cancelButtonClicked) {
        [self.delegate geoAddControllerDidFinish:self];
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    _cancelButtonClicked = YES;
    [_selectedLocality release];
    _selectedLocality = nil;
    [self.delegate geoAddControllerDidFinish:self];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // acquire location name and dismiss modal view
    [_selectedLocality release];
    _selectedLocality = [[processedData objectAtIndex:indexPath.row] retain];
    [self.delegate geoAddControllerDidFinish:self];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [processedData count];
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
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        cell.textLabel.text = [[processedData objectAtIndex:indexPath.row] description];
    }
    return cell;
}

#pragma mark - UISearchDisplayDelegate delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController*)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [apiConnection cancel];
    [apiConnection release];
    apiConnection = nil;
    
    [responseData release];
	responseData = [[NSMutableData data] retain];
    _cancelButtonClicked = NO;
    
    [_selectedLocality release];
    _selectedLocality = nil;
    
    // Note: if you are using this code, please apply for your own id at Google Places API page
    theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&sensor=true&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc", [self.searchDisplayController.searchBar text]]];

    apiConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self startImmediately: YES];
    return NO;
}


-(BOOL)searchDisplayController:(UISearchDisplayController*)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [apiConnection cancel];
    [apiConnection release];
    apiConnection = nil;
    
    [responseData release];
	responseData = [[NSMutableData data] retain];
    _cancelButtonClicked = NO;
    
    [_selectedLocality release];
    _selectedLocality = nil;
    
    // Note: if you are using this code, please apply for your own id at Google Places API page
    theURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&sensor=true&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc", [self.searchDisplayController.searchBar text]]];
    
    apiConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self startImmediately: YES];
    return NO;
}

#pragma mark - NSURLConnection delegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Deal with predictions returned by autocomplete API
    JSONDecoder* parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *data;
    @try {
        data = [parser objectWithData:responseData];
    }
    @catch (NSException *e) {
        data = nil;
        NSLog(@"Exception caught parsing JSON");
    }
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
    
    // release previous data stored and allocate new array
    [processedData removeAllObjects];
    
    for (NSDictionary *item in predictions) {
        // Data in the table are search results.
        // We only show localities, not countries or other types
        int haveLocality = 0;
        NSMutableArray *types = [item objectForKey:@"types"];
        for (NSString *type in types) {
            if ([type isEqualToString:@"locality"]) {
                haveLocality = 1;
                break;
            }
        }
        if (haveLocality == 1) {
            // at this point, store id, reference id, and description of locality
            RSLocality *locality = [[RSLocality alloc] initWithId:[item objectForKey:@"id"] reference:[item objectForKey:@"reference"] description:[item objectForKey:@"description"]];
            [processedData addObject:locality];
            [locality release];
            locality = nil;
        }
    }
    
    // reload table view
    if (self.searchDisplayController.searchResultsTableView.hidden == YES){
        self.searchDisplayController.searchResultsTableView.hidden = NO;
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    //cleanup
    [responseData release];
    responseData = nil;
}

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

@end
