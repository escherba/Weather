//
//  UIImage+RSRoundCorners.h
//  Category extending UIImage to allow for rounded corners
//
//  Created by Eugene Scherba on 11/18/11.
//  http://stackoverflow.com/questions/2118613/how-do-i-add-a-uiimage-to-grouped-uitableviewcell-so-it-rounds-the-corners
//  http://atastypixel.com/blog/easy-rounded-corners-on-uitableviewcell-image-view/
//

#import <UIKit/UIKit.h>

@interface UIImage (RSRoundCorners)
- (UIImage *)roundCornersWithRadius:(CGFloat)radius;
- (UIImage *)imageScaledToSize:(CGSize)size;
@end
