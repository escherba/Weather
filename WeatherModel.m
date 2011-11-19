//
//  WeatherModel.m
//  Weather
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

- (void)dealloc {
    [self.wind release];
    [self.humidity release];
    [self.tempC release];
    [self.tempF release];
    [self.condition release];
    [self.iconURL release];
    [self.iconData release];
    [super dealloc];
}

-(NSString*) formatTemperature {
    // stringWithFormat returns a string that is already autoreleased
    return [NSString stringWithFormat:@"%@F (%@C)", 
            self.tempF, 
            self.tempC];
}

-(void)setIconURL:(NSString *)iconURL {
    _iconURL = [iconURL retain];
    [self loadIcon];
}

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

- (id)initWithDate:(NSDate*)date1
             highT:(NSString*) highT1
              lowT:(NSString*) lowT1
         condition:(NSString*)condition1
           iconURL:(NSString*)iconURL1
{
    self = [super init];
    if (self) {
        self.date = [date1 retain];
        self.lowT = [lowT1 retain];
        self.highT = [highT1 retain];
        self.condition = [condition1 retain];
        self.iconURL = [iconURL1 retain];
        [self loadIcon];
    }
    return self;
}

- (void)dealloc {
    [self.date release];
    [self.lowT release];
    [self.highT release];
    [self.condition release];
    [self.iconURL release];
    [self.iconData release];
    [super dealloc];
}

-(NSString*) getHiLo {
    // stringWithFormat returns a string that is already autoreleased
    return [NSString stringWithFormat:@"%@° / %@°", 
            self.highT, 
            self.lowT];
}

-(void)setIconURL:(NSString *)iconURL {
    _iconURL = [iconURL retain];
    [self loadIcon];
}

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