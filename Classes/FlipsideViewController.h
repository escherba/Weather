//
// FlipsideViewController.h
// Weather
//
// Created by Eugene Scherba on 1/11/11.
// Copyright 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSAddGeo.h"

@protocol FlipsideViewControllerDelegate;

@class WeatherAppDelegate;

@interface FlipsideViewController : UIViewController <RSAddGeoDelegate, UITableViewDelegate, UITableViewDataSource> {
    // ivar is autogenerated when the corresponding @property is specified
    //id <FlipsideViewControllerDelegate> delegate;
    WeatherAppDelegate *appDelegate;
    RSAddGeo *geoAddController;

    // for querying Google Places API
    NSURL *theURL;
    NSURLConnection *apiConnection;
    NSMutableData *responseData;
    NSMutableDictionary *modelDict;
    
    NSString *_currentLocalityId;
    IBOutlet UITableView *_tableView;
    NSMutableDictionary *tableContents;
}

@property (nonatomic, retain) IBOutlet UIButton *addCity;
@property (nonatomic, retain) NSMutableDictionary *tableContents;
@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate; // don't retain delegates

- (IBAction)addCityTouchDown;
- (IBAction)done:(id)sender;

@end

// A delegate of FlipsideViewController must implement the following protocol:
@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@property (nonatomic, retain) NSMutableArray *modelArray;
@end

