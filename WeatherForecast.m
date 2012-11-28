//
//  WeatherForecast.m
//  Weather
//
//  Created by Eugene Scherba on 1/14/11.
//  Copyright 2011 Boston University. All rights reserved.
//

/*********** Example ***************
 Query: http://free.worldweatheronline.com/feed/weather.ashx?q=37.777940030048796,-122.41945266723633&format=json&num_of_days=5&key=d90609c900092229111111
 Result:
{
    "data": {
        "current_condition": [{
            "cloudcover": "0",
            "humidity": "76",
            "observation_time": "04:28 PM",
            "precipMM": "0.0",
            "pressure": "1028",
            "temp_C": "8",
            "temp_F": "46",
            "visibility": "16",
            "weatherCode": "113",
            "weatherDesc": [{
                "value": "Sunny"
            }],
            "weatherIconUrl": [{
                "value": "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png"
            }],
            "winddir16Point": "N",
            "winddirDegree": "0",
            "windspeedKmph": "0",
            "windspeedMiles": "0"
        }],
        "request": [{
            "query": "Lat 37.78 and Lon -122.42",
            "type": "LatLon"
        }],
        "weather": [{
            "date": "2012-11-11",
            "precipMM": "0.0",
            "tempMaxC": "13",
            "tempMaxF": "56",
            "tempMinC": "10",
            "tempMinF": "50",
            "weatherCode": "113",
            "weatherDesc": [{
                "value": "Sunny"
            }],
            "weatherIconUrl": [{
                "value": "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png"
            }],
            "winddir16Point": "ENE",
            "winddirDegree": "74",
            "winddirection": "ENE",
            "windspeedKmph": "8",
            "windspeedMiles": "5"
        }, {
            "date": "2012-11-12",
            "precipMM": "0.0",
            "tempMaxC": "16",
            "tempMaxF": "60",
            "tempMinC": "12",
            "tempMinF": "53",
            "weatherCode": "113",
            "weatherDesc": [{
                "value": "Sunny"
            }],
            "weatherIconUrl": [{
                "value": "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png"
            }],
            "winddir16Point": "NE",
            "winddirDegree": "50",
            "winddirection": "NE",
            "windspeedKmph": "9",
            "windspeedMiles": "6"
        }, {
            "date": "2012-11-13",
            "precipMM": "0.0",
            "tempMaxC": "16",
            "tempMaxF": "62",
            "tempMinC": "10",
            "tempMinF": "50",
            "weatherCode": "113",
            "weatherDesc": [{
                "value": "Sunny"
            }],
            "weatherIconUrl": [{
                "value": "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png"
            }],
            "winddir16Point": "E",
            "winddirDegree": "81",
            "winddirection": "E",
            "windspeedKmph": "11",
            "windspeedMiles": "7"
        }, {
            "date": "2012-11-14",
            "precipMM": "0.0",
            "tempMaxC": "17",
            "tempMaxF": "62",
            "tempMinC": "13",
            "tempMinF": "55",
            "weatherCode": "113",
            "weatherDesc": [{
                "value": "Sunny"
            }],
            "weatherIconUrl": [{
                "value": "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png"
            }],
            "winddir16Point": "NE",
            "winddirDegree": "51",
            "winddirection": "NE",
            "windspeedKmph": "12",
            "windspeedMiles": "7"
        }, {
            "date": "2012-11-15",
            "precipMM": "0.0",
            "tempMaxC": "16",
            "tempMaxF": "62",
            "tempMinC": "12",
            "tempMinF": "53",
            "weatherCode": "113",
            "weatherDesc": [{
                "value": "Sunny"
            }],
            "weatherIconUrl": [{
                "value": "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png"
            }],
            "winddir16Point": "E",
            "winddirDegree": "99",
            "winddirection": "E",
            "windspeedKmph": "15",
            "windspeedMiles": "10"
        }]
    }
}
**************/

#import <CoreLocation/CoreLocation.h>
#import "JSONKit.h"
#import "WeatherForecast.h"
#import "WeatherModel.h"
//#import "DownloadUrlOperation.h"

@implementation WeatherForecast

//@synthesize location;
@synthesize delegate;
@synthesize date;
@synthesize condition;
@synthesize days;
@synthesize timestamp;

#pragma mark - Instance Methods

// Public method: queryService
// Queries http://free.worldweatheronline.com/ for weather data
// Note that key to the web service is hard-coded here.
//
- (void)queryService:(CLLocationCoordinate2D)coord
{
    // Ignore request if one is pending.
    //
    // TODO: consider implementing some way of canceling requests and overriding
    // them with new ones, ot at least some sort of a stack/queue.
    //
    if (pendingRequest) {
        NSLog(@"Canceling request because one is already pending");
        return;
    }
    pendingRequest = YES;
    
	[responseData release];
	responseData = [[NSMutableData data] retain];
	
    // TODO: move all private IDs to a separate header file
    // Note: if you are using this code, please apply for your own id at worldweatheronline.com
	NSString *url = [NSString stringWithFormat:@"http://free.worldweatheronline.com/feed/weather.ashx?q=%f,%f&format=json&num_of_days=5&key=d90609c900092229111111", coord.latitude, coord.longitude];
    NSLog(@"Fetching forecast from: %@", url);
 
    [theURL release];
	theURL = [[NSURL URLWithString:url] retain];
	NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    
    [apiConnection release];
    apiConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"request sent");
}


#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        delegate = nil;
        apiConnection = nil;
        responseData = nil;
        theURL = nil;
        timestamp = nil;
        pendingRequest = NO;
        operationCount = 0;
        
        // grab on to shared application's delegate
        appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)dealloc
{
    [timestamp release],     timestamp = nil;
    
    // [location release];
	[responseData release],  responseData = nil;
	[theURL release],        theURL = nil;
    [apiConnection release], apiConnection = nil;
	[date release],          date = nil;
	[condition release],     condition = nil;
	[days release],          days = nil;
	[super dealloc];
}

#pragma mark - NSURLConnection delegate methods
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    pendingRequest = NO;
    NSLog(@"Connection did finish loading");
    
    // get content using JSONKit
    JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *data;
    @try {
        data = [[parser objectWithData:responseData] objectForKey:@"data"];
    }
    @catch (NSException *e) {
        data = nil;
        NSLog(@"Exception trying to parse JSON response");
    }
    
	// Forecast Information ///////////////////////////////////////
    //[self.location release];
	//self.location = [[[data objectForKey:@"request"] objectAtIndex:0] objectForKey:@"query"];
    self.timestamp = [NSDate date];
    
	// Current Conditions /////////////////////////////////////////
    NSDictionary *current_condition = [[data objectForKey:@"current_condition"] objectAtIndex:0];
    RSCurrentCondition* rsCurrentCondition = [[RSCurrentCondition alloc] initWithDict:current_condition withIndex:0];

    //download weather condition image icon
    //DownloadUrlOperation *operation = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:rsCurrentCondition.iconURL]];
    //[operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:rsCurrentCondition];
    //[operationQueue addOperation:operation]; // operation starts as soon as its added
    //[operation release];
    //operationCount++;
    
    [condition release];
    condition = rsCurrentCondition;

	// 5-day forecast ////////////////////////////////////////
    NSMutableArray* tmpDays = [[NSMutableArray alloc] initWithObjects:nil];
    NSArray *forecast = [data objectForKey:@"weather"];
    NSUInteger i = 1; // reserve i=0 for current condition
    if (forecast) {
        for (NSDictionary *node in forecast) {
            RSDay *rsDay = [[RSDay alloc] initWithDict:node withIndex:i];
            
            //download weather condition image icon
            //DownloadUrlOperation *operation = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:rsDay.iconURL]];
            //[operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:rsDay];
            //[operationQueue addOperation:operation]; // operation starts as soon as its added
            //[operation release];
            //operationCount++;
            
            [tmpDays addObject:rsDay];
            [rsDay release];
            rsDay = nil;
            i++;
        }
    }
    [days release],          days = tmpDays;
    [responseData release],  responseData = nil;

    NSLog(@"Notifying delegate that forecast had finished downloading");
    [delegate weatherForecastDidFinish:self];
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
    // initialize mutable data
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
didReceiveData:(NSData *)data
{
    // append to NSMutableData
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // handle error
    pendingRequest = NO;
}

@end
