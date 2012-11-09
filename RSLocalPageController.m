//
//  RSLocalPageController.m
//  Weather
//
//  Created by Eugene Scherba on 11/7/12.
//
//

#import "RSLocalPageController.h"
#import "RSAddGeo.h"

@implementation RSLocalPageController

@synthesize locality;
@synthesize forecast;
@synthesize loadingActivityIndicator;

#pragma mark - Lifecycle

// will call this instead of init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    forecast = [[WeatherForecast alloc] init];
    forecast.delegate = self;
    
    NSLog(@"RSLocalPageController viewDidLoad");
    //locationName = [[NSString alloc] init];
    //appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    weekdayFormatter = [[NSDateFormatter alloc] init];
    [weekdayFormatter setDateFormat: @"EEEE"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    NSLog(@"Calling refresh view to show weather");
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [weekdayFormatter release];
    //[locationName release];
	
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

#pragma mark - custom methods

- (IBAction)refreshView {
    
	[loadingActivityIndicator startAnimating];
    CLLocationDegrees lat = [locality.lat doubleValue];
    CLLocationDegrees lng = [locality.lng doubleValue];
    CLLocation* defaultLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    [forecast queryService:[defaultLocation coordinate]];
    [defaultLocation release];
    NSLog(@"Finished querying lat:%f lng:%f", lat, lng);
}

#pragma mark - WeatherForecastDelegate method
-(void)weatherForecastDidFinish:(WeatherForecast *)sender
{
    // do whatever needs to be done when we finish downloading forecast
    [loadingActivityIndicator stopAnimating];
    
	// City and Date
    //NSLog( @"Location name: %@", locationName );
	//nameLabel.text = locationName;
    nameLabel.text = locality.description;
	dateLabel.text = forecast.date;
    
	// Now
	nowTempLabel.text = [forecast.condition formatTemperature];
	nowHumidityLabel.text = forecast.condition.humidity;
	nowWindLabel.text = forecast.condition.wind;
	nowConditionLabel.text = forecast.condition.condition;
	nowImage.image = forecast.condition.iconData;
    
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
        NSString *title = [[NSString alloc] initWithFormat:@"%@: %@", [weekdayFormatter stringFromDate:day.date], [day getHiLo]];
        cell.textLabel.text = title;
        [title release];
        
        cell.detailTextLabel.text = day.condition;
        cell.imageView.image = day.iconData;
    }
    return cell;
}



@end
