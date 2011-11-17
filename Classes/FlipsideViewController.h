//
//  FlipsideViewController.h
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;

@class WeatherAppDelegate;

@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
    IBOutlet UISwitch *toggleSwitch;
    WeatherAppDelegate *appDelegate;
    
    NSDictionary *tableContents;
    NSArray *sortedKeys;
}

@property (nonatomic,retain) NSDictionary *tableContents;
@property (nonatomic,retain) NSArray *sortedKeys;

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
- (IBAction)switchThrown;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

