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

    [self setupPage];
    NSLog(@"# viewDidLoad called");
}

// TODO: see if we need the method below to load forecast
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"# viewDidAppear called");
    //[self refreshView:self];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
    
    // viewDidUnload deprecated in iOS6
    [flipsideController release];

    [scrollView release];
    [pageControl release];
    
    // free up controller array
    //for (RSLocalPageController* controller in controllers) {
    //    [controller release];
    //}
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

# pragma mark - FlipsideViewControllerDelegate
-(void)saveSettings {
    // save user selections
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
    [controllers addObject:controller];
    [controller release];
    
    NSUInteger numberOfViews = [modelArray count];
    scrollView.contentSize = CGSizeMake(viewFrameSize.width * numberOfViews, viewFrameSize.height);
    pageControl.numberOfPages = numberOfViews;
    
    // save user selection
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
    
    // removeObjectAtIndex will release the object,
    // so no neeed to call [controller release] here
    RSLocalPageController* controller = [controllers objectAtIndex:index];
    [controller.view removeFromSuperview];
    [controllers removeObjectAtIndex:index];

    // shift all the views afterwards to the left
    NSUInteger i;
    NSUInteger numberOfViews = [controllers count];
    CGSize viewFrameSize = self.view.frame.size;
    for (i = index; i < numberOfViews; i++) {
        controller = [controllers objectAtIndex:i];
        CGFloat xOrigin = i * viewFrameSize.width;
        controller.view.frame = CGRectMake(xOrigin, 0, viewFrameSize.width, viewFrameSize.height);
    }
    
    //now resize the entire scrollview so that we don't get empty space on the right
    scrollView.contentSize = CGSizeMake(viewFrameSize.width * numberOfViews, viewFrameSize.height);
    
    // fix up PageControl
    pageControl.numberOfPages = numberOfViews;
    
    // save user selection
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
