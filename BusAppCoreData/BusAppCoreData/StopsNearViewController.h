//
//  StopsNearViewController.h
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 27/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreDataAndRequestSupervisor.h"
#import "ECSlidingViewController.h"

@interface StopsNearViewController : UIViewController <CoreDataRequestDelegate>

@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic) BOOL isStopsOnScreen;

- (void)updateMapView;
- (void)creatAnnotationsFromBusPointsArray:(NSArray*)stopsNear;


@end
