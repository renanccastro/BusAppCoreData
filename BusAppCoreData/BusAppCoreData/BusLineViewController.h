//
//  BusLineViewController.h
//  BusAppCoreData
//
//  Created by Brenda Oliveira Ramires on 28/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataAndRequestSupervisor.h"
#import "Bus_line.h"

@interface BusLineViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSArray *rotaDeIda;
@property (nonatomic, strong) NSArray *rotaDeVolta;
@property (nonatomic)		  Bus_line*bus_line;

@end
