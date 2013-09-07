//
//  ActivityViewController.m
//  myTime
//
//  Created by Kiss Rudolf Zsolt on 2013.09.05..
//  Copyright (c) 2013 Kiss Rudolf Zsolt. All rights reserved.
//

#import "ActivityViewController.h"

typedef enum {
    kActivityStatusAway,
    kActivityStatusWorkingOnProject
} ActivityStatus;

@interface ActivityViewController () {
    
    __weak IBOutlet UITextField *_tfProject;
    __weak IBOutlet UITextView *_tvSubtask;
    __weak IBOutlet UIButton *_btnActivity;
    
    ActivityStatus _currentActivityStatus;
}

- (IBAction)changeMyStatus:(id)sender;


@end

@implementation ActivityViewController

#pragma mark - private methods

- (NSString *)pathToDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
    
}


- (IBAction)changeMyStatus:(id)sender {
    
    NSDate *now = [NSDate date];
    
    if(_currentActivityStatus == kActivityStatusAway) {
        
        _currentActivityStatus = kActivityStatusWorkingOnProject;
        
        [_btnActivity setTitle:@"Szünetet tartok" forState:UIControlStateNormal];
        
        
    } else if(_currentActivityStatus == kActivityStatusWorkingOnProject) {
        _currentActivityStatus = kActivityStatusAway;
        
        [_btnActivity setTitle:@"Folytatom a munkát" forState:UIControlStateNormal];
    }
    
    [self createEntryWithDate:now];
    
}

- (void)createEntryWithDate:(NSDate *)someDate {
    NSString *newEntry = nil;
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if(_currentActivityStatus == kActivityStatusWorkingOnProject) {
        
        
        newEntry = [NSString stringWithFormat:@"%@ %@\n", [df stringFromDate:someDate], @"MUNKA INDUL"];
    } else if(_currentActivityStatus == kActivityStatusAway) {
        newEntry = [NSString stringWithFormat:@"%@ %@\n", [df stringFromDate:someDate], @"MUNKA VÉGE"];
    }
    
    
    NSString *fullPath = [[self pathToDocumentsDirectory] stringByAppendingPathComponent:FILE_STORAGE];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:fullPath]) {
        NSError *error;
        
        [newEntry writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if(error) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Hiba" message:@"Nem sikerült rögzíteni a változást" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [av show];
        }
        
    } else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:fullPath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[newEntry dataUsingEncoding:NSUTF8StringEncoding]];
    }
}


#pragma mark - view lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(_currentActivityStatus == kActivityStatusAway) {
        [_btnActivity setTitle:@"Folytatom a munkát" forState:UIControlStateNormal];
        
    } else if(_currentActivityStatus == kActivityStatusWorkingOnProject) {
        [_btnActivity setTitle:@"Szünetet tartok" forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
