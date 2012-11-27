//
//  RSAddGeo.h
//  SearchTut2
//
//  Created by Eugene Scherba on 11/14/11.
//  Copyright (c) 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class RSAddGeo;

@protocol RSAddGeoDelegate
-(void)geoAddControllerDidFinish:(RSAddGeo *)controller;
@end

// have this object implement NSCoding protocol for saving with NSUserDefaults;
// implement initWithCoder and encodeWithCoder methods.
@interface RSLocality : NSObject <NSCoding> {
    // coord property has custom accessors
    CLLocationCoordinate2D coord;
}
- (id) initWithCoder: (NSCoder *)coder;
- (void) encodeWithCoder: (NSCoder *)coder;
- (void) updateFrom: (RSLocality *)locality;

// this initialization occurs before details request is sent
-(id)initWithId:(NSString *)id1
      reference:(NSString *)ref1
    description:(NSString *)desc1;
@property (nonatomic, retain) NSString* apiId;
@property (nonatomic, retain) NSString* reference;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* formatted_address;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* vicinity;

@property (nonatomic, assign) CLLocationCoordinate2D coord;
@property (nonatomic, assign) BOOL haveCoord;
@property (nonatomic, assign) BOOL trackLocation;
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
