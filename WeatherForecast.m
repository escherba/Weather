//
//  WeatherForecast.m
//  Weather
//
//  Created by Eugene Scherba on 1/14/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "WeatherForecast.h"
#import "MainViewController.h"
#import "JSONKit.h"

@implementation WeatherForecast

@synthesize location;
@synthesize date;

@synthesize icon;
@synthesize temp;
@synthesize humidity;
@synthesize wind;
@synthesize condition;

@synthesize days;
@synthesize icons;
@synthesize temps;
@synthesize conditions;

#pragma mark -
#pragma mark Instance Methods

- (void)queryService:(CLLocationCoordinate2D)coord
  withParent:(UIViewController *)controller
{
    
	viewController = (MainViewController *)controller;
	[responseData release];
	responseData = [[NSMutableData data] retain];
	
    // Note: if you are using this code, please apply for your own id at worldweatheronline.com
	NSString *url = [NSString stringWithFormat:@"http://free.worldweatheronline.com/feed/weather.ashx?q=%f,%f&format=json&num_of_days=5&key=d90609c900092229111111", coord.latitude, coord.longitude];
    NSLog(@"%@", url);
    
	theURL = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void)dealloc
{
	[viewController release];
	
	[responseData release];
	[theURL release];
	
	[location release];
	[date release];
	
	[icon release];
	[temp release];
	[humidity release];
	[wind release];
	[condition release];
	
	[days release];
	[icons release];
	[temps release];
	[conditions release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

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

-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{	
    //NSError *error;
	
    // get content using JSONKit
    JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *data 
    = [[parser objectWithData:responseData] objectForKey:@"data"];

    if (!data) {
        NSLog(@"no data received");
        return;
    }
    NSLog(@"received data ok");
    
	// Forecast Information ///////////////////////////////////////
	location = [[[data objectForKey:@"request"] objectAtIndex:0] objectForKey:@"query"];

    
	// Current Conditions /////////////////////////////////////////
    NSDictionary *current_condition = [[data objectForKey:@"current_condition"] objectAtIndex:0];
	icon =[[[current_condition objectForKey:@"weatherIconUrl"] objectAtIndex:0] objectForKey:@"value"];
	temp = [NSString stringWithFormat:@"%@F (%@C)", [current_condition objectForKey:@"temp_F"], [current_condition objectForKey:@"temp_C"]];
	humidity = [current_condition objectForKey:@"humidity"];
	wind = [current_condition objectForKey:@"windspeedMiles"];
	condition = [[[current_condition objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"];
	
	// 5-day forecast ////////////////////////////////////////
	NSArray *forecast = [data objectForKey:@"weather"];
    
	// Day names
	[days release];
	days = [[NSMutableArray alloc] init];
	for (NSDictionary *node in forecast) {
		[days addObject:[node objectForKey:@"date"]];
	}
	
	// Icons
	[icons release];
	icons = [[NSMutableArray alloc] init];
	for (NSDictionary  *node in forecast) {
		//[icons addObject:[NSString stringWithFormat:@"http://www.google.com%@", [node stringValue]]];
        [icons addObject:[[[node objectForKey:@"weatherIconUrl"] objectAtIndex:0] objectForKey:@"value"]];
	}
	
	// Temperatures (high)
	NSMutableArray *highs = [[NSMutableArray alloc] init];
	for (NSDictionary  *node in forecast) {
		[highs addObject:[node objectForKey:@"tempMaxF"]];
	}
    
    // Temperatures (low)
    NSMutableArray *lows = [[NSMutableArray alloc] init];
	for (NSDictionary  *node in forecast) {
        [lows addObject:[node objectForKey:@"tempMinF"]];
	}
    
	[temps release];
	temps = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0u, mcount = MIN(highs.count, lows.count); i < mcount; i++) {
		[temps addObject:[NSString stringWithFormat:@"%@F/%@F", [highs objectAtIndex:i], [lows objectAtIndex:i]]];
	}
	[highs release];
	[lows release];
	
	// Conditions
	[conditions release];
	conditions = [[NSMutableArray alloc] init];
	for (NSDictionary  *node in forecast) {
		[conditions addObject:[[[node objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"]];
	}
	
	[viewController updateView];
}

@end
