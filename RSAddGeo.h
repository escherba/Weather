//
//  RSAddGeo.h
//  SearchTut2
//
//  Created by Eugene Scherba on 11/14/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSAddGeo;

@protocol RSAddGeoDelegate
-(void)geoAddControllerDidFinish:(RSAddGeo *)controller;
@end

@interface RSAddGeo : UITableViewController <UISearchDisplayDelegate, UITableViewDelegate, UISearchBarDelegate> {

    // for querying Google Places API
    NSMutableArray *apiData;
    NSURLConnection *apiConnection;
    NSMutableData *responseData;
    NSURL *theURL;
    BOOL _cancelButtonClicked;
}

@property (nonatomic, retain) NSString* selectedLocation;
@property (nonatomic, assign) id <RSAddGeoDelegate> delegate;

@end
