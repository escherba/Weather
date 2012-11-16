//
//  FindNearbyPlace.m
//  Weather
//
//  Can also use http://ws.geonames.org/ webservice to reverse-lookup geolocation
//
//  Created by Eugene Scherba on 11/10/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

/********** Example ***************
 Query: http://ws.geonames.org/findNearbyPlaceNameJSON?lat=37.8015957&lng=-122.4735831&username=rescribble
 
 Result:
 {
 "geonames": [{
 "countryName": "United States",
 "adminCode1": "CA",
 "fclName": "city, village,...",
 "countryCode": "US",
 "lng": -122.4735831,
 "fcodeName": "populated place",
 "distance": "0",
 "toponymName": "Fort Winfield Scott",
 "fcl": "P",
 "name": "Fort Winfield Scott",
 "fcode": "PPL",
 "geonameId": 5350113,
 "lat": 37.8015957,
 "adminName1": "California",
 "population": 0
 }]
 }
**********************/

#import "MainViewController.h"
#import "FindNearbyPlace.h"
#import "JSONKit.h"

@implementation FindNearbyPlace
@synthesize delegate;

//
// This is the only public method in this class
// URL is built-in for now -- consider adding ability to use different URLs
//
-(void)queryServiceWithCoord:(CLLocationCoordinate2D)coord
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
    
    NSLog(@"FindNearbyPlace queryServiceWithCoord:");
    responseData = [[NSMutableData data] retain];
    
    /* With geonames API, can also return weather like this:
     http://api.geonames.org/findNearByWeatherJSON?lat=37.791752&lng=-122.480210&username=rescribble
     {
     "weatherObservation": {
     "weatherCondition": "n/a",
     "clouds": "scattered clouds",
     "observation": "KSFO 140356Z 16004KT 10SM SCT180 14/05 A3010 RMK AO2 SLP193 T01440050",
     "windDirection": 160,
     "ICAO": "KSFO",
     "seaLevelPressure": 1019.3,
     "elevation": 3,
     "countryCode": "US",
     "cloudsCode": "SCT",
     "lng": -122.36666666666666,
     "temperature": "14.4",
     "dewPoint": "5",
     "windSpeed": "04",
     "humidity": 53,
     "stationName": "San Francisco, San Francisco International Airport",
     "datetime": "2012-11-14 03:56:00",
     "lat": 37.61666666666667
     }
     } */
    
    // Using Google Places API:
    // https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.8015957,-122.4735831&rankby=distance&types=establishment&sensor=true&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc
    //
    // http://maps.googleapis.com/maps/api/geocode/json?latlng=37.8015957,-122.4735831&sensor=true&types=locality
    NSString *url = [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyPlaceNameJSON?lat=%f&lng=%f&username=rescribble",
                     coord.latitude, coord.longitude];
    theURL = [[NSURL URLWithString:url] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    if (apiConnection) {
        [apiConnection release];
    }
    apiConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - Lifecycle
- (id)init {
    self = [super init];
    if (self) {
        pendingRequest = NO;
    }
    return self;
}

-(void)dealloc {
    [apiConnection release];
    [responseData release];
    [theURL release];
    [super dealloc];
}

#pragma mark - NSURLConnection delegate methods

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    pendingRequest = NO;
    NSLog(@"@FindNearbyplace connectionDidFinishLoading");
    
    // get content using JSONKit
    JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *firstLocation;
    @try {
        firstLocation = [[[parser objectWithData:responseData] objectForKey:@"geonames"] objectAtIndex:0];
    }
    @catch (NSException *e) {
        firstLocation = nil;
        NSLog(@"Exception caught while parsing JSON");
    }
    
    [self.delegate findNearbyPlaceDidFinish:firstLocation];
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
    pendingRequest = NO;
}

@end
