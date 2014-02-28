//
//  TrajectoryViewController.h
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bus_line.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface TrajectoryViewController : UIViewController

@property (nonatomic, strong) NSArray *bus;
@property (nonatomic) CLLocationCoordinate2D initial;
@property (nonatomic) CLLocationCoordinate2D final;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (void)addRoute: (NSArray *)route;
- (void)justGotInfo;
- (CLLocationCoordinate2D)findBusStopNear: (CLLocationCoordinate2D) point;
- (BOOL)point: (CLLocationCoordinate2D)point belongsToGeobox: (NSMutableArray *)box;


@end
