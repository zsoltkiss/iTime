//
//  ActivityViewController.m
//  myTime
//
//  Created by Kiss Rudolf Zsolt on 2013.09.05..
//  Copyright (c) 2013 Kiss Rudolf Zsolt. All rights reserved.
//

#import "ActivityViewController.h"
#import "TimeSheetEntry.h"
#import "DBUtil.h"
#import <MBProgressHUD/MBProgressHUD.h>



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

- (void)changeMyStatus:(id)sender;
- (void)createNewEntry;
- (void)viewTapped:(UITapGestureRecognizer *)sender;

@end

@implementation ActivityViewController

#pragma mark - private methods

- (void)createNewEntry {
    
    TimeSheetEntry *newEntry = [DBUtil timeSheetEntryForCreate];
    [newEntry setSubtask:_tvSubtask.text];
    [newEntry setProject:_tfProject.text];
    [newEntry setActivityTime:[NSDate date]];
    [newEntry setActivityDesc:(_currentActivityStatus == kActivityStatusWorkingOnProject) ? STATUS_DESC_WORKING : STATUS_DESC_AWAY];
    
    NSError *persistError;
    BOOL success = [DBUtil persistInContext:[DBUtil getContext] useError:&persistError];
    
    NSLog(@"success: %d, error? %@", success, persistError);
    
}

- (NSString *)pathToDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
    
}


- (void)changeMyStatus:(id)sender {
    
    if(_tfProject.text.length == 0 || _tvSubtask.text.length == 0) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Hiányos adatok" message:@"Project vagy subtask hiányzik." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
    } else {
        
        if(_currentActivityStatus == kActivityStatusAway) {
            
            _currentActivityStatus = kActivityStatusWorkingOnProject;
            
            _tfProject.userInteractionEnabled = NO;
            _tvSubtask.userInteractionEnabled = NO;
            
            
            _tfProject.alpha = ALPHA_WHEN_WORKING;
            _tvSubtask.alpha = ALPHA_WHEN_WORKING;
            
            [_btnActivity setTitle:@"Szünetet tartok" forState:UIControlStateNormal];
            
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Dolgozom...";
            
            
            
        } else if(_currentActivityStatus == kActivityStatusWorkingOnProject) {
            _currentActivityStatus = kActivityStatusAway;
            
            _tfProject.text = nil;
            _tvSubtask.text = nil;
            
            _tfProject.userInteractionEnabled = YES;
            _tvSubtask.userInteractionEnabled = YES;
            
            _tfProject.alpha = ALPHA_WHEN_AWAY;
            _tvSubtask.alpha = ALPHA_WHEN_AWAY;
            
            
            [_btnActivity setTitle:@"Folytatom a munkát" forState:UIControlStateNormal];
        }
        
        self.view.backgroundColor = (_currentActivityStatus == kActivityStatusWorkingOnProject) ? BACKGROUND_COLOR_WHEN_WORKING : BACKGROUND_COLOR_WHEN_AWAY;
        
        [self createNewEntry];
        
        
        
    }
    
}

- (void)viewTapped:(UITapGestureRecognizer *)sender {
    
    if([sender isEqual:_btnActivity]) {
        [self changeMyStatus:_btnActivity];
    } else {
    
        [self.view endEditing:YES];
    }
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
    
    [_btnActivity addTarget:self action:@selector(changeMyStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    
//    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapped:)];
//    [self.view addGestureRecognizer:rec];
//    
    _tvSubtask.text = nil;
    
	
    if(_currentActivityStatus == kActivityStatusAway) {
        [_btnActivity setTitle:@"Folytatom a munkát" forState:UIControlStateNormal];
        
    } else if(_currentActivityStatus == kActivityStatusWorkingOnProject) {
        [_btnActivity setTitle:@"Szünetet tartok" forState:UIControlStateNormal];
    }
    
    self.view.backgroundColor = (_currentActivityStatus == kActivityStatusWorkingOnProject) ? BACKGROUND_COLOR_WHEN_WORKING : BACKGROUND_COLOR_WHEN_AWAY;
}

- (void)viewWillAppear:(BOOL)animated {

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}




@end
