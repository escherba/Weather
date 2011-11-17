//
//  WeatherModel.h
//  Weather
//
//  Created by Eugene Scherba on 11/16/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>

//========================================================================
@interface RSCondition : NSObject

@property (nonatomic, retain) NSString* wind;
@property (nonatomic, retain) NSString* humidity;
@property (nonatomic, retain) NSString* tempF;
@property (nonatomic, retain) NSString* tempC;
@property (nonatomic, retain) NSString* condition;
@property (nonatomic, retain) NSString* iconURL;
@property (readonly, nonatomic, retain) UIImage* iconData;

-(NSString*) formatTemperature;
-(void) loadIcon;

@end
//========================================================================
@interface RSDay : NSObject

@property (nonatomic, retain) NSString* date;
@property (nonatomic, retain) NSString* highT;
@property (nonatomic, retain) NSString* lowT;
@property (nonatomic, retain) NSString* condition;
@property (nonatomic, retain) NSString* iconURL;
@property (readonly, nonatomic, retain) UIImage* iconData;

-(id)initWithDate:(NSString*)date1
            highT:(NSString*)highT1
             lowT:(NSString*)lowT1
        condition:(NSString*)condition1
          iconURL:(NSString*)iconURL1;
-(NSString*) getHiLo;
-(void) loadIcon;
@end
//========================================================================
