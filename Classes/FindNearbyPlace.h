//
//  FindNearbyPlace.h
//  Weather
//
//  Created by Eugene Scherba on 11/10/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FindNearbyPlaceDelegate;

@interface FindNearbyPlace : NSObject {
    NSMutableData *responseData;
    NSURL *theURL;
    NSURLConnection *apiConnection;
    
    id<FindNearbyPlaceDelegate> delegate;
    BOOL pendingRequest;
}

-(void)queryServiceWithCoord:(CLLocationCoordinate2D)coord;

@property (nonatomic, assign) id<FindNearbyPlaceDelegate> delegate;
@end

@protocol FindNearbyPlaceDelegate
-(void)findNearbyPlaceDidFinish:(NSDictionary*)dict;
@end