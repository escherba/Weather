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

@synthesize wind;
@synthesize humidity;
@synthesize tempC;
@synthesize tempF;
@synthesize condition;
@synthesize iconURL = _iconURL;
@synthesize iconData = _iconData;

// Lifecycle methods: dealloc
- (void)dealloc {
    [wind release];
    [humidity release];
    [tempC release];
    [tempF release];
    [condition release];
    [_iconURL release];
    [_iconData release];
    [super dealloc];
}

// Public method: formatTemperature
-(NSString*) formatTemperature {
    // stringWithFormat returns a string that is already autoreleased
    return [NSString stringWithFormat:@"%@F (%@C)", 
            self.tempF, 
            self.tempC];
}

// method: setIconURL
-(void)setIconURL:(NSString *)iconURL {
    _iconURL = [iconURL retain];
    [self loadIcon];
}

// method: loadIcon
-(void)loadIcon {
    [self.iconData release];
    if (self.iconURL) {
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.iconURL]]];
        _iconData = [[img roundCornersWithRadius:3.0] retain];
        [img release];
    }
}

@end

//========================================================================
@implementation RSDay

@synthesize date;
@synthesize highT;
@synthesize lowT;
@synthesize condition;
@synthesize iconURL = _iconURL;
@synthesize iconData = _iconData;

// Lifecycle methods: initWithDate
- (id)initWithDate:(NSDate*)date1
             highT:(NSString*) highT1
              lowT:(NSString*) lowT1
         condition:(NSString*)condition1
           iconURL:(NSString*)iconURL1
{
    self = [super init];
    if (self) {
        date = [date1 retain];
        lowT = [lowT1 retain];
        highT = [highT1 retain];
        condition = [condition1 retain];
        _iconURL = [iconURL1 retain];
        [self loadIcon];
    }
    return self;
}

// Lifecycle methods: dealloc
- (void)dealloc {
    [date release];
    [lowT release];
    [highT release];
    [condition release];
    [_iconURL release];
    [_iconData release];
    [super dealloc];
}

// Public method: getHiLo
-(NSString*) getHiLo {
    // stringWithFormat returns a string that is already autoreleased
    return [NSString stringWithFormat:@"%@° / %@°", 
            self.highT, 
            self.lowT];
}

// method: setIconURL
-(void)setIconURL:(NSString *)iconURL {
    _iconURL = [iconURL retain];
    [self loadIcon];
}

// method: loadIcon (TODO: note that this method's definition is repeated for different interface)
-(void)loadIcon {
    [self.iconData release];
    if (self.iconURL) {
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.iconURL]]];
        _iconData = [[[img roundCornersWithRadius:3.0] imageScaledToSize:CGSizeMake(40, 40)] retain];
        [img release];
    }
}

@end
//========================================================================