//
//  RSLocalPageController.m
//  Weather
//
//  Created by Eugene Scherba on 11/7/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "WeatherAppDelegate.h"
#import "MainViewController.h"
#import "RSLocalPageController.h"
#import "RSAddGeo.h"

@implementation RSLocalPageController

@synthesize showingImperial;
@synthesize pageNumber;
@synthesize locality;
@synthesize forecast;
@synthesize loadingActivityIndicator;

#pragma mark - Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];
    showingImperial = appDelegate.mainViewController.useImperial;
    
    UIColor *pattern = [UIColor colorWithPatternImage:[UIImage imageNamed: @"fancy_deboss.png"]];
    [self.view setBackgroundColor: pattern];

    // Now add rounded corners:
    UIView* view = self.view;
    [view.layer setCornerRadius:15.0f];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:1.5f];
    [view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    //[view.layer setShadowColor:[UIColor blackColor].CGColor];
    //[view.layer setShadowOpacity:0.8];
    //[view.layer setShadowRadius:3.0];
    //[view.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    // Do any additional setup after loading the view from its nib.
    forecast = [[WeatherForecast alloc] init];
    forecast.delegate = self;
    
    NSLog(@"RSLocalPageController viewDidLoad");
    //appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    weekdayFormatter = [[NSDateFormatter alloc] init];
    [weekdayFormatter setDateFormat: @"EEEE"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [view addSubview:_tableView];
    //[_tableView release];
    
    if (locality.haveCoord) {
        NSLog(@"Page %u: viewDidLoad: getting forecast", pageNumber);
        [loadingActivityIndicator startAnimating];
        [forecast queryService:locality.coord];
        if (locality.trackLocation) {
            [appDelegate.findNearby queryServiceWithCoord:locality.coord];
        }
    } else {
        NSLog(@"Page %u: viewDidLoad: missing coordinates", pageNumber);
        NSLog(@"lat: %f, long: %f", self.locality.coord.latitude, self.locality.coord.longitude);
    }
    if (locality.trackLocation) {
        [loadingActivityIndicator startAnimating];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"Releasing observer");
    [locality removeObserver:self forKeyPath:@"coord" context:self];
    
    [locality release],                 locality = nil;
    [loadingActivityIndicator release], loadingActivityIndicator = nil;
    [forecast release],                 forecast = nil;
    [weekdayFormatter release],         weekdayFormatter = nil;
	[nameLabel release],                nameLabel = nil;
	[dateLabel release],                dateLabel = nil;
	[nowImage release],                 nowImage = nil;
	[nowTempLabel release],             nowTempLabel = nil;
	[nowHumidityLabel release],         nowHumidityLabel = nil;
	[nowWindLabel release],             nowWindLabel = nil;
	[nowConditionLabel release],        nowConditionLabel = nil;
    [_tableView release],               _tableView = nil;
	[super dealloc];
}

#pragma mark - internals

-(void)currentLocationDidUpdate:(CLLocation *)location
{
    CLLocationCoordinate2D coord = location.coordinate;
    [appDelegate.findNearby queryServiceWithCoord:coord];
    //[forecast queryService:coord];
}

-(void)findNearbyPlaceDidFinish:(NSDictionary*)dict
{
    NSLog(@"RSLocalPageController findNearbyPlaceDidFinish:");
    NSString* placeName = [dict objectForKey:@"name"];
    nameLabel.text = placeName;
}

-(void)viewMayNeedUpdate {
    // gets called whenever view will be displayed in parent viewport
    // need to determine whether to retrieve new forecast here based on the
    // difference between current and stored timestamps;
    
    BOOL doUseImperial = appDelegate.mainViewController.useImperial;
    if (doUseImperial != showingImperial) {
        showingImperial = doUseImperial;
        [self reloadDataViews];
    }
    
    NSDate *currentTime = [NSDate date];
    NSTimeInterval interval = [currentTime timeIntervalSinceDate:locality.forecastTimestamp];
    
    // 900 seconds is 15 minutes
    if (interval >= 900.0f) {
        [loadingActivityIndicator startAnimating];
        [forecast queryService:locality.coord];
    }
    NSLog(@"!!! Seconds since last update: %f", interval);
}


-(void)reloadDataViews {
    // Current condition
	nowTempLabel.text = [forecast.condition formatTemperatureImperial:showingImperial];
	nowHumidityLabel.text = [NSString stringWithFormat:@"%u%%", forecast.condition.humidity];
    nowWindLabel.text = [forecast.condition formatWindSpeedImperial:showingImperial];
	nowConditionLabel.text = forecast.condition.condition;
    
    // Forecast
    [_tableView reloadData];
}

#pragma mark - Key-Value-Observing
// override setter so that we register observing method whenever locality is added
-(void)setLocality:(RSLocality *)localityValue
{
    if (localityValue != locality)
    {
        [localityValue retain];
        [locality removeObserver:self forKeyPath:@"coord" context:self];
        [locality release];
        [localityValue addObserver:self
            forKeyPath:@"coord"
                options:NSKeyValueObservingOptionNew
                    context:self];
        
        locality = localityValue;
    }
}

// this method should be called when coordinates are added/updated
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"coord"]) {
        NSLog(@"RSLocalPageController observeValueForKeyPath:coord called");
        [loadingActivityIndicator startAnimating];
        [forecast queryService:locality.coord];
        if (locality.trackLocation) {
            [appDelegate.findNearby queryServiceWithCoord:locality.coord];
        }
    }
}

#pragma mark - WeatherForecastDelegate method
-(void)weatherForecastDidFinish:(WeatherForecast *)sender
{
    // do whatever needs to be done when we finish downloading forecast
    [loadingActivityIndicator stopAnimating];
    
    // update timestamp to current time
    locality.forecastTimestamp = [NSDate date];
    
	// City and Date
	//nameLabel.text = locationName;
    nameLabel.text = locality.description;
	dateLabel.text = forecast.date;
    
	[self reloadDataViews];
}

- (void)iconDidLoad:(id)iconOwner
{
    // icon loaded asynchronously
    UIImage* img = [iconOwner iconData];
    NSInteger index = [iconOwner index];
    if (index == 0) {
        // if index is zero, then we have current condition icon
        NSLog(@"setting current condition image");
        nowImage.image = img;
    } else if (index > 0) {
        NSInteger cellIndex = index - 1;
        // otherwise it is one of the forecast icons
        NSLog(@"setting current image at index: %d", cellIndex);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0] ;
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = img;
        
        // [cell setNeedsDisplay];
        // [cell.backgroundView setNeedsDisplay];
        // [cell.contentView setNeedsDisplay];
    } else {
        // Have an error
        NSLog(@"ERROR: bad index");
    }
}

-(void)allIconsLoaded
{
    NSLog(@"allIconsLoaded called");
    [_tableView reloadData];
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
        NSString *title = [[NSString alloc] initWithFormat:@"%@: %@", [weekdayFormatter stringFromDate:day.date], [day getHiLoImperial:showingImperial]];
        cell.textLabel.text = title;
        [title release], title = nil;
        cell.detailTextLabel.text = day.condition;
        
        // check if row is odd or even and set color accordingly
        //cell.backgroundColor = (indexPath.row % 2) ? [UIColor whiteColor] : [UIColor lightGrayColor];
    }

    //[cell setNeedsDisplay];
    //[cell.backgroundView setNeedsDisplay];
    //[cell.contentView setNeedsDisplay];
    return cell;
}

#pragma mark - Screen orientation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // lock to portrait
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
