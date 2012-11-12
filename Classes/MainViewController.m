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

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    appDelegate = (WeatherAppDelegate*)[[UIApplication sharedApplication] delegate];

    timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(400.0f) target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    
    // restore user selections (do this before setupPage is called)
    [self restoreSettings];
    
    // if don't have any saved objects, use default
    NSUInteger numObjects = [modelArray count];
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
    
    // flipside controller
    flipsideController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	flipsideController.delegate = self; // need FlipsideViewControllerDelegate in <> interface
	flipsideController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // provide both old and new values to current page change observer
    [pageControl addObserver:self
                  forKeyPath:@"currentPage"
                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                     context:self];

    // TODO: consider adding a timer here
    //[NSTimer scheduledTimerWithTimeInterval:900.0f target:self selector:@selector(updateForecast) userInfo:nil repeats:YES];

    [self setupPage];
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
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"localities"];
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

// this method should be called when coordinates are added/updated
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

# pragma mark - FlipsideViewControllerDelegate
-(void)saveSettings {
    // save data models
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    [currentDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:modelArray] forKey:@"localities"];
    BOOL savedOK = [currentDefaults synchronize];
    
    if (savedOK) {
        NSLog(@"$$$ Saved user selections, with model array size: %d", [modelArray count]);
    } else {
        NSLog(@"$$$ FAILED saving user selections, model array size: %d", [modelArray count]);
    }
}

- (void)addPageWithLocality:(RSLocality*)locality {
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

- (void)removePage:(NSInteger)index {
    // remove page with index... from UIScrollView
    NSLog(@"removing page: %u", index);
    
    // removeObjectAtIndex will release the object, no need to release controller
    RSLocalPageController* controller = [controllers objectAtIndex:index];
    [controller.view removeFromSuperview];

    // update controller array
    [controllers removeObjectAtIndex:index];
    
    // shift all the views afterwards to the left
    NSUInteger i;
    NSUInteger numberOfViews = [controllers count];
    CGSize viewFrameSize = self.view.frame.size;
    for (i = index; i < numberOfViews; i++) {
        controller = [controllers objectAtIndex:i];
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
    NSLog(@"___ moving view from index %d to %d", fromIndex, toIndex);
    // update controller array
    RSLocalPageController* controller = [[controllers objectAtIndex:fromIndex] retain];
    [controllers removeObject:controller];
    [controllers insertObject:controller atIndex:toIndex];
    [controller release];
    
    // show all views at their proper locations
    CGSize viewFrameSize = self.view.frame.size;
    NSUInteger i;
    NSUInteger numberOfViews = [controllers count];
    for (i = 0; i < numberOfViews; i++) {
        controller = [controllers objectAtIndex:i];
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
    pageControl.currentPage = page;
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
