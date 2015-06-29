//
//  NewDriveViewController.m
//  Come Follow Me
//
//  Created by Marty Lavender on 6/25/15.
//  Copyright (c) 2015 Marty Lavender. All rights reserved.
//

#import "NewDriveViewController.h"
#import "DetailViewController.h"
#import "Drive.h"

#import <CoreLocation/CoreLocation.h>
#import "MathController.h"
#import "Location.h"

#import <MapKit/MapKit.h>

#import <QuartzCore/QuartzCore.h>



static NSString * const detailSegueName = @"DriveDetails";

@interface NewDriveViewController () <UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) Drive *drive;


//labels and such
@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;

//math stuff
@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;


@end

@implementation NewDriveViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
 
	self.startButton.hidden = NO;
	self.promptLabel.hidden = NO;
 
	self.timeLabel.text = @"";
	self.timeLabel.hidden = YES;
	self.distLabel.hidden = YES;
	self.paceLabel.hidden = YES;
	self.stopButton.hidden = NO;
	self.stopButton.enabled = NO;
	
	self.mapView.hidden = NO;
	

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.timer invalidate];
}

- (void)eachSecond
{
	self.seconds++;
	self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
	self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
	self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
}

- (void)startLocationUpdates
{
	// Create the location manager if this object does not
	// already have one.
	if (self.locationManager == nil) {
		self.locationManager = [[CLLocationManager alloc] init];
	}
 
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.locationManager.activityType = CLActivityTypeFitness;
 
	// Movement threshold for new events.
	self.locationManager.distanceFilter = 10; // meters
	
	[self.locationManager requestWhenInUseAuthorization];
	[self.locationManager startUpdatingLocation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolyline *polyLine = (MKPolyline *)overlay;
		MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
		polylineRenderer.strokeColor = [UIColor blueColor];
		polylineRenderer.fillColor = [UIColor blueColor];
		polylineRenderer.lineWidth = 5.0;
		
		//[mapView addOverlay:polyLine level:MKOverlayLevelAboveRoads];
		
		return polylineRenderer;
	}
	return nil;
}

-(IBAction)startPressed:(id)sender
{
	// hide the start UI
	self.startButton.hidden = YES;
	self.promptLabel.hidden = YES;
 
	// show the running UI
	self.timeLabel.hidden = NO;
	self.distLabel.hidden = NO;
	self.paceLabel.hidden = NO;
	self.stopButton.hidden = YES;
	

	
	self.seconds = 0;
	self.distance = 0;
	self.locations = [NSMutableArray array];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
												selector:@selector(eachSecond) userInfo:nil repeats:YES];
	[self startLocationUpdates];
	self.mapView.hidden = NO;
	[_mapView setShowsUserLocation:YES];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
	for (CLLocation *newLocation in locations) {
		
		NSDate *eventDate = newLocation.timestamp;
		
		NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
		
		if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
			
			// update distance
			if (self.locations.count > 0) {
				self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
				
				CLLocationCoordinate2D coords[2];
				coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
				coords[1] = newLocation.coordinate;
				
				MKCoordinateRegion region =
				MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
				[self.mapView setRegion:region animated:YES];
				
				[self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
				//[self.mapView addOverlay:self.mapView level:MKOverlayLevelAboveRoads];
			}
			
			[self.locations addObject:newLocation];
		}
	}
}

- (void)saveDrive
{
	Drive *newDrive = [NSEntityDescription insertNewObjectForEntityForName:@"Drive"
            inManagedObjectContext:self.managedObjectContext];
 
	newDrive.distance = [NSNumber numberWithFloat:self.distance];
	newDrive.duration = [NSNumber numberWithInt:self.seconds];
	newDrive.timestamp = [NSDate date];
 
	NSMutableArray *locationArray = [NSMutableArray array];
	for (CLLocation *location in self.locations) {
		Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
																 inManagedObjectContext:self.managedObjectContext];
		
		locationObject.timestamp = location.timestamp;
		locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
		locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
		[locationArray addObject:locationObject];
	}
 
	newDrive.locations = [NSOrderedSet orderedSetWithArray:locationArray];
	self.drive = newDrive;
 
	// Save the context.
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (IBAction)stopPressed:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self
													cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
													otherButtonTitles:@"Keep This Drive", @"Get Rid Of It", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.locationManager stopUpdatingLocation];
 
	// save
	if (buttonIndex == 0) {
		[self saveDrive];
		[self performSegueWithIdentifier:detailSegueName sender:nil];
		
		// discard
	} else if (buttonIndex == 1) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

//pops to the root when the save button is tapped
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[[segue destinationViewController] setDrive:self.drive];
}

@end
