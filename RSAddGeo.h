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

@interface RSLocality : NSObject
// this initialization occurs before details request is sent
-(id)initWithId:(NSString *)id1
      reference:(NSString *)ref1
    description:(NSString *)desc1;
@property (nonatomic, retain) NSString* apiId;
@property (nonatomic, retain) NSString* reference;
@property (nonatomic, retain) NSString* lat;
@property (nonatomic, retain) NSString* lng;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* formatted_address;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* vicinity;
@end

@interface RSAddGeo : UITableViewController <UISearchDisplayDelegate, UITableViewDelegate, UISearchBarDelegate> {

    // for querying Google Places API
    NSURL *theURL;
    NSURLConnection *apiConnection;
    NSMutableData *responseData;
    NSMutableArray *processedData;
    
    // interface stuff
    BOOL _cancelButtonClicked;
}

@property (nonatomic, retain, readonly) RSLocality* selectedLocality; // don't retain delegates
@property (nonatomic, assign) id <RSAddGeoDelegate> delegate; // don't retain delegates

@end
