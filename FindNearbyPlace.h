//
//  FindNearbyPlace.h
//  Weather
//
//  Created by Eugene Scherba on 11/10/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>

// type
@class WeatherAppDelegate;

@interface FindNearbyPlace : NSObject {
    WeatherAppDelegate *appDelegate;
    NSMutableData *responseData;
    NSURL *theURL;
}

-(void)queryServiceWithLat:(NSString *)latitude
                   andLong:(NSString*)longitude;

@end
