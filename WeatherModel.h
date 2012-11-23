//
//  WeatherModel.h
//  Weather
//
//  This is the header for implementation of two classes: RSCurrentCondition and RSDay
//
//  Created by Eugene Scherba on 11/16/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>

//========================================================================
@interface RSCondition : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) double precipMM;
@property (nonatomic, assign) NSUInteger winddirDegree;
@property (nonatomic, assign) NSUInteger windspeedMiles;
@property (nonatomic, assign) NSUInteger windspeedKmph;
@property (nonatomic, retain) NSString* winddir16Point;
@property (nonatomic, retain) NSString* condition;
@property (nonatomic, retain) NSString* iconURL;
@property (nonatomic, retain) UIImage* iconData;

-(id)initWithDict:(NSDictionary *)node withIndex:(NSInteger)index;
-(NSString*) formatWindSpeedImperial:(BOOL)useImperial;

@end

//========================================================================
@interface RSCurrentCondition : RSCondition

@property (nonatomic, assign) NSUInteger visibility;
@property (nonatomic, assign) NSUInteger humidity;
@property (nonatomic, assign) NSInteger temp_F;
@property (nonatomic, assign) NSInteger temp_C;
@property (nonatomic, assign) NSUInteger pressure;

-(NSString*) formatTemperatureImperial:(BOOL)useImperial;

@end

//========================================================================
@interface RSDay : RSCondition

@property (nonatomic, retain) NSDate* date;
@property (nonatomic, assign) NSInteger tempMaxF;
@property (nonatomic, assign) NSInteger tempMinF;
@property (nonatomic, assign) NSInteger tempMaxC;
@property (nonatomic, assign) NSInteger tempMinC;

-(NSString*) getHiLoImperial:(BOOL)useImperial;

@end
//========================================================================
