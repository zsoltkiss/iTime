//
//  ProjectSummaryViewController.m
//  myTime
//
//  Created by Kiss Rudolf Zsolt on 2013.09.05..
//  Copyright (c) 2013 Kiss Rudolf Zsolt. All rights reserved.
//

#import "ProjectSummaryViewController.h"
#import "DBUtil.h"
#import "TimeSheetEntry.h"


@interface ProjectSummaryViewController () {
    NSArray *_entries;
}

- (void)readTimesheetFile;

- (void)readEntriesFromDatabase;

- (int)sumWorkHours;

@end

@implementation ProjectSummaryViewController

#pragma mark - private methods

- (NSString *)pathToDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
    
}

- (int)sumWorkHours {

    double sumInSeconds;
    
    BOOL calculateStarted = NO;
    
    NSDate *start, *stop;
    for(TimeSheetEntry *entry in _entries) {
        
        if(calculateStarted) {
            if([entry.activityDesc isEqualToString:STATUS_DESC_WORKING]) {
                start = entry.activityTime;
            } else if([entry.activityDesc isEqualToString:STATUS_DESC_AWAY]) {
                stop = entry.activityTime;
            }
            
            if(start != nil && stop != nil) {
                NSTimeInterval secondsBetweenStartAndStop = [start timeIntervalSinceDate:stop];
                sumInSeconds += secondsBetweenStartAndStop;
                
                start = nil;
                stop = nil;
            }
            
        } else {
            if([entry.activityDesc isEqualToString:STATUS_DESC_AWAY]) {
                stop = entry.activityTime;
                
                calculateStarted = YES;
            }
        }
        
        
    }
    
    sumInSeconds = (sumInSeconds < 0) ? -1 * sumInSeconds : sumInSeconds;
    
    NSLog(@"Sum in seconds: %f ", sumInSeconds);
    int numberOfFullHours = sumInSeconds / (60 * 60);
    
    NSLog(@"Sum in HOURS: %d ", numberOfFullHours);
    
    return numberOfFullHours;
}

- (void)readEntriesFromDatabase {
    if(_entries != nil) {
        _entries = nil;
    }
    
    NSArray *tmpArray = [DBUtil retrieveAllEntries];
    
    NSSortDescriptor *sdesc = [[NSSortDescriptor alloc]initWithKey:@"activityTime" ascending:NO];
    
    _entries = [tmpArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sdesc]];
    
}

- (void)readTimesheetFile {
    if(_entries != nil) {
        _entries = nil;
    }
    
    NSString *fullPath = [[self pathToDocumentsDirectory] stringByAppendingPathComponent:FILE_STORAGE];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if([manager fileExistsAtPath:fullPath]) {
        NSString *content = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
        
        // separate by new line
        NSArray* allLinedStrings = [content componentsSeparatedByCharactersInSet:
         [NSCharacterSet newlineCharacterSet]];
        
        _entries = [NSArray arrayWithArray:allLinedStrings];

    } else {
        NSString *testContent = [NSString stringWithFormat:@"line %d\nline %d\nline %d", 1, 2, 3];
        
        NSArray* allLinedStrings = [testContent componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet newlineCharacterSet]];
        
        _entries = [NSArray arrayWithArray:allLinedStrings];
    }
    
    
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
//    [self readTimesheetFile];
    [self readEntriesFromDatabase];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_entries count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    if(indexPath.row == 0) {
        //Zeroth row should have a summary cell...
        
        int sumHours = [self sumWorkHours];
        int sumMoneyInHUF = sumHours * 20 * 220;
        
        cell.textLabel.text = [NSString stringWithFormat:@"Sum hours: %d. Sum money: %d", sumHours, sumMoneyInHUF];
        
    } else {
    
        TimeSheetEntry *entry = [_entries objectAtIndex:indexPath.row - 1];
        
        NSString *str = [NSString stringWithFormat:@"%@: %@", [df stringFromDate:entry.activityTime], entry.activityDesc];

        cell.textLabel.text = str;
        
//        UIColor *bgColor = ([entry.activityDesc isEqualToString:STATUS_DESC_WORKING]) ? BACKGROUND_COLOR_WHEN_WORKING : BACKGROUND_COLOR_WHEN_AWAY;
//        
//        [cell setBackgroundColor:bgColor];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

@end
