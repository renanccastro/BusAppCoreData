//
//  BusTableViewController.m
//  BusAppCoreData
//
//  Created by Flavio Matheus on 30/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "BusTableViewController.h"
#import "Bus_line+Core_Data_Methods.h"
#import "BusLineViewController.h"

@interface BusTableViewController ()

@end

@implementation BusTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.busLinesInStop count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Bus Line";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	NSString *text  = ((Bus_line*)self.busLinesInStop[indexPath.row]).full_name;
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier] isEqualToString:@"BusTrajectory"])
    {
        BusLineViewController *tela = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForCell:sender];
        tela.rotaDeIda = [((Bus_line*)self.busLinesInStop[path.row]).polyline_ida allObjects];
        tela.rotaDeVolta = [((Bus_line*)self.busLinesInStop[path.row]).polyline_volta allObjects];

    }
}



@end
