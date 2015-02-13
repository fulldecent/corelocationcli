#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Delegate : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL once;
@property (nonatomic) BOOL verbose;
@property (nonatomic, retain) NSString* format;
@end

@implementation Delegate;

@synthesize format;
@synthesize verbose;
@synthesize once;

- (void)start
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;

    if(self.verbose) {
        NSLog(@"authorizationStatus: %d", [CLLocationManager authorizationStatus]);
        NSLog(@"locationServicesEnabled: %d", [CLLocationManager locationServicesEnabled]);
        NSLog(@"significantLocationChangeMonitoringAvailable: %d", [CLLocationManager significantLocationChangeMonitoringAvailable]);
        NSLog(@"headingAvailable: %d", [CLLocationManager headingAvailable]);
        NSLog(@"regionMonitoringAvailable: %d", [CLLocationManager regionMonitoringAvailable]);
    }

    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    if( self.format == nil ){
        printf( "%s\n", [newLocation.description UTF8String] );
    } else {
        NSMutableString *output = [format mutableCopy];

        [output replaceOccurrencesOfString:@"%latitude"
                                withString:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];
        [output replaceOccurrencesOfString:@"%longitude"
                                withString:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];
        [output replaceOccurrencesOfString:@"%altitude"
                                withString:[NSString stringWithFormat:@"%f", newLocation.altitude]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];
        [output replaceOccurrencesOfString:@"%direction"
                                withString:[NSString stringWithFormat:@"%f", newLocation.course]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];
        [output replaceOccurrencesOfString:@"%speed"
                                withString:[NSString stringWithFormat:@"%d", (int) newLocation.speed]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];
        [output replaceOccurrencesOfString:@"%h_accuracy"
                                withString:[NSString stringWithFormat:@"%d", (int) newLocation.horizontalAccuracy]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];
        [output replaceOccurrencesOfString:@"%v_accuracy"
                                withString:[NSString stringWithFormat:@"%d", (int) newLocation.verticalAccuracy]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];
        [output replaceOccurrencesOfString:@"%time"
                                withString:[newLocation.timestamp description]
                                   options:NSLiteralSearch range:NSMakeRange(0, [output length])];

        printf( "%s\n", [output UTF8String] );
    }

    if (self.once) exit(0);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    printf ( "ERROR: %s\n", [[error localizedDescription] UTF8String]);
    exit(1);
}

@end

void help()
{
    printf( "USAGE: CoreLocationCLI [options]\n");
    printf( "       Displays current location using CoreLocation services.\n" );
    printf( "       By default, this will continue printing locations until you kill it with Ctrl-C.\n" );
    printf( "\n" );
    printf( "OPTIONS:\n" );
    printf( "  -h               Display this help message and exit\n" );
    printf( "\n" );
    printf( "  -once YES        Print one location and exit\n");
    printf( "  -verbose YES     Verbose mode\n");
    printf( "  -format 'format' Print a formatted string with the following specifiers\n" );
    printf( "     %%latitude\n" );
    printf( "     %%longitude\n" );
    printf( "     %%altitude    (meters)\n" );
    printf( "     %%direction   (degrees from true north)\n" );
    printf( "     %%speed       (meters per second)\n" );
    printf( "     %%h_accuracy  (meters)\n" );
    printf( "     %%v_accuracy  (meters)\n" );
    printf( "     %%time\n" );
    printf( "\n" );
}

int main(int argc, const char * argv[])
{
    if ((argc > 1) && strcmp(argv[1], "-h") == 0) {
        help();
        exit(1);
    }

    @autoreleasepool {
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];

        Delegate *delegate = [[Delegate alloc] init];
        delegate.format    = [args stringForKey:@"format"];
        delegate.verbose   = [args boolForKey:@"verbose"];
        delegate.once      = [args boolForKey:@"once"];

        [delegate start];
        NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
        [runLoop run];
    }
    return 0;
}
