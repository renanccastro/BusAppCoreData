//
//  TabBarViewController.h
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 11/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetInfo <NSObject>

-(void)setInfoForController:(id)controller;

@end

@interface TabBarViewController : UITabBarController

@end
