//
//  TimeSheetEntry.h
//  myTime
//
//  Created by Kiss Rudolf Zsolt on 2013.09.08..
//  Copyright (c) 2013 Kiss Rudolf Zsolt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeSheetEntry : NSManagedObject

@property (nonatomic, retain) NSDate * activityTime;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * subtask;
@property (nonatomic, retain) NSString * activityDesc;

@end
