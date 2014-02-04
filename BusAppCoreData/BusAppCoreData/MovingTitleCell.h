//
//  MovingTitleCell.h
//  BusAppCoreData
//
//  Created by Flavio Matheus on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface MovingTitleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MarqueeLabel *movingTitle;


@end
