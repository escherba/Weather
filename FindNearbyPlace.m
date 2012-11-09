//
//  FindNearbyPlace.m
//  Weather
//
//  Can also use http://ws.geonames.org/ webservice to reverse-lookup geolocation
//
//  TODO: place labels don't show up, verify why
//
//  Created by Eugene Scherba on 11/10/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import "WeatherAppDelegate.h"
#import "MainViewController.h"
#import "FindNearbyPlace.h"
#import "JSONKit.h"

@implementation FindNearbyPlace

//
// This is the only public method in this class
// URL is built-in for now -- consider adding ability to use different URLs
//
-(void)queryServiceWithCoord:(CLLocationCoordinate2D)coord
{
    appDelegate = (WeatherAppDelegate *)[[UIApplication sharedApplication] delegate];
    responseData = [[NSMutableData data] retain];
    
    // Using Google Places API:
    // https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.8015957,-122.4735831&rankby=distance&types=establishment&sensor=true&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc
    //
    // http://maps.googleapis.com/maps/api/geocode/json?latlng=37.8015957,-122.4735831&sensor=true&types=locality
    NSString *url = [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyPlaceNameJSON?lat=%f&lng=%f",
                     coord.latitude, coord.longitude];
    theURL = [[NSURL URLWithString:url] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

// Lifecycle method: dealloc
-(void)dealloc {
    [appDelegate release];
    [responseData release];
    [theURL release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSString *content =
    //[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
    
    // get content using JSONKit
    //JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    //NSDictionary *firstLocation = [[[parser objectWithData:responseData] objectForKey:@"geonames"] objectAtIndex:0];
    
    // set location
    //appDelegate.mainViewController.locationName
    //appDelegate.nearbyLocationName = [NSString stringWithFormat:@"%@,%@", [firstLocation objectForKey:@"name"], [firstLocation objectForKey:@"adminCode1"]];
    
    // stop spinning loading indicator
    //[appDelegate.mainViewController.loadingActivityIndicator stopAnimating];
    
    // refresh main view
    //[appDelegate.mainViewController refreshView: self];
    [responseData release];
    responseData = nil;
}

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
    // initialize mutable data
    [responseData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection
didReceiveData:(NSData *)data
{
    // append to NSMutableData
    [responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection
didFailWithError:(NSError *)error
{
    // handle error
}

@end
