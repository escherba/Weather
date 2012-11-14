/**
 * @file
 *
 * @author Chris Doble
 * @date 07/08/2011
 */

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class CDLocationManager;

/**
 * @brief A class must implement this protocol to be a
 *     <tt>CDLocationManager</tt> delegate.
 */
@protocol CDLocationManagerDelegate

/**
 * @brief Notifies the delegate that a location update is available.
 *
 * @param locationManager
 *   The location manager that generated the update.
 * @param location
 *   The location update.
 */
- (void)locationManager:(CDLocationManager *)locationManager
    didUpdateToLocation:(CLLocation *)location;

@end

#pragma mark -

/**
 * @brief Monitors the device's location, generating accurate location updates
 *     while using as little power as possible.
 */
@interface CDLocationManager : NSObject <CLLocationManagerDelegate>

/**
 * @brief Start generating location updates.
 */
- (void)startUpdatingLocation;

/**
 * @brief Stop generating location updates.
 */
- (void)stopUpdatingLocation;

/**
 * @brief The object that is to be sent location updates.
 */
@property (nonatomic, assign) id <CDLocationManagerDelegate> delegate;

//- (BOOL)isValidLocation:(CLLocation *)newLocation withOldLocation:(CLLocation *)oldLocation;

@end