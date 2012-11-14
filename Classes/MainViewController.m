//
//  MainViewController.m
//  Weather
//
//  Created by Eugene Scherba on 1/11/11.
//  Copyright 2011 Boston University. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "WeatherAppDelegate.h"
#import "WeatherModel.h"
#import "RSLocalPageController.h"
#import "RSAddGeo.h"

@implementation MainViewController

@synthesize modelArray;
@synthesize scrollView;
@synthesize pageControl;
@synthesize trackLocation;

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

    defaults = [NSUserDefaults standardUserDefaults];
    appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];

    // restore user selections (do this before setupPage is called)
    [self restoreSettings];
    
    // if don't have any saved objects, use default
    NSUInteger numObjects = [modelArray count];
    if (trackLocation) {
        if (numObjects > 0) {
            RSLocality *locality = [modelArray objectAtIndex:0];
            if (!locality.trackLocation) {
                // set up a page at position zero representing current location
                RSLocality* defaultLocality = [[RSLocality alloc] initWithId:@"" reference:@"" description:@"Current Location"];
                defaultLocality.trackLocation = YES;
                [modelArray insertObject:defaultLocality atIndex:0];
                [defaultLocality release];
            }
        } else {
            // empty array
            // set up a page at position zero representing current location
            RSLocality* defaultLocality = [[RSLocality alloc] initWithId:@"" reference:@"" description:@"Current Location"];
            defaultLocality.trackLocation = YES;
            [modelArray addObject:defaultLocality];
            [defaultLocality release];
        }
    } else {
        if (numObjects < 1) {
            // default locality is San Francisco, CA
            RSLocality* defaultLocality = [[RSLocality alloc] initWithId:@"1b9ea3c094d3ac23c9a3afa8cd4d8a41f05de50a" reference:@"CkQ4AAAAtQXounq6fLeQifuqKBwOqg2lBXw3e14F2tpYq6Wq4aVEg8ntTYYm7SgoaJoSuJWaKqihCKxD-q4mqEKxpSXJ7RIQMYHFzmgd1BlKqSIiRvT_FRoUFhM0AAxFRnbO8S7QlZEjVa-a7aM" description:@"San Francisco, CA, United States"];
            // reference and id are not reliable, so we also add longitude and latitude
            CLLocationCoordinate2D defaultCoord;
            defaultCoord.latitude = 37.777940030048796;
            defaultCoord.longitude = -122.41945266723633;
            defaultLocality.coord = defaultCoord;
            defaultLocality.haveCoord = YES;
            [modelArray addObject:defaultLocality];
            [defaultLocality release];
        }
    }
    
    // flipside controller
    flipsideController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	flipsideController.delegate = self; // need FlipsideViewControllerDelegate in <> interface
	flipsideController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    // initialize model dictionary by using model array in the delegate object
    NSUInteger i;
    NSUInteger i_begin = (trackLocation) ? 1 : 0;
    NSUInteger i_end = [modelArray count];
    for (i = i_begin; i < i_end; i++) {
        RSLocality *locality = [modelArray objectAtIndex:i];
        [flipsideController.modelDict setObject:locality forKey:[locality apiId]];
    }

    [self setupPage];

    // The following calls allow us to update views with current forecasts.
    // Monitor "currentPage" property of pageControl:
    [pageControl addObserver:self
                  forKeyPath:@"currentPage"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:self];

    // Monitor "trackLocation" property
    /*
    [self addObserver:self
                  forKeyPath:@"trackLocation"
                     options:NSKeyValueObservingOptionNew
                     context:self];
     */
    
    // Ideally timer should be called after setupPage
    timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(400.0f) target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    
    NSLog(@"# viewDidLoad called");
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"######## view will appear #########");
    [super viewWillAppear:animated];
    
    // register applicationWillEnterForeground
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // overriding this method solely to remove applicationWillEnterForeground
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    // this gets called when the we switch from background to foreground mode
    NSLog(@"_________Entering foreground");
    
    // Notify the RSLocalPageController instance for which the view is currently visible
    // that it had become visible.
    // Additionally, whenever a user scrolls a page, notify the RSLocalPageController
    // instance using the same selector.
    [[controllers objectAtIndex:pageControl.currentPage] viewMayNeedUpdate];
}

- (void)dealloc {

    [self removeObserver:self forKeyPath:@"trackLocation" context:self];
    [pageControl removeObserver:self forKeyPath:@"currentPage" context:self];

    // remove timer
    [timer invalidate];
    timer = nil;
    
    // viewDidUnload deprecated in iOS6
    [flipsideController release];

    [scrollView release];
    [pageControl release];
    
    [modelArray release];
    [controllers release];
	[super dealloc];
}

# pragma mark - Info button
- (IBAction)showInfo:(id)sender {
	//[self presentModalViewController:flipsideController animated:YES];
    [self presentViewController:flipsideController animated:YES completion:nil];
}

# pragma mark - internals
-(void)insertTrackedLocality
{
    // take care of the model first
    RSLocality* defaultLocality = [[RSLocality alloc] initWithId:@"" reference:@"" description:@"Current Location"];
    defaultLocality.trackLocation = YES;
    [modelArray insertObject:defaultLocality atIndex:0];
    [defaultLocality release];

    // now the controllers
    CGSize viewFrameSize = self.view.frame.size;
    RSLocality* locality = [modelArray objectAtIndex:0];
    RSLocalPageController *controller = [[RSLocalPageController alloc] initWithNibName:nil bundle:nil];
    NSLog(@"Adding tracking page");
    controller.locality = locality;
    controller.pageNumber = 0;
    UIView* view = controller.view;
    view.frame = [self viewFrameWithX0:0 frameSize:viewFrameSize];
    [scrollView addSubview:view];
    [controllers insertObject:controller atIndex:0];
    [controller release];
    
    NSUInteger controllerCount = [controllers count];
    NSLog(@"Setting ScrollView width to %f * %u = %f", viewFrameSize.width, controllerCount, viewFrameSize.width * (CGFloat)controllerCount);
    scrollView.contentSize = CGSizeMake(viewFrameSize.width * (CGFloat)controllerCount, viewFrameSize.height);
    pageControl.numberOfPages = controllerCount;
    
    // rearrange following views
    NSUInteger i;
    for (i = 1; i < controllerCount; i++) {
        controller = [controllers objectAtIndex:i];
        controller.pageNumber = i;
        CGFloat xOrigin = i * viewFrameSize.width;
        controller.view.frame = [self viewFrameWithX0:xOrigin frameSize:viewFrameSize];
    }
    
    [self saveSettings];
}

- (void)setupPage {
    // line below is crucial for UIScrollViewDelegate protocol to work
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    
    NSUInteger numberOfViews = [modelArray count];
    controllers = [[NSMutableArray alloc] initWithCapacity:0];
    NSUInteger i = 0;
    
    CGSize viewFrameSize = self.view.frame.size;
    for (RSLocality* locality in modelArray) {
        CGFloat xOrigin = i * viewFrameSize.width;
        
        RSLocalPageController *controller = [[RSLocalPageController alloc] initWithNibName:nil bundle:nil];
        NSLog(@"Adding locality");
        controller.locality = locality;
        controller.pageNumber = i;
        UIView* view = controller.view;
        view.frame = [self viewFrameWithX0:xOrigin frameSize:viewFrameSize];
        
        [scrollView addSubview:view];
        [controllers addObject:controller];
        [controller release];
        i++;
    }
    scrollView.contentSize = CGSizeMake(viewFrameSize.width * numberOfViews, viewFrameSize.height);
    [self.view addSubview:scrollView];
    [scrollView release];
    
    pageControl.numberOfPages = numberOfViews;
    //pageControl.currentPage = 0;
}

-(void)restoreSettings {

    trackLocation = (BOOL)[defaults stringForKey:@"trackLocation"];
    
    // Localities array
    NSData *dataRepresentingSavedArray = [defaults objectForKey:@"localities"];
    if (dataRepresentingSavedArray != nil) {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (oldSavedArray != nil) {
            modelArray = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        } else {
            modelArray = [[NSMutableArray alloc] init];
        }
    } else {
        modelArray = [[NSMutableArray alloc] init];
    }

    NSLog(@"$$$$ Size of the restored array: %d", [modelArray count]);
}

// This will get called every 15 min in foreground mode
- (void)timerFired{
    [[controllers objectAtIndex:pageControl.currentPage] viewMayNeedUpdate];
    NSLog(@"Timer fired");
}

// this method should be called when scrollview is moved
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPage"]) {
        NSUInteger newPage = [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
        NSUInteger oldPage = [[change objectForKey:NSKeyValueChangeOldKey] unsignedIntegerValue];
        if (newPage != oldPage) {
            NSLog(@">>>> Current page changed from %u to %u", oldPage, newPage);
            // send a message to the controller that it will be displayed
            [[controllers objectAtIndex:newPage] viewMayNeedUpdate];
        }
    }
}

-(void) didUpdateToLocation:(CLLocation *)location
{
    NSLog(@"didUpdateToLocation called: %f, %f", location.coordinate.latitude,
          location.coordinate.longitude);
    NSLog(@"=> horiz: %f, vert: %f", [location horizontalAccuracy], [location verticalAccuracy]);
    
    // pass the coordinate to the locality object
    RSLocality *locality = [modelArray objectAtIndex:0];
    if (locality.trackLocation) {
        locality.coord = location.coordinate;
    }
}

# pragma mark - FlipsideViewControllerDelegate
-(NSUInteger)permanentLocalityCount
{
    NSUInteger lcount = [modelArray count];
    if (lcount == 0) {
        return lcount;
    } else if (trackLocation) {
        return lcount - 1;
    } else {
        return lcount;
    }
}

-(RSLocality*)getPermanentLocalityByRow:(NSUInteger)row
{
    NSUInteger pageIndex = (trackLocation) ? row + 1 : row;
    return [modelArray objectAtIndex:pageIndex];
}

-(void)saveSettings
{
    // save data models
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:modelArray] forKey:@"localities"];
    BOOL savedOK = [defaults synchronize];
    if (savedOK) {
        NSLog(@"$$$ Saved user selections, with model array size: %d", [modelArray count]);
    } else {
        NSLog(@"$$$ FAILED saving user selections, model array size: %d", [modelArray count]);
    }
}

- (void)addPageWithLocality:(RSLocality*)locality {
    [modelArray addObject:locality];
    
    CGSize viewFrameSize = self.view.frame.size;
    CGFloat xOrigin = scrollView.contentSize.width;
    RSLocalPageController *controller = [[RSLocalPageController alloc] initWithNibName:nil bundle:nil];
    NSLog(@"Adding locality");
    controller.locality = locality;
    
    UIView* view = controller.view;
    view.frame = [self viewFrameWithX0:xOrigin frameSize:viewFrameSize];
    [scrollView addSubview:view];
    
    // update controller array
    [controllers addObject:controller];
    [controller release];
    
    NSUInteger numberOfViews = [modelArray count];
    scrollView.contentSize = CGSizeMake(viewFrameSize.width * numberOfViews, viewFrameSize.height);
    pageControl.numberOfPages = numberOfViews;
    
    // save data model
    [self saveSettings];
}

-(CGRect)viewFrameWithX0:(CGFloat)xOrigin frameSize:(CGSize)viewFrameSize
{
    CGFloat borderWidth = 15.0f;
    CGFloat bottomOffset = 36.0f;
    return CGRectMake(xOrigin + borderWidth, borderWidth, viewFrameSize.width - borderWidth - borderWidth, viewFrameSize.height - borderWidth - bottomOffset);
    
    // for no modifications:
    //return CGRectMake(xOrigin, 0, viewFrameSize.width, viewFrameSize.height);
}

-(BOOL)firstPageIsTrackingLocation {
    if ([modelArray count] < 1) {
        return NO;
    } else {
        RSLocality* locality = [modelArray objectAtIndex:0];
        return locality.trackLocation;
    }
}

- (void)removePage:(NSInteger)index {
    
    if ([controllers count] < 1) {
        pageControl.numberOfPages = 0;
        [self saveSettings];
        return;
    }

    // Now the thing to do is to figure out if we have a controller tracking location.
    // If so, increment index by one.
    NSUInteger pageIndex = trackLocation ? index + 1 : index;
    
    // remove page with index... from UIScrollView
    NSLog(@"removing page: %u", pageIndex);
    
    RSLocality* locality = [modelArray objectAtIndex:pageIndex];
    [flipsideController.modelDict removeObjectForKey:[locality apiId]];
    [modelArray removeObjectAtIndex:pageIndex];
    
    // removeObjectAtIndex will release the object, no need to release controller
    RSLocalPageController* controller = [controllers objectAtIndex:pageIndex];
    [controller.view removeFromSuperview];

    // update controller array
    [controllers removeObjectAtIndex:pageIndex];

    // shift all the views afterwards to the left
    NSUInteger i;
    NSUInteger numberOfViews = [controllers count];
    CGSize viewFrameSize = self.view.frame.size;
    for (i = pageIndex; i < numberOfViews; i++) {
        controller = [controllers objectAtIndex:i];
        controller.pageNumber = i;
        CGFloat xOrigin = i * viewFrameSize.width;
        controller.view.frame = [self viewFrameWithX0:xOrigin frameSize:viewFrameSize];
    }

    //now resize the entire scrollview so that we don't get empty space on the right
    scrollView.contentSize = CGSizeMake(viewFrameSize.width * numberOfViews, viewFrameSize.height);
    
    // fix up PageControl
    pageControl.numberOfPages = numberOfViews;
    
    // save data model
    [self saveSettings];
}

- (void)insertViewFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    // Now the thing to do is to figure out if we have a controller tracking location.
    // If so, increment index by one.
    NSUInteger fromPageIndex = trackLocation ? fromIndex + 1 : fromIndex;
    NSUInteger toPageIndex = trackLocation ? toIndex + 1 : toIndex;
    NSLog(@"___ moving view from index %d to %d", fromPageIndex, toPageIndex);
    
    RSLocality *item = [[modelArray objectAtIndex:fromPageIndex] retain];
    [modelArray removeObject:item];
    [modelArray insertObject:item atIndex:toPageIndex];
    [item release];
    
    // update controller array
    RSLocalPageController* controller = [[controllers objectAtIndex:fromPageIndex] retain];
    [controllers removeObject:controller];
    [controllers insertObject:controller atIndex:toPageIndex];
    [controller release];

    // show all views at their proper locations
    CGSize viewFrameSize = self.view.frame.size;
    NSUInteger i;
    NSUInteger numberOfViews = [controllers count];
    for (i = 0; i < numberOfViews; i++) {
        controller = [controllers objectAtIndex:i];
        controller.pageNumber = i;
        CGFloat xOrigin = i * viewFrameSize.width;
        controller.view.frame = [self viewFrameWithX0:xOrigin frameSize:viewFrameSize];
    }
    
    // save data model
    [self saveSettings];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationSwitchSetTo:(BOOL)newState
{
    // Save the class member variable
    trackLocation = newState;
    NSLog( @"The switch is %@", trackLocation ? @"ON" : @"OFF" );
    [defaults setObject:[NSNumber numberWithBool:trackLocation] forKey:@"trackLocation"];
    if (trackLocation) {
        if ([modelArray count] == 0 || ![[modelArray objectAtIndex:0] trackLocation]) {
            [self insertTrackedLocality];
        }
        [appDelegate startUpdatingLocation:self withCallback:@selector(didUpdateToLocation:)];
    } else {
        [appDelegate stopUpdatingLocation];
        if ([modelArray count] > 0 && [self firstPageIsTrackingLocation]) {
            [self removePage:0];
        }
    }
}

#pragma mark - UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)__scrollView
{
    if (pageControlUsed) {
        return;
    }
    
    // prevent vertical bounces
    __scrollView.contentSize = CGSizeMake(__scrollView.contentSize.width,__scrollView.frame.size.height);
    
    // switch page at 50% across
    CGFloat pageWidth = __scrollView.frame.size.width;
    int page = floor((__scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    //NSLog(@"page: %d", page);
    
    // Because we use observer on pageControl, it is important that we do not call
    // the setter every time the page is moved slightly, otherwise observer will be
    // called too many times.
    if (pageControl.currentPage != page) {
        pageControl.currentPage = page;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__scrollView
{
    pageControlUsed = NO;
}

#pragma mark - PageControl stuff
- (IBAction)changePage:(id)sender
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    
    [scrollView scrollRectToVisible:frame animated:YES];
    pageControlUsed = YES;
}

#pragma mark - Screen orientation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // lock to portrait
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
