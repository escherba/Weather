//
//  WeatherModel.m
//  Weather
//
//  This file contains implementation of two classes: RSCurrentCondition and RSDay
//
//  Created by Eugene Scherba on 11/16/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//


#import "WeatherModel.h"
//#import "ASIHTTPRequest.h"

//========================================================================
//Super class
@implementation RSCondition

@synthesize precipMM;
@synthesize winddirDegree;
@synthesize windspeedKmph;
@synthesize windspeedMiles;
@synthesize index;

@synthesize winddir16Point = _winddir16Point;
@synthesize condition = _condition;
@synthesize iconURL = _iconURL;
@synthesize iconData = _iconData;

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        
        //set defaults for assign variables
        index = -1;
        
        // set retained variables to nil
        _winddir16Point = nil;
        _condition = nil;
        _iconURL = nil;
        _iconData = nil;
    }
    return self;
}

-(id)initWithDict:(NSDictionary *)node withIndex:(NSInteger)pIndex
{
    // this method is specific for World Weather Online data
    self = [super init];
    if (self) {
        index = pIndex; // negative (error) value is default

        precipMM = [[node objectForKey:@"precipMM"] integerValue];
        winddirDegree = [[node objectForKey:@"winddirDegree"] integerValue];
        windspeedKmph = [[node objectForKey:@"windspeedKmph"] integerValue];
        windspeedMiles = [[node objectForKey:@"windspeedMiles"] integerValue];
        
        _winddir16Point = [[node objectForKey:@"winddir16Point"] retain];
        _condition = [[[[node objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"] retain];
        _iconURL = [[[[node objectForKey:@"weatherIconUrl"] objectAtIndex:0] objectForKey:@"value"] retain];
    }
    return self;
}

- (void)dealloc
{
    [_winddir16Point release], _winddir16Point = nil;
    [_condition release], _condition = nil;
    [_iconURL release],  _iconURL = nil;
    [_iconData release], _iconData = nil;
    [super dealloc];
}

#pragma mark - methods
-(NSString*)formatWindSpeedImperial:(BOOL)useImperial {
    if (useImperial) {
        return [NSString stringWithFormat:@"%u mph", windspeedMiles];
    } else {
        return [NSString stringWithFormat:@"%u kmph", windspeedKmph];
    }
}

@end

//========================================================================
@implementation RSCurrentCondition

@synthesize visibility;
@synthesize pressure;
@synthesize humidity;
@synthesize temp_C;
@synthesize temp_F;

-(id)initWithDict:(NSDictionary *)node withIndex:(NSInteger)index
{
    // this method is specific for World Weather Online data
    self = [super initWithDict:node withIndex:index];
    if (self) {
        visibility = [[node objectForKey:@"visibility"] integerValue];
        pressure = [[node objectForKey:@"pressure"] integerValue];
        humidity = [[node objectForKey:@"humidity"] integerValue];
        temp_C = [[node objectForKey:@"temp_C"] integerValue];
        temp_F = [[node objectForKey:@"temp_F"] integerValue];
    }
    return self;
}

// Public method: formatTemperature
-(NSString*) formatTemperatureImperial:(BOOL)useImperial {
    // stringWithFormat returns a string that is already autoreleased
    if (useImperial) {
        return [NSString stringWithFormat:@"%d°", temp_F];
    } else {
        return [NSString stringWithFormat:@"%d°", temp_C];
    }
}

@end

//========================================================================
@implementation RSDay

@synthesize date = _date;
@synthesize tempMaxF;
@synthesize tempMinF;
@synthesize tempMaxC;
@synthesize tempMinC;

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        // set retained variables to nil
        _date = nil;
    }
    return self;
}

-(id)initWithDict:(NSDictionary *)node withIndex:(NSInteger)index
{
    // this method is specific for World Weather Online data
    self = [super initWithDict:node withIndex:index];
    if (self) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        _date = [[dateFormatter dateFromString:[node objectForKey:@"date"]] retain];
        [dateFormatter release], dateFormatter = nil;
        
        tempMaxF = [[node objectForKey:@"tempMaxF"] integerValue];
        tempMinF = [[node objectForKey:@"tempMinF"] integerValue];
        tempMaxC = [[node objectForKey:@"tempMaxC"] integerValue];
        tempMinC = [[node objectForKey:@"tempMinC"] integerValue];
    }
    return self;
}

-(void)dealloc
{
    [_date release],      _date = nil;
    [super dealloc];
}

#pragma mark - methods
-(NSString*) getHiLoImperial:(BOOL)useImperial
{
    // stringWithFormat returns a string that is already autoreleased
    if (useImperial) {
        NSString *result = [NSString stringWithFormat:@"%d° / %d°",
                            self.tempMaxF,
                            self.tempMinF];
        NSLog(@"getHiLo called: using Fahrenheit: %@", result);
        return result;
    } else {
        NSString *result = [NSString stringWithFormat:@"%d° / %d°",
                            self.tempMaxC,
                            self.tempMinC];
        NSLog(@"getHiLo called: using Celsius: %@", result);
        return result;
    }
}

@end
//========================================================================