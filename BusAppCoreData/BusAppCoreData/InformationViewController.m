//
//  InformationViewController.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 06/02/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "InformationViewController.h"
#import "MovingTitleCell.h"
#import "Bus_line+Core_Data_Methods.h"
#import "BusLineViewController.h"

@interface InformationViewController ()

@end

@implementation InformationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.busLine count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"infoCell";
    MovingTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.movingTitle.text = ((Bus_line*)self.busLine[indexPath.row]).full_name;
    cell.movingTitle.textColor = [UIColor orangeColor];
    cell.imageView.tintColor = self.collors[indexPath.row];
    
    if(indexPath.row %2)
    {
        cell.imageView.image = [[UIImage imageNamed:@"BlackBus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.imageView.image = [[UIImage imageNamed:@"WhiteBus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.backgroundColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier] isEqualToString:@"busTrajectory"])
    {
        BusLineViewController *tela = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForCell:sender];
        tela.rotaDeIda = [((Bus_line*)self.busLine[path.row]).polyline_ida allObjects];
        tela.rotaDeVolta = [((Bus_line*)self.busLine[path.row]).polyline_volta allObjects];
		tela.bus_line =((Bus_line*)self.busLine[path.row]);
		tela.color = self.collors[path.row];
        
    }
}


@end
