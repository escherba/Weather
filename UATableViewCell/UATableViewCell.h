//
//  UATableViewCell.h
//  Weather
//
//  Created by Eugene Scherba on 11/25/12.
//
//  Subclassing UITableViewCell to have gradient drawn by default

#import <UIKit/UIKit.h>
#import "UACellBackgroundView.h"

@interface UATableViewCell : UITableViewCell

- (void)setPosition:(UACellBackgroundViewPosition)newPosition;

@end
