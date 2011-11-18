//
//  RSAddGeo.h
//  SearchTut2
//
//  Created by Eugene Scherba on 11/14/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RSAddGeoDelegate;

@interface RSAddGeo : UITableViewController <UISearchDisplayDelegate, UITableViewDelegate, UISearchBarDelegate> {

    // for querying Google Places API
    NSMutableArray *apiData;
    NSURLConnection *apiConnection;
    NSMutableData *responseData;
    NSURL *theURL;
    
}

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

@property (nonatomic, assign) id <RSAddGeoDelegate> delegate;
@end

@protocol RSAddGeoDelegate
-(void)geoAddControllerDidFinish:(RSAddGeo *)controller;

@end
