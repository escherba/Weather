//
//  FindNearbyPlace.m
//  Weather
//
//  Can also use http://api.geonames.org/ webservice to reverse-lookup geolocation
//
//  Created by Eugene Scherba on 11/10/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//



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
    if (pendingRequest) {
        NSLog(@"Canceling request because one is already pending");
        return;
        //[apiConnection cancel];
    }
    pendingRequest = YES;
    
    NSLog(@"FindNearbyPlace queryServiceWithCoord:");
    [responseData release];
    responseData = [[NSMutableData data] retain];
    
    /* With geonames API, can also return weather like this:
     http://api.geonames.org/findNearByWeatherJSON?lat=37.8015957&lng=-122.4735831&username=<YOUR_USERNAME>
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
    // https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.791752,-122.480210&rankby=distance&types=establishment&sensor=true&key=<YOUR_API_KEY>
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

    //NSString *url = [NSString stringWithFormat:@"http://api.geonames.org/findNearbyPlaceNameJSON?lat=%f&lng=%f&username=<YOUR_USERNAME>", coord.latitude, coord.longitude];
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true&types=locality&rankby=distance", coord.latitude, coord.longitude];
    
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
#pragma mark - internals
- (NSDictionary*)parseGeonamesWithData:(NSMutableData *)data
{
    /********** Example ***************
     Query: http://api.geonames.org/findNearbyPlaceNameJSON?lat=37.791752&lng=-122.480210&username=<YOUR_USERNAME>
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
     "name": "Seacliff", // <------ this is what we need
     "fcode": "PPLX",
     "geonameId": 5394077,
     "lat": 37.7885406,
     "adminName1": "California",
     "population": 0
     }]
     }
     **********************/
    JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *firstLocation = [[[parser objectWithData:data] objectForKey:@"geonames"] objectAtIndex:0];
    
    NSMutableDictionary *retValue = [NSMutableDictionary dictionary];
    [retValue setObject:[firstLocation objectForKey:@"name"] forKey:@"neighborhood"];
    [retValue setObject:[firstLocation objectForKey:@"countryCode"] forKey:@"countryCode"];
    return retValue;
}

- (NSDictionary*)componentWithResult:(NSDictionary *)result ofType:(NSString*)requestedType
{
    NSDictionary *neededComponent = nil;
    NSArray *addressComponents = [result objectForKey:@"address_components"];
    for (NSDictionary *addressComponent in addressComponents) {
        NSArray *types = [addressComponent objectForKey:@"types"];
        for (NSString *type in types) {
            if ([type isEqualToString:requestedType]) {
                neededComponent = addressComponent;
                break;
            }
        }
        if (neededComponent != nil) break;
    }
    return neededComponent;
}

- (NSDictionary*)componentWithResults:(NSArray*)results ofType:(NSString*)requestedType
{
    // helper function for parseGooglePlacesWithData
    NSDictionary *neededComponent = nil;
    for (NSDictionary *result in results) {
        neededComponent = [self componentWithResult:result ofType:requestedType];
        if (neededComponent != nil) break;
    }
    return neededComponent;
}

- (NSDictionary*)parseGooglePlacesWithData:(NSMutableData*)data
{
    /*
     Query: http://maps.googleapis.com/maps/api/geocode/json?latlng=37.791752,-122.480210&sensor=true&types=locality&rankby=distance
     Result:
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
    "status" : "OK"
     */
    JSONDecoder *parser = [JSONDecoder decoder]; // autoreleased
    NSDictionary *root = [parser objectWithData:data];
    NSString *status = [root objectForKey:@"status"];
    if (![status isEqualToString:@"OK"]) {
        return nil;
    }
    NSArray *results = [root objectForKey:@"results"];
    
    // first try to get neighborhood
    NSDictionary *neighborhood = [self componentWithResults:results ofType:@"neighborhood"];
    if (neighborhood == nil) {
        // failing that, look for locality
        neighborhood = [self componentWithResults:results ofType:@"locality"];
        if (neighborhood == nil) {
            // failing that, look for political
            neighborhood = [self componentWithResults:results ofType:@"political"];
        }
    }
    NSDictionary *country = [self componentWithResults:results ofType:@"country"];

    // autoreleased
    NSString *strNeighborhood = [neighborhood objectForKey:@"long_name"];
    NSString *strCountryCode = [country objectForKey:@"short_name"];
    NSLog(@"Location: %@, Country: %@", strNeighborhood, strCountryCode);
    NSMutableDictionary *retValue = [NSMutableDictionary dictionary];
    [retValue setObject:strNeighborhood forKey:@"neighborhood"];
    [retValue setObject:strCountryCode forKey:@"countryCode"];
    return retValue;
}

#pragma mark - NSURLConnection delegate methods

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    pendingRequest = NO;
    NSLog(@"@FindNearbyplace connectionDidFinishLoading");
    
    // get content using JSONKit
    NSDictionary *place;
    @try {
        //placeName = [self parseGeonamesWithData:responseData];
        place = [self parseGooglePlacesWithData:responseData];
    }
    @catch (NSException *e) {
        place = nil;
        NSLog(@"Exception caught while parsing JSON");
    }
    
    [self.delegate findNearbyPlaceDidFinish:place];
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
