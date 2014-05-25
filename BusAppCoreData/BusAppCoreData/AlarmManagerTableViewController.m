//
//  AlarmManagerTableViewController.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 25/05/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "AlarmManagerTableViewController.h"
#import "Bus_line.h"


@interface AlarmManagerTableViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) NSMutableArray* daysOfWeek;
@end

@implementation AlarmManagerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)setAlarm:(id)sender {
    for (NSDateComponents* date in self.daysOfWeek) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        NSDate* data = [self.datePicker date];
        
        [date setWeekday:date.weekday];
        
        localNotification.alertAction = [NSString stringWithFormat:@"Alerta do ônibus: %@", self.busTime.bus.line_number];
        localNotification.alertBody = [NSString stringWithFormat:@"Seu ônibus(%@) está chegando",self.busTime.bus.full_name];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        localNotification.fireDate = data;
        localNotification.repeatInterval = NSWeekCalendarUnit;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _daysOfWeek = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 7) {
        //trata-se de uma definição de repetição
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [_daysOfWeek removeObjectAtIndex:indexPath.row];
        }else{
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            NSDateComponents *weekdayComponents =[[NSDateComponents alloc] init];
            [weekdayComponents setWeekday:indexPath.row+1];
            [_daysOfWeek insertObject:weekdayComponents atIndex:indexPath.row];
        }
    }
}

@end
