//
//  UIImage+RSRoundCorners.m
//  Category extending UIImage to allow for rounded corners
//
//  Created by Eugene Scherba on 11/18/11. Based on:
//  http://stackoverflow.com/questions/2118613/how-do-i-add-a-uiimage-to-grouped-uitableviewcell-so-it-rounds-the-corners
//  http://atastypixel.com/blog/easy-rounded-corners-on-uitableviewcell-image-view/
//

#import "UIImage+RSRoundCorners.h"

void addRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat ovalWidth, CGFloat ovalHeight, CGFloat radius)
{
    if (ovalWidth == 0.0 || ovalHeight == 0.0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    
    CGFloat fw = CGRectGetWidth (rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight (rect) / ovalHeight;
    CGFloat fw_half = fw/2.0;
    CGFloat fh_half = fh/2.0;
    
    CGContextMoveToPoint(context, fw, fh_half);
    
    CGContextAddArcToPoint(context, fw,  fh,  fw_half, fh,      radius);
    CGContextAddArcToPoint(context, 0.0, fh,  0.0,     fh_half, radius);
    CGContextAddArcToPoint(context, 0.0, 0.0, fw_half, 0,       radius);
    CGContextAddArcToPoint(context, fw,  0.0, fw,      fh_half, radius); 

    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@implementation UIImage (RSRoundCorners)

- (UIImage *)roundCornersWithRadius:(CGFloat)radius {
    int w = self.size.width;
    int h = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0.0, 0.0, w, h);
    addRoundedRectToPath(context, rect, 4.0, 4.0, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, w, h), self.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);

    return img;    
}

- (UIImage*)imageScaledToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
