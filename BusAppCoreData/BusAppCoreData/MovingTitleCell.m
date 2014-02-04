//
//  MovingTitleCell.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 04/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "MovingTitleCell.h"
#import "MarqueeLabel.h"

@interface MovingTitleCell ()

@end

@implementation MovingTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
