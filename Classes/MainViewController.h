//
//  MainViewController.h
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//


#import "FlipsideViewController.h"
#import "WeatherForecast.h"
#import "FindNearbyPlace.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIScrollViewDelegate, FindNearbyPlaceDelegate>
{
    NSUserDefaults *defaults;
    WeatherAppDelegate *appDelegate;
    
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    
    // objects that need to be released on dealloc
    NSMutableArray* controllers; // holds RSLocalPageController objects
    FlipsideViewController *flipsideController;
    UIScrollView *scrollView;
    UIPageControl *pageControl;

    NSTimer *timer;
}

-(void)currentLocationDidUpdate:(CLLocation *)location;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *modelArray;
@property (nonatomic, assign) BOOL useImperial;
@property (nonatomic, assign) BOOL showCurrentLocation;

/* TODO: implement shake-to-refresh? */

/* for Info button */
- (IBAction)showInfo:(id)sender;

/* for pageControl */
- (IBAction)changePage:(id)sender;

/* internal */
- (void)setupPage;

@end
