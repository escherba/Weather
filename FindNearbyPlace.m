//
//  FindNearbyPlace.m
//  Weather
//
//  Can also use http://api.geonames.org/ webservice to reverse-lookup geolocation
//
//  Created by Eugene Scherba on 11/10/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

/* "The important part of the service is the element 'timezoneId'. The offset is redundant and only included because users have been asking for it. "
 * For timezone: http://api.geonames.org/timezoneJSON?lat=47.01&lng=10.2&username=rescribble
 {
 "time": "2012-11-29 05:37",
 "countryName": "Austria",
 "sunset": "2012-11-29 16:32",
 "rawOffset": 1,
 "dstOffset": 2,
 "countryCode": "AT",
 "gmtOffset": 1,
 "lng": 10.2,
 "sunrise": "2012-11-29 07:42",
 "timezoneId": "Europe/Vienna",
 "lat": 47.01
 }
 */

/********** Example ***************
 Query: http://api.geonames.org/findNearbyPlaceNameJSON?lat=37.791752&lng=-122.480210&username=rescribble
 
 Result:
 {
 "geonames": [{
 "countryName": "United States",
 "adminCode1": "CA",
 "fclName": "city, village,...",
 "countryCode": "US",
 "lng": -122.4869164,
 "fcodeName": "section of populated place",
 "distance": "0.68903",
 "toponymName": "Seacliff",
 "fcl": "P",
 "name": "Seacliff",
 "fcode": "PPLX",
 "geonameId": 5394077,
 "lat": 37.7885406,
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
    [responseData release];
    responseData = [[NSMutableData data] retain];
    
    /* With geonames API, can also return weather like this:
     http://api.geonames.org/findNearByWeatherJSON?lat=37.8015957&lng=-122.4735831&username=rescribble
     {
     "weatherObservation": {
     "weatherCondition": "n/a",
     "clouds": "few clouds",
     "observation": "KSFO 291656Z 12012KT 10SM FEW035 SCT065 OVC150 15/10 A3002 RMK AO2 SLP166 T01500100",
     "windDirection": 120,
     "ICAO": "KSFO",
     "seaLevelPressure": 1016.6,
     "elevation": 3,
     "countryCode": "US",
     "cloudsCode": "FEW",
     "lng": -122.36666666666666,
     "temperature": "15",
     "dewPoint": "10",
     "windSpeed": "12",
     "humidity": 72,
     "stationName": "San Francisco, San Francisco International Airport",
     "datetime": "2012-11-29 16:56:00",
     "lat": 37.61666666666667
     }
     } */
    
    // Using Google Places API:
    // https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.791752,-122.480210&rankby=distance&types=establishment&sensor=true&key=AIzaSyAU8uU4oGLZ7eTEazAf9pOr3qnYVzaYTCc
    /*
     {
     "html_attributions" : [],
     "next_page_token" : "CmRYAAAANhUIXA4dkYt4PKjxK0wMdho2NmZTMaJcO8PYRgTobbAG8mKMC-lwMi2LlNvm28KiUpNAQmno1crmlce3XrwX4HF7QW-0ANoXOO0X-UbFDuwLaD8-IVjCA42KS0F4bU1kEhB6hwlWnRxQQB_Tp7z3UVD5GhQHXmTtqy3i5enzOP_e86Yr3nIInw",
     "results" : [
     {
     "geometry" : {
     "location" : {
     "lat" : 37.7922610,
     "lng" : -122.4803280
     }
     },
     "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png",
     "id" : "91b1eac8c050515525e98a070a39c6d581ec63b7",
     "name" : "Presidio Residences",
     "photos" : [
     {
     "height" : 976,
     "html_attributions" : [],
     "photo_reference" : "CnRoAAAAR9LooeJKefCRekAqI-sWsFn6KqGHP9wGZVYaQnhsYH945gufwiEqsZdvpRB6iRGll814-29DQZOzHBE-yiCoLVCJfLulzFrzmocZBDfg5qxl-ZzSL_70kqVW7317SBSomb7PQvv417Z_YudXlP0VQBIQlL4svTCJnmtefAlXND3S0RoUJ7Hu4WxhiH5GExcr3jwnwQfx1jY",
     "width" : 1632
     }
     ],
     "rating" : 4.0,
     "reference" : "CqQBlAAAAB3vL70v6LpvmXv2f8rnr-c6SZW4YKwCTENVghD4J-YlHps5VNyTvW2Aus3s4KQR5vJckKEX82uCXM-5XDIDPwc9tAOwZyoFEiv01qpw6BdrvrLwkMhD8fINOdEOhgxo92oqwnj7vCHu45J0H0Ddqh-aG1szixYsPtAwg9yqCSJhSnM9y4tzLiELtFvLEBYUCzylvyjkmJ7L1I9ITVygFLwSEFmgPi6Qr-Ck9nbw2W9ykCMaFGjJ2mc71NR7CdNiC8fLZprdg5kc",
     "types" : [ "establishment" ],
     "vicinity" : "1504 Pershing Drive, San Francisco"
     },
     ...
     */
    // http://maps.googleapis.com/maps/api/geocode/json?latlng=37.791752,-122.480210&sensor=true&types=locality&rankby=distance
    /*
     {
     "results" : [
     {
     "address_components" : [
     {
     "long_name" : "1509",
     "short_name" : "1509",
     "types" : [ "street_number" ]
     },
     {
     "long_name" : "Presidio of San Francisco",
     "short_name" : "Presidio of San Francisco",
     "types" : [ "establishment" ]
     },
     {
     "long_name" : "Pershing Dr",
     "short_name" : "Pershing Dr",
     "types" : [ "route" ]
     },
     {
     "long_name" : "Presidio",
     "short_name" : "Presidio",
     "types" : [ "neighborhood", "political" ]
     },
     {
     "long_name" : "San Francisco",
     "short_name" : "SF",
     "types" : [ "locality", "political" ]
     },
     ...
     */
    NSString *url = [NSString stringWithFormat:@"http://api.geonames.org/findNearbyPlaceNameJSON?lat=%f&lng=%f&username=rescribble",
                     coord.latitude, coord.longitude];
    
    [theURL release];
    theURL = [[NSURL URLWithString:url] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    
    [apiConnection release];
    apiConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - Lifecycle
- (id)init {
    self = [super init];
    if (self) {
        theURL = nil;
        responseData = nil;
        apiConnection = nil;
        pendingRequest = NO;
    }
    return self;
}

-(void)dealloc {
    [apiConnection release], apiConnection = nil;
    [responseData release], responseData = nil;
    [theURL release], theURL = nil;
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
    [theURL release]; //[theURL autorelease];
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
