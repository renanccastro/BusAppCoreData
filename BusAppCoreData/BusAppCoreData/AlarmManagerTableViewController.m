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
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        
        NSDate* pickerDate = [self.datePicker date];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:pickerDate];
        [components setCalendar:[NSCalendar currentCalendar]];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        NSString* time = [self timeFormatted:self.busTime.time.intValue];
        int forHours = [([time componentsSeparatedByString:@":"][0]) intValue];
        int forMinutes = [([time componentsSeparatedByString:@":"][1]) intValue];
        int newHours = ((forHours + hour)%24) + ((forMinutes + minute) / 60);
        int newMinutes = (forMinutes + minute) % 60;
        [date setHour:newHours];
        [date setMinute:newMinutes];
        
        
        NSDate *now = [NSDate date];
        NSDateComponents *componentsForFireDate = [calendar components:(NSYearCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit | NSWeekdayCalendarUnit) fromDate: now];
        [componentsForFireDate setWeekday: date.weekday]; //for fixing Sunday
        [componentsForFireDate setHour: newHours]; //for fixing 8PM hour
        [componentsForFireDate setMinute:newMinutes];
        [componentsForFireDate setSecond:0];

        
        NSDate *fireDateOfNotification = [calendar dateFromComponents: componentsForFireDate];
        localNotification.alertAction = [NSString stringWithFormat:@"Alerta do ônibus: %@", self.busTime.bus.line_number];
        localNotification.alertBody = [NSString stringWithFormat:@"Seu ônibus(%@) está chegando",self.busTime.bus.full_name];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        localNotification.fireDate = fireDateOfNotification;
        localNotification.repeatInterval = NSWeekCalendarUnit;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _daysOfWeek = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:[NSDate date]];
    
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0.0];
    
    NSDate *newDate = [calendar dateFromComponents:dateComponents];

    [self.datePicker setDate:newDate];
    
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
        NSDateComponents *weekdayComponents =[[NSDateComponents alloc] init];
        [weekdayComponents setWeekday:indexPath.row];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [_daysOfWeek removeObject:weekdayComponents];
        }else{
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [_daysOfWeek addObject:weekdayComponents];
        }
    }
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
}


@end
