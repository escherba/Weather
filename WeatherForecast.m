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
#import "DownloadUrlOperation.h"
#import "UIImage+RSRoundCorners.h"

@implementation WeatherForecast

//@synthesize location;
@synthesize date;
@synthesize condition;
@synthesize days;

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
    
	//viewController = (RSLocalPageController *)controller;
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
        apiConnection = nil;
        responseData = nil;
        theURL = nil;
        pendingRequest = NO;
        operationCount = 0;
        
        // grab on to shared application's delegate
        appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];
        operationQueue = appDelegate.operationQueue;
    }
    return self;
}

- (void)dealloc
{
    operationQueue = nil;
    
	//[viewController release];
    // [location release];
	[responseData release],  responseData = nil;
	[theURL release],        theURL = nil;
    [apiConnection release], apiConnection = nil;
	[date release],          date = nil;
	[condition release],     condition = nil;
	[days release],          days = nil;
	[super dealloc];
}

#pragma mark - KVO observing

-(BOOL)isValidPNG:(UIImage*)img{
    NSData *png = UIImagePNGRepresentation(img);
    if (png == nil) {
        return NO;
    }
    NSUInteger length = [png length];
    const char *img_bytes = [png bytes];
    if (memcmp(img_bytes, "\211PNG", 4) != 0) {
        return NO;
    }
    else if (OSReadBigInt64(img_bytes, (length - 8)) != 5279712195050102914) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)operation change:(NSDictionary *)change context:(void *)context
{
    if ([operation isKindOfClass:[DownloadUrlOperation class]]) {
        operationCount--;
        NSLog(@"Operation finished");
        
        DownloadUrlOperation *downloadOperation = (DownloadUrlOperation *)operation;
        RSCondition *prediction = (RSCondition *)context;
        NSData *data = [downloadOperation data];
        NSError *error = [downloadOperation error];
        
        if (error == nil) {
            // Notify that we have got this source data;
            /*[[NSNotificationCenter defaultCenter] postNotificationName:@"DataDownloadFinished"
             object:self
             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:source, @"source", data, @"data", nil]];*/
            
            // save data
            UIImage *img = [[UIImage alloc] initWithData:data];
            if (![self isValidPNG:img]) {
                NSLog(@"ERROR: invalid PNG");
            }
            [prediction setIconData:[img roundCornersWithRadius:3.0]];
            [img release];
            img = nil;
            
            // post notification
            [self.delegate iconDidLoad:prediction];
        } else {
            NSLog(@"ERROR: download did not complete");
            // handle error
            // Notify that we have got an error downloading this data;
            /*[[NSNotificationCenter defaultCenter] postNotificationName:@"DataDownloadFailed"
             object:self
             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:source, @"source", error, @"error", nil]];*/
        }
        //NSUInteger opRem = [operationQueue operationCount];
        //NSLog(@"Operations remaining: %u", opRem);
        if (operationCount < 1) {
            [self.delegate allIconsLoaded];
        }
    }
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
    
	// Current Conditions /////////////////////////////////////////
    NSDictionary *current_condition = [[data objectForKey:@"current_condition"] objectAtIndex:0];
    RSCurrentCondition* rsCurrentCondition = [[RSCurrentCondition alloc] initWithDict:current_condition withIndex:0];

    //download weather condition image icon
    DownloadUrlOperation *operation = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:rsCurrentCondition.iconURL]];
    [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:rsCurrentCondition];
    [operationQueue addOperation:operation]; // operation starts as soon as its added
    [operation release];
    operationCount++;
    
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
            DownloadUrlOperation *operation = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:rsDay.iconURL]];
            [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:rsDay];
            [operationQueue addOperation:operation]; // operation starts as soon as its added
            [operation release];
            operationCount++;
            
            [tmpDays addObject:rsDay];
            [rsDay release];
            rsDay = nil;
            i++;
        }
    }
    [days release],          days = tmpDays;
    [responseData release],  responseData = nil;

    NSLog(@"Notifying delegate that forecast had finished downloading");
    if (self.delegate) {
        [self.delegate weatherForecastDidFinish:self];
    }
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
