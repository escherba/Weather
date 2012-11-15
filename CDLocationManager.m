/**
 * @file
 *
 * @author Chris Doble
 * @date 07/08/2011
 */

#import "CDLocationManager.h"

/**
 * @brief The maximum "age" of a location update (in seconds).
 *
 * Location updates that are older than this value will be rejected. This
 * prevents "cached" updates from being passed through to the delegate.
 *
 * You shouldn't need to change this value.
 */
#define CD_LOCATION_MANAGER_LIFETIME 1

/**
 * @brief The minimum acceptable accuracy for a location update to be considered
 *     accurate (in metres). Based on the <tt>horizontalAccuracy</tt> property.
 *
 * Accuracy often increases in successive location updates; this value
 * determines when we should accept an update as being "accurate enough".
 *
 * Decreasing this value means that fewer, more accurate updates will be sent to
 * the delegate, but it is likely increase the occurrence of timeouts and make
 * the manager less robust. If you encounter these problems, just use the GPS.
 */
#define CD_LOCATION_MANAGER_MINIMUM_ACCURACY 65

/**
 * @brief The longest we will wait for an accurate location update (in seconds).
 *
 * Sometimes the GPS can't get an accurate fix on the device's location. This
 * value determines when we should just give up and wait for another update.
 *
 * Decreasing this value will reduce power consumption as the GPS won't be on
 * for as long. You need to strike a balance between this value an the minimum
 * accuracy; if this is too low and it's too high, you'll continually timeout.
 */
#define CD_LOCATION_MANAGER_TIMEOUT 60

#pragma mark -

@interface CDLocationManager ()

#pragma mark - Properties

// Whether the next update will be accurate (rather than significant).
@property (nonatomic, assign, getter=isAccurateUpdate) BOOL accurateUpdate;

// When we turned the GPS on to generate an accurate update.
@property (nonatomic, retain) NSDate *accurateUpdateStarted;

// Whether the next update will be the first.
@property (nonatomic, assign, getter=isFirstUpdate) BOOL firstUpdate;

// Our source of raw location updates.
@property (nonatomic, retain) CLLocationManager *locationManager;

// Whether the location manager is monitoring the device's location.
@property (nonatomic, assign, getter=isRunning) BOOL running;

@end

#pragma mark -

@implementation CDLocationManager

- (id)init {
  if ((self = [super init])) {
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
  }

  return self;
}

- (void)startUpdatingLocation {
  if (self.isRunning) {
    return;
  }

  self.running = YES;
  self.firstUpdate = YES;
  [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopUpdatingLocation {
  if (!self.isRunning) {
    return;
  }

  self.running = NO;
  self.accurateUpdate = NO;
  self.accurateUpdateStarted = nil;
  [self.locationManager stopUpdatingLocation];
  [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  // Reject old updates unless this is the first update. If this is the first
  // update, it doesn't matter if it's old because we'll turn the GPS on anyway.
  if (ABS([newLocation.timestamp timeIntervalSinceNow]) >
      CD_LOCATION_MANAGER_LIFETIME && !self.isFirstUpdate) {
    return;
  }

  self.firstUpdate = NO;

  if (self.isAccurateUpdate) {
    // Have we got an accurate location update or timed out?
    BOOL finished = NO;
    BOOL timedOut = ABS([self.accurateUpdateStarted timeIntervalSinceNow]) >=
        CD_LOCATION_MANAGER_TIMEOUT;

    // Is the location update accurate enough?
    if (newLocation.horizontalAccuracy <=
        CD_LOCATION_MANAGER_MINIMUM_ACCURACY) {
      finished = YES;
      [self.delegate locationManager:self didUpdateToLocation:newLocation];
    }

    if (finished || timedOut) {
      self.accurateUpdate = NO;
      self.accurateUpdateStarted = nil;
      [self.locationManager stopUpdatingLocation];
    }
  } else {
    // We got a significant location update, so fire up the GPS.
    self.accurateUpdate = YES;
    self.accurateUpdateStarted = [NSDate date];
    [self.locationManager startUpdatingLocation];
  }
}

- (void)dealloc {
  accurateUpdateStarted = nil;
  locationManager = nil;
  [super dealloc];
}

#pragma mark - Properties

@synthesize accurateUpdate;
@synthesize accurateUpdateStarted;
@synthesize delegate;
@synthesize firstUpdate;
@synthesize locationManager;
@synthesize running;

@end