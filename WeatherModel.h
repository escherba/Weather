//
//  WeatherModel.h
//  Weather
//
//  This is the header for implementation of two classes: RSCondition and RSDay
//
//  Created by Eugene Scherba on 11/16/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>

//========================================================================
@interface RSCondition : NSObject

@property (nonatomic, assign) NSUInteger windspeedMiles;
@property (nonatomic, assign) NSUInteger windspeedKmph;
@property (nonatomic, assign) NSUInteger humidity;
@property (nonatomic, assign) NSInteger temp_F;
@property (nonatomic, assign) NSInteger temp_C;
@property (nonatomic, retain) NSString* condition;
@property (nonatomic, retain) NSString* iconURL;
@property (nonatomic, retain, readonly) UIImage* iconData;

-(NSString*) formatWindSpeedImperial:(BOOL)useImperial;
-(NSString*) formatTemperatureImperial:(BOOL)useImperial;

// Public method: loadIcon
-(void) loadIcon;

@end
//========================================================================

@interface RSDay : NSObject

@property (nonatomic, retain) NSDate* date;
@property (nonatomic, assign) NSInteger tempMaxF;
@property (nonatomic, assign) NSInteger tempMinF;
@property (nonatomic, assign) NSInteger tempMaxC;
@property (nonatomic, assign) NSInteger tempMinC;
@property (nonatomic, retain) NSString* condition;
@property (nonatomic, retain) NSString* iconURL;
@property (nonatomic, retain, readonly) UIImage* iconData;

-(id)initWithDate:(NSDate*)date1
         tempMaxF:(NSString*)highT1
         tempMinF:(NSString*)lowT1
         tempMaxC:(NSString*)highT2
         tempMinC:(NSString*)lowT2
        condition:(NSString*)condition1
          iconURL:(NSString*)iconURL1;

-(NSString*) getHiLoImperial:(BOOL)useImperial;

// Public method: loadIcon
-(void) loadIcon;

@end
//========================================================================
