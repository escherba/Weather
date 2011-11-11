//
//  MainViewController.h
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import "FlipsideViewController.h"
#import "WeatherForecast.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	
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
	
	IBOutlet UILabel *dayOneLabel;
	IBOutlet UIImageView *dayOneImage;
	IBOutlet UILabel *dayOneTempLabel;
	IBOutlet UILabel *dayOneChanceLabel;
	
	IBOutlet UILabel *dayTwoLabel;
	IBOutlet UIImageView *dayTwoImage;
	IBOutlet UILabel *dayTwoTempLabel;
	IBOutlet UILabel *dayTwoChanceLabel;
	
	IBOutlet UILabel *dayThreeLabel;
	IBOutlet UIImageView *dayThreeImage;
	IBOutlet UILabel *dayThreeTempLabel;
	IBOutlet UILabel *dayThreeChanceLabel;

	IBOutlet UILabel *dayFourLabel;
	IBOutlet UIImageView *dayFourImage;
	IBOutlet UILabel *dayFourTempLabel;
	IBOutlet UILabel *dayFourChanceLabel;
}

- (IBAction)showInfo;
- (IBAction)refreshView:(id) sender;
- (void)updateView;

@property (nonatomic, retain) WeatherForecast *forecast;
@property(nonatomic, retain) UIActivityIndicatorView *loadingActivityIndicator;
@property(nonatomic,retain) NSString *locationName;

@end
