//
//  DetailViewController.m
//  Come Follow Me
//
//  Created by Marty Lavender on 6/25/15.
//  Copyright (c) 2015 Marty Lavender. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>

#import "MathController.h"
#import "Drive.h"
#import "Location.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDrive:(Drive *)drive {
	if (_drive != drive) {
	    _drive = drive;
		
	    // Update the view.
	    [self configureView];
	}
}

- (void)configureView {
	// Update the user interface for the detail item.
	self.distanceLabel.text = [MathController stringifyDistance:self.drive.distance.floatValue];
 
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	self.dateLabel.text = [formatter stringFromDate:self.drive.timestamp];
 
	self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.drive.duration.intValue usingLongFormat:YES]];
 
	self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist:self.drive.distance.floatValue overTime:self.drive.duration.intValue]];
	
	[self loadMap];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (MKCoordinateRegion)mapRegion
{
	MKCoordinateRegion region;
	Location *initialLoc = self.drive.locations.firstObject;
 
	float minLat = initialLoc.latitude.floatValue;
	float minLng = initialLoc.longitude.floatValue;
	float maxLat = initialLoc.latitude.floatValue;
	float maxLng = initialLoc.longitude.floatValue;
 
	for (Location *location in self.drive.locations) {
		if (location.latitude.floatValue < minLat) {
			minLat = location.latitude.floatValue;
		}
		if (location.longitude.floatValue < minLng) {
			minLng = location.longitude.floatValue;
		}
		if (location.latitude.floatValue > maxLat) {
			maxLat = location.latitude.floatValue;
		}
		if (location.longitude.floatValue > maxLng) {
			maxLng = location.longitude.floatValue;
		}
	}
 
	region.center.latitude = (minLat + maxLat) / 2.0f;
	region.center.longitude = (minLng + maxLng) / 2.0f;
 
	region.span.latitudeDelta = (maxLat - minLat) * 1.1f; // 10% padding
	region.span.longitudeDelta = (maxLng - minLng) * 1.1f; // 10% padding
 
	return region;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolyline *polyLine = (MKPolyline *)overlay;
		MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
		aRenderer.strokeColor = [UIColor blackColor];
		aRenderer.lineWidth = 3;
		return aRenderer;
	}
 
	return nil;
}

- (MKPolyline *)polyLine {
 
	CLLocationCoordinate2D coords[self.drive.locations.count];
 
	for (int i = 0; i < self.drive.locations.count; i++) {
		Location *location = [self.drive.locations objectAtIndex:i];
		coords[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
	}
 
	return [MKPolyline polylineWithCoordinates:coords count:self.drive.locations.count];
}

- (void)loadMap
{
	if (self.drive.locations.count > 0) {
		
		self.mapView.hidden = NO;
		
		// set the map bounds
		[self.mapView setRegion:[self mapRegion]];
		
		// make the line(s!) on the map
		[self.mapView addOverlay:[self polyLine]];
		
	} else {
		
		// no locations were found!
		self.mapView.hidden = NO;
		
		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:@"BOOM!"
								  message:@"Oops, it looks like this drive has no locations."
								  delegate:nil
								  cancelButtonTitle:@"Try Again"
								  otherButtonTitles:nil];
		[alertView show];
	}
}

@end
