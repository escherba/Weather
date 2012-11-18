//
//  WeatherModel.m
//  Weather
//
//  This file contains implementation of two classes: RSCondition and RSDay
//
//  Created by Eugene Scherba on 11/16/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//


#import "WeatherModel.h"
#import "UIImage+RSRoundCorners.h"

//========================================================================
@implementation RSCondition

@synthesize windspeedMiles;
@synthesize windspeedKmph;
@synthesize humidity;
@synthesize temp_C;
@synthesize temp_F;
@synthesize condition;
@synthesize iconURL = _iconURL;
@synthesize iconData = _iconData;

// Lifecycle methods: dealloc
- (void)dealloc {
    [condition release], condition = nil;
    [_iconURL release],  _iconURL = nil;
    [_iconData release], _iconData = nil;
    [super dealloc];
}

// Public method:
-(NSString*)formatWindSpeedImperial:(BOOL)useImperial {
    if (useImperial) {
        return [NSString stringWithFormat:@"%u mph", windspeedMiles];
    } else {
        return [NSString stringWithFormat:@"%u kmph", windspeedKmph];
    }
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

// method: setIconURL
-(void)setIconURL:(NSString *)iconURL {
    _iconURL = [iconURL retain];
    [self loadIcon];
}

// method: loadIcon
-(void)loadIcon {
    [_iconData release];
    _iconData = nil;
    if (self.iconURL) {
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.iconURL]]];
        _iconData = [[img roundCornersWithRadius:3.0] retain];
        [img release];
        img = nil;
    }
}

@end

//========================================================================
@implementation RSDay

@synthesize date;
@synthesize tempMaxF;
@synthesize tempMinF;
@synthesize tempMaxC;
@synthesize tempMinC;
@synthesize condition;
@synthesize iconURL = _iconURL;
@synthesize iconData = _iconData;

// Lifecycle methods: initWithDate
- (id)initWithDate:(NSDate*)date1
          tempMaxF:(NSString*) highT1
              tempMinF:(NSString*) lowT1
             tempMaxC:(NSString*) highT2
              tempMinC:(NSString*) lowT2
         condition:(NSString*)condition1
           iconURL:(NSString*)iconURL1
{
    self = [super init];
    if (self) {
        date = [date1 retain];
        tempMaxF = [highT1 integerValue];
        tempMinF = [lowT1 integerValue];
        tempMaxC = [highT2 integerValue];
        tempMinC = [lowT2 integerValue];
        condition = [condition1 retain];
        _iconURL = [iconURL1 retain];
        [self loadIcon];
    }
    return self;
}

// Lifecycle methods: dealloc
- (void)dealloc {
    [date release],      date = nil;
    [condition release], condition = nil;
    [_iconURL release],  _iconURL = nil;
    [_iconData release], _iconData = nil;
    [super dealloc];
}

// Public method: getHiLo
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

// method: setIconURL
-(void)setIconURL:(NSString *)iconURL {
    _iconURL = [iconURL retain];
    [self loadIcon];
}

// method: loadIcon
-(void)loadIcon {
    [_iconData release];
    _iconData = nil;
    if (self.iconURL) {
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.iconURL]]];
        _iconData = [[[img roundCornersWithRadius:3.0] imageScaledToSize:CGSizeMake(40, 40)] retain];
        [img release];
        img = nil;
    }
}

@end
//========================================================================