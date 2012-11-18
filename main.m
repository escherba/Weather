//
//  main.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([[[UIApplication sharedApplication] delegate] class]));
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    pool = nil;
    return retVal;
}
