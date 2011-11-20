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
    id <FlipsideViewControllerDelegate> delegate;
    //IBOutlet UISwitch *toggleSwitch;
    WeatherAppDelegate *appDelegate;
    RSAddGeo *geoAddController;

    IBOutlet UITableView *_tableView;
    NSDictionary *tableContents;
    NSArray *sortedKeys;
}

@property (nonatomic,retain) IBOutlet UIButton *addCity;
@property (nonatomic,retain) NSDictionary *tableContents;
@property (nonatomic,retain) NSArray *sortedKeys;

- (IBAction)addCityTouchDown;

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
- (IBAction)switchThrown;
@end

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;

@end

