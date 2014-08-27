#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Delegate : NSObject <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL once;
@end

@implementation Delegate;
@synthesize locationManager = _locationManager;
@synthesize once = _once;

- (void)start:(BOOL)once
{
    self.once = once;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    NSLog(@"Location: %@", self.locationManager.location);
    NSLog(@"authorizationStatus: %d", [CLLocationManager authorizationStatus]);
    NSLog(@"locationServicesEnabled: %d", [CLLocationManager locationServicesEnabled]);
    NSLog(@"significantLocationChangeMonitoringAvailable: %d", [CLLocationManager significantLocationChangeMonitoringAvailable]);
    NSLog(@"headingAvailable: %d", [CLLocationManager headingAvailable]);
    NSLog(@"regionMonitoringAvailable: %d", [CLLocationManager regionMonitoringAvailable]);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    printf ("%s\n", [newLocation.description UTF8String]);
    if (self.once) exit(0);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    printf ( "ERROR: %s\n", [[error localizedDescription] UTF8String]);
    exit(1);
}
@end

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        BOOL once = (argc > 1 && strcmp(argv[1], "--once") == 0);
        Delegate *delegate = [[Delegate alloc] init];
        [delegate performSelectorOnMainThread:@selector(start:) withObject:[NSNumber numberWithBool:once] waitUntilDone:NO];
        NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
        [runLoop run];
    }
    return 0;
}