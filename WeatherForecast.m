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
#import "WeatherModel.h"


@implementation WeatherForecast

@synthesize location;
@synthesize date;

@synthesize condition;
@synthesize days;

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
	
    // release RSCondition object
	[condition release];
    
    // release Days array
    NSEnumerator *enumDays = [self.days objectEnumerator];
    RSDay *day;
    while (day = [enumDays nextObject]) {
        [day release];
    }
	[self.days release];
	
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
    // get content using JSONKit
    JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *data 
    = [[parser objectWithData:responseData] objectForKey:@"data"];

    if (!data) {
        return;
    }
    
	// Forecast Information ///////////////////////////////////////
	location = [[[data objectForKey:@"request"] objectAtIndex:0] objectForKey:@"query"];

    
	// Current Conditions /////////////////////////////////////////
    [self.condition release];
    self.condition = [[RSCondition alloc] init];
    
    NSDictionary *current_condition = [[data objectForKey:@"current_condition"] objectAtIndex:0];
    if (current_condition) {
        self.condition.iconURL
        = [[[current_condition objectForKey:@"weatherIconUrl"] objectAtIndex:0] objectForKey:@"value"];
        self.condition.condition 
        = [[[current_condition objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"];
        self.condition.tempC = [current_condition objectForKey:@"temp_C"];
        self.condition.tempF = [current_condition objectForKey:@"temp_F"];
        self.condition.humidity = [current_condition objectForKey:@"humidity"];
        self.condition.wind = [current_condition objectForKey:@"windspeedMiles"];
    }
    
	// 5-day forecast ////////////////////////////////////////
    NSEnumerator *enumDays = [self.days objectEnumerator];
    RSDay *day;
    while (day = [enumDays nextObject]) {
        [day release];
    }
	[self.days release];
	self.days = [[NSMutableArray alloc] initWithObjects:nil];
    
    NSArray *forecast = [data objectForKey:@"weather"];
    if (forecast) {
        for (NSDictionary *node in forecast) {
            [self.days addObject:[[RSDay alloc] initWithDate:[node objectForKey:@"date"] highT:[node objectForKey:@"tempMaxF"] lowT:[node objectForKey:@"tempMinF"] condition:[[[node objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"] iconURL:[[[node objectForKey:@"weatherIconUrl"] objectAtIndex:0] objectForKey:@"value"]]];
        }
	}

	[viewController updateView];
}

@end
