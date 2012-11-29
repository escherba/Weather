//
//  UATableViewCell.m
//  Weather
//
//  Created by Eugene Scherba on 11/25/12.
//
//

#import "UATableViewCell.h"

@implementation UATableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]) {
        
        // Background Image
        self.backgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
    }
    return self;
}

- (void)setPosition:(UACellBackgroundViewPosition)newPosition {
    [(UACellBackgroundView *)self.backgroundView setPosition:newPosition];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
