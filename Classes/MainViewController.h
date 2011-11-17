//
//  MainViewController.h
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//


#import "FlipsideViewController.h"
#import "WeatherForecast.h"


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	WeatherForecast *forecast;
    WeatherAppDelegate *appDelegate;
    NSString *locationName;
	IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
	
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *dateLabel;
	
	IBOutlet UIImageView *nowImage;
	IBOutlet UILabel *nowTempLabel;
	IBOutlet UILabel *nowHumidityLabel;
	IBOutlet UILabel *nowWindLabel;
	IBOutlet UILabel *nowConditionLabel;

    IBOutlet UITableView *_tableView;
/*
    IBOutlet UIImageView *dayOneImage;
	IBOutlet UILabel *dayOneLabel;
	IBOutlet UILabel *dayOneTempLabel;
	IBOutlet UILabel *dayOneChanceLabel;

    IBOutlet UIImageView *dayTwoImage;
	IBOutlet UILabel *dayTwoLabel;
	IBOutlet UILabel *dayTwoTempLabel;
	IBOutlet UILabel *dayTwoChanceLabel;
	
    IBOutlet UIImageView *dayThreeImage;
	IBOutlet UILabel *dayThreeLabel;
	IBOutlet UILabel *dayThreeTempLabel;
	IBOutlet UILabel *dayThreeChanceLabel;

    IBOutlet UIImageView *dayFourImage;
	IBOutlet UILabel *dayFourLabel;
	IBOutlet UILabel *dayFourTempLabel;
	IBOutlet UILabel *dayFourChanceLabel;
*/
}

- (IBAction)showInfo;
- (IBAction)refreshView:(id) sender;
- (void)updateView;

@property (nonatomic, retain) WeatherForecast *forecast;
@property(nonatomic, retain) UIActivityIndicatorView *loadingActivityIndicator;
@property(nonatomic,retain) NSString *locationName;

@end
