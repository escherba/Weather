//
//  FindNearbyPlace.m
//  Weather
//
//  Created by Eugene Scherba on 11/10/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import "WeatherAppDelegate.h"
#import "MainViewController.h"
#import "FindNearbyPlace.h"
#import "JSONKit.h"

@implementation FindNearbyPlace

-(void)queryServiceWithLat:(NSString *)latitude andLong:(NSString *)longitude
{
    appDelegate = (WeatherAppDelegate *)[[UIApplication sharedApplication] delegate];
    responseData = [[NSMutableData data] retain];
    
    NSString *url = [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyPlaceNameJSON?lat=%@&lng=%@",
                     latitude, longitude];
    theURL = [[NSURL URLWithString:url] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

-(NSURLRequest *) connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest*) request
            redirectResponse:(NSURLResponse *) redirectResponse
{
    [theURL autorelease];
    theURL = [[request URL] retain];
    return request;
}

-(void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection
didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}
-(void)connection:(NSURLConnection *)connection
didFailWithError:(NSError *)error
{
    // handle error
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSString *content = 
    //[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
    
    // get content using JSONKit
    JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *firstLocation 
    = [[[parser objectWithData:responseData] objectForKey:@"geonames"] objectAtIndex:0];
    
    // set location
    appDelegate.mainViewController.locationName 
    = [NSString stringWithFormat:@"%@,%@", [firstLocation objectForKey:@"name"], [firstLocation objectForKey:@"adminCode1"]];
    
    // stop spinning loading indicator
    [appDelegate.mainViewController.loadingActivityIndicator stopAnimating];
    
    // refresh main view
    [appDelegate.mainViewController refreshView: self];
    [responseData release];
    responseData = nil;
}

-(void)dealloc {
    [appDelegate release];
    [responseData release];
    [theURL release];
    [super dealloc];
}

@end
