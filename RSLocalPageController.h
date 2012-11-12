//
//  RSLocalPageController.h
//  Weather
//
//  Created by Eugene Scherba on 11/7/12.
//
//

#import <UIKit/UIKit.h>
#import "WeatherForecast.h"
#import "RSAddGeo.h"

@interface RSLocalPageController : UIViewController <UITableViewDelegate, UITableViewDataSource, WeatherForecastDelegate> {

    IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
    
    // different location (in different time zones) could have different dates
    NSDateFormatter *weekdayFormatter;

    IBOutlet UIImageView *nowImage;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *nowTempLabel;
    IBOutlet UILabel *nowHumidityLabel;
    IBOutlet UILabel *nowWindLabel;
    IBOutlet UILabel *nowConditionLabel;
    
    IBOutlet UITableView *_tableView;
}

-(void)viewMayNeedUpdate;

/* TODO: implement shake-to-refresh */
- (IBAction)refreshView;

@property (nonatomic, retain) UIActivityIndicatorView *loadingActivityIndicator;
@property (nonatomic, retain) WeatherForecast *forecast;
@property (nonatomic, assign) RSLocality* locality;

// debug
@property (nonatomic, assign) NSUInteger pageNumber;

@end
